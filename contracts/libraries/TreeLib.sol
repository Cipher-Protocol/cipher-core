// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IPoseidonT3} from "../interfaces/IPoseidonT3.sol";
import {Constants} from "./Constants.sol";
import {Errors} from "./Errors.sol";
import {Events} from "./Events.sol";
import {TreeData} from "../DataType.sol";

library TreeLib {
    using TreeLib for TreeData;

    /// @notice Initialize the tree data
    /// @param tree The tree data
    /// @param depth The depth of the tree
    function init(TreeData storage tree, uint256 depth) internal {
        if (depth == 0 || depth > Constants.MAX_DEPTH) revert Errors.InvalidTreeDepth(depth);

        tree.depth = depth;
        tree.root = defaultZeroVal(depth);
    }

    /// @notice Update the history roots array and index
    /// @dev Add the current root to the history roots array before insert new commitments
    /// @param tree The tree data
    /// @param root The new root
    function updateHistoryRoot(TreeData storage tree, uint256 root) internal {
        tree.historyRoots[tree.historyRootsIdx] = root;
        tree.historyRootsIdx = uint8(addmod(tree.historyRootsIdx, 1, Constants.VALID_HISTORY_ROOTS_SIZE));
    }

    /// @notice Update the nullifiers mapping
    /// @dev Set the nullifiers to true to avoid double spend
    /// @param tree The tree data
    /// @param token The token of the token tree
    /// @param nullifiers The nullifiers array
    /// @param nullifierLen The length of nullifiers array
    function updateNullifiers(
        TreeData storage tree,
        IERC20 token,
        uint256[] calldata nullifiers,
        uint256 nullifierLen
    ) internal {
        for (uint256 i; i < nullifierLen; ) {
            uint256 nullifier = nullifiers[i];
            if (tree.nullifiers[nullifier]) revert Errors.InvalidNullifier(nullifier);

            tree.nullifiers[nullifier] = true;
            emit Events.NewNullifier(token, nullifier);

            unchecked {
                ++i;
            }
        }
    }

    /// @notice Insert commitments to the incremental merkle tree
    /// @dev Insert commitments to the incremental merkle tree and update the tree root
    /// @param tree The tree data
    /// @param token The token of the token tree
    /// @param poseidonT3 The PoseidonT3 contract address
    /// @param commitments The commitments array
    /// @param commitmentLen The length of commitments array
    function insertCommitments(
        TreeData storage tree,
        IERC20 token,
        IPoseidonT3 poseidonT3,
        uint256[] calldata commitments,
        uint256 commitmentLen
    ) internal {
        for (uint256 i; i < commitmentLen; ) {
            uint256 commitment = commitments[i];
            uint256 leafIndex = tree.numberOfLeaves;
            uint256 root = tree.insert(poseidonT3, commitment, leafIndex);
            emit Events.NewCommitment(token, root, commitment, leafIndex);

            unchecked {
                ++i;
            }
        }
    }

    /// @notice Insert a commitment to the incremental merkle tree
    function insert(
        TreeData storage tree,
        IPoseidonT3 poseidonT3,
        uint256 leaf,
        uint256 leafIndex
    ) internal returns (uint256) {
        if (leaf >= Constants.SNARK_SCALAR_FIELD) revert Errors.InvalidFieldValue(leaf);
        if (leafIndex >= 2 ** Constants.DEFAULT_TREE_DEPTH)
            revert Errors.TreeIsFull(Constants.DEFAULT_TREE_DEPTH, leafIndex);

        uint256 hash = leaf;
        for (uint8 i; i < Constants.DEFAULT_TREE_DEPTH; ) {
            if (leafIndex & 1 == 0) {
                tree.lastSubtrees[i] = [hash, defaultZeroVal(i)];
            } else {
                tree.lastSubtrees[i][1] = hash;
            }

            hash = poseidonT3.poseidon(tree.lastSubtrees[i]);
            leafIndex >>= 1;

            unchecked {
                ++i;
            }
        }

        tree.root = hash;
        tree.numberOfLeaves += 1;
        return hash;
    }

    /// @notice Check if the root is in the history roots array
    /// @dev Check from the latest history root to the oldest history root to save gas
    ///      i.e. If `historyRootsIdx` = 27, check from `historyRoots`[27] -> [26] -> [25] ... [1] -> [0] -> [31] ... [29] -> [28]
    /// @param tree The tree data
    /// @param root The root to check
    /// @return isHistoryRoot True if the root is in the history roots array
    function isHistoryRoot(TreeData storage tree, uint256 root) internal view returns (bool) {
        // ex: 32 - 27 = 5
        uint256 start = Constants.VALID_HISTORY_ROOTS_SIZE - tree.historyRootsIdx;
        // ex: 5 + 32 = 37
        uint256 end = start + Constants.VALID_HISTORY_ROOTS_SIZE;
        // ex: 5, 6, 7, ...36
        for (start; start < end; ) {
            // ex: (32 - (5 % 32)) % 32 = 27 (27, 26, 25, ... 1, 0, 31, 30, 29, 28)
            uint256 rootIdx = (Constants.VALID_HISTORY_ROOTS_SIZE - (start % Constants.VALID_HISTORY_ROOTS_SIZE)) %
                Constants.VALID_HISTORY_ROOTS_SIZE;
            if (root == tree.historyRoots[rootIdx]) return true;

            unchecked {
                ++start;
            }
        }
        return false;
    }

    /// @notice Check if the root is the latest root
    /// @param tree The tree data
    /// @param root The root to check
    /// @return isLastestRoot True if the root is the latest root
    function isLastestRoot(TreeData storage tree, uint256 root) internal view returns (bool) {
        return root == tree.root;
    }

    /// @notice Check if the root is valid
    /// @dev Check if the root is the latest root or in the history roots array
    /// @param tree The tree data
    /// @param root The root to check
    /// @return isValidRoot True if the root is valid
    function isValidRoot(TreeData storage tree, uint256 root) internal view returns (bool) {
        return isLastestRoot(tree, root) || isHistoryRoot(tree, root);
    }

    /// @notice Default zero value for each node in the merkle tree
    ///         Z_0 = DEFAULT_LEAF_ZERO_VALUE
    ///         Z_1 = poseidon(Z_0, Z_0)
    ///         Z_2 = poseidon(Z_1, Z_1)
    ///         ...
    ///         Z_24 = poseidon(Z_23, Z_23)
    /// @param idx The index of the node in the merkle tree
    /// @return zeroValue The default zero value of the node
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
