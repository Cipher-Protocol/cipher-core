// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IPoseidonT3} from "../interfaces/IPoseidonT3.sol";
import {Constants} from "./Constants.sol";
import {Errors} from "./Errors.sol";
import {Events} from "./Events.sol";

/** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        Tree data structure in storage
***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
struct TreeData {
    /// @notice The incremental merkle tree data
    // uint256 depth; // Depth of the tree (levels - 1).
    uint256 root; // Root hash of the tree.
    uint256 numberOfLeaves; // Number of leaves of the tree.
    mapping(uint256 => uint256[2]) lastSubtrees; // Caching these values is essential to efficient appends.
    /// @notice The index of the latest history root in history roots array
    uint8 historyRootsIdx;
    /// @notice The history roots array (The 32 valid roots before the latest root)
    ///         to avoid others updating the root when user calculating the proof in client side
    uint256[32] historyRoots;
    /// @notice The nullifiers mapping to avoid double spend
    mapping(uint256 => bool) nullifiers;
}

library TreeLib {
    using TreeLib for TreeData;

    /// @notice Update the history roots array and index
    /// @dev Add the current root to the history roots array before insert new commitments
    /// @param _tree The tree data
    /// @param _root The new root
    function updateHistoryRoot(TreeData storage _tree, uint256 _root) internal {
        _tree.historyRoots[_tree.historyRootsIdx] = _root;
        _tree.historyRootsIdx = uint8(addmod(_tree.historyRootsIdx, 1, Constants.VALID_HISTORY_ROOTS_SIZE));
    }

    /// @notice Update the nullifiers mapping
    /// @dev Set the nullifiers to true to avoid double spend
    /// @param _tree The tree data
    /// @param _token The token of the token tree
    /// @param _nullifiers The nullifiers array
    /// @param nullifierLen The length of nullifiers array
    function updateNullifiers(
        TreeData storage _tree,
        IERC20 _token,
        uint256[] calldata _nullifiers,
        uint256 nullifierLen
    ) internal {
        for (uint256 i; i < nullifierLen; ++i) {
            uint256 nullifier = _nullifiers[i];
            if (_tree.nullifiers[nullifier]) revert Errors.InvalidNullifier(nullifier);

            _tree.nullifiers[nullifier] = true;
            emit Events.NewNullifier(_token, nullifier);
        }
    }

    /// @notice Insert commitments to the incremental merkle tree
    /// @dev Insert commitments to the incremental merkle tree and update the tree root
    /// @param _tree The tree data
    /// @param _token The token of the token tree
    /// @param _poseidonT3 The PoseidonT3 contract address
    /// @param _commitments The commitments array
    /// @param commitmentLen The length of commitments array
    function insertCommitments(
        TreeData storage _tree,
        IERC20 _token,
        IPoseidonT3 _poseidonT3,
        uint256[] calldata _commitments,
        uint256 commitmentLen
    ) internal {
        for (uint256 i; i < commitmentLen; ++i) {
            uint256 commitment = _commitments[i];
            uint256 leafIndex = _tree.numberOfLeaves;
            _tree.insert(_poseidonT3, commitment);
            emit Events.NewCommitment(_token, commitment, leafIndex);
        }
    }

    /// @notice Check if the root is in the history roots array
    /// @dev Check from the latest history root to the oldest history root to save gas
    ///      i.e. If `historyRootsIdx` = 27, check from `historyRoots`[27] -> [26] -> [25] ... [1] -> [0] -> [31] ... [29] -> [28]
    /// @param _tree The tree data
    /// @param _root The root to check
    /// @return isHistoryRoot True if the root is in the history roots array
    function isHistoryRoot(TreeData storage _tree, uint256 _root) internal view returns (bool) {
        // ex: 32 - 27 = 5
        uint256 start = Constants.VALID_HISTORY_ROOTS_SIZE - _tree.historyRootsIdx;
        // ex: 5 + 32 = 37
        uint256 end = start + Constants.VALID_HISTORY_ROOTS_SIZE;
        // ex: 5, 6, 7, ...36
        for (start; start < end; ++start) {
            // ex: (32 - (5 % 32)) % 32 = 27 (27, 26, 25, ... 1, 0, 31, 30, 29, 28)
            uint256 rootIdx = (Constants.VALID_HISTORY_ROOTS_SIZE - (start % Constants.VALID_HISTORY_ROOTS_SIZE)) %
                Constants.VALID_HISTORY_ROOTS_SIZE;
            if (_root == _tree.historyRoots[rootIdx]) return true;
        }
        return false;
    }

    /// @notice Check if the root is the latest root
    /// @param _tree The tree data
    /// @param _root The root to check
    /// @return isLastestRoot True if the root is the latest root
    function isLastestRoot(TreeData storage _tree, uint256 _root) internal view returns (bool) {
        return _root == _tree.root;
    }

    /// @notice Check if the root is valid
    /// @dev Check if the root is the latest root or in the history roots array
    /// @param _tree The tree data
    /// @param _root The root to check
    /// @return isValidRoot True if the root is valid
    function isValidRoot(TreeData storage _tree, uint256 _root) internal view returns (bool) {
        return isLastestRoot(_tree, _root) || isHistoryRoot(_tree, _root);
    }

    function init(TreeData storage _tree) internal {
        // root = Z_24
        _tree.root = defaultZeroVal(Constants.DEFAULT_TREE_DEPTH);
    }

    function insert(TreeData storage _tree, IPoseidonT3 poseidonT3, uint256 leaf) internal returns (uint256) {
        // uint256 depth = _tree.depth;

        require(leaf < Constants.SNARK_SCALAR_FIELD, "IncrementalBinaryTree: leaf must be < SNARK_SCALAR_FIELD");
        require(_tree.numberOfLeaves < 2 ** Constants.DEFAULT_TREE_DEPTH, "IncrementalBinaryTree: tree is full");

        uint256 index = _tree.numberOfLeaves;
        uint256 hash = leaf;

        for (uint8 i; i < Constants.DEFAULT_TREE_DEPTH; ) {
            if (index & 1 == 0) {
                _tree.lastSubtrees[i] = [hash, defaultZeroVal(i)];
            } else {
                _tree.lastSubtrees[i][1] = hash;
            }

            hash = poseidonT3.poseidon(_tree.lastSubtrees[i]);
            index >>= 1;

            unchecked {
                ++i;
            }
        }

        _tree.root = hash;
        _tree.numberOfLeaves += 1;
        return hash;
    }

    function defaultZeroVal(uint256 idx) internal pure returns (uint256) {
        if (idx == 0) return Constants.Z_0;
        if (idx == 1) return Constants.Z_1;
        if (idx == 2) return Constants.Z_2;
        if (idx == 3) return Constants.Z_3;
        if (idx == 4) return Constants.Z_4;
        if (idx == 5) return Constants.Z_5;
        if (idx == 6) return Constants.Z_6;
        if (idx == 7) return Constants.Z_7;
        if (idx == 8) return Constants.Z_8;
        if (idx == 9) return Constants.Z_9;
        if (idx == 10) return Constants.Z_10;
        if (idx == 11) return Constants.Z_11;
        if (idx == 12) return Constants.Z_12;
        if (idx == 13) return Constants.Z_13;
        if (idx == 14) return Constants.Z_14;
        if (idx == 15) return Constants.Z_15;
        if (idx == 16) return Constants.Z_16;
        if (idx == 17) return Constants.Z_17;
        if (idx == 18) return Constants.Z_18;
        if (idx == 19) return Constants.Z_19;
        if (idx == 20) return Constants.Z_20;
        if (idx == 21) return Constants.Z_21;
        if (idx == 22) return Constants.Z_22;
        if (idx == 23) return Constants.Z_23;
        if (idx == 24) return Constants.Z_24;
        revert Errors.InvalidTreeDepth(idx);
    }
}
