// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IncrementalBinaryTree, IncrementalTreeData} from "@zk-kit/incremental-merkle-tree.sol/IncrementalBinaryTree.sol";
import {Constants} from "./Constants.sol";
import {Errors} from "./Errors.sol";
import {Events} from "./Events.sol";

/** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        Tree data structure in storage
***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
struct TreeData {
    /// @notice The incremental merkle tree data
    IncrementalTreeData incrementalTreeData;
    /// @notice The index of the latest history root in history roots array
    uint8 historyRootsIdx;
    /// @notice The history roots array (The 32 valid roots before the latest root)
    ///         to avoid others updating the root when user calculating the proof in client side
    uint256[32] historyRoots;
    /// @notice The nullifiers mapping to avoid double spend
    mapping(uint256 => bool) nullifiers;
}

library TreeLib {
    using IncrementalBinaryTree for IncrementalTreeData;

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
    /// @param _commitments The commitments array
    /// @param commitmentLen The length of commitments array
    function insertCommitments(
        TreeData storage _tree,
        IERC20 _token,
        uint256[] calldata _commitments,
        uint256 commitmentLen
    ) internal {
        for (uint256 i; i < commitmentLen; ++i) {
            uint256 commitment = _commitments[i];
            uint256 leafIndex = _tree.incrementalTreeData.numberOfLeaves;
            _tree.incrementalTreeData.insert(commitment);
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
        return _root == _tree.incrementalTreeData.root;
    }

    /// @notice Check if the root is valid
    /// @dev Check if the root is the latest root or in the history roots array
    /// @param _tree The tree data
    /// @param _root The root to check
    /// @return isValidRoot True if the root is valid
    function isValidRoot(TreeData storage _tree, uint256 _root) internal view returns (bool) {
        return isLastestRoot(_tree, _root) || isHistoryRoot(_tree, _root);
    }
}
