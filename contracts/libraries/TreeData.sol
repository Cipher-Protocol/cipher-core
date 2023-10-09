// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IncrementalBinaryTree, IncrementalTreeData} from "@zk-kit/incremental-merkle-tree.sol/IncrementalBinaryTree.sol";
import {Constants} from "./Constants.sol";
import {Errors} from "./Errors.sol";
import {Events} from "./Events.sol";

struct TreeData {
    IncrementalTreeData incrementalTreeData;
    /// @notice The index of the latest root in history roots
    uint8 historyRootsIdx;
    /// @notice History roots (The 32 valid roots before the latest root)
    /// @notice To avoid others updating the root when user calculating the proof in client side
    uint256[32] historyRoots;
    mapping(uint256 => bool) nullifiers;
}

library LibTreeData {
    using IncrementalBinaryTree for IncrementalTreeData;

    function updateHistoryRoot(TreeData storage _tree, uint256 _root) internal {
        _tree.historyRoots[_tree.historyRootsIdx] = _root;
        _tree.historyRootsIdx = uint8(addmod(_tree.historyRootsIdx, 1, Constants.VALID_HISTORY_ROOTS_SIZE));
    }

    function updateNullifiers(TreeData storage _tree, IERC20 _token, uint256[] calldata _nullifiers) internal {
        for (uint256 i; i < _nullifiers.length; ++i) {
            uint256 nullifier = _nullifiers[i];
            if (_tree.nullifiers[nullifier]) revert Errors.InvalidNullifier(nullifier);

            _tree.nullifiers[nullifier] = true;
            emit Events.NewNullifier(_token, nullifier);
        }
    }

    function insertCommitments(TreeData storage _tree, IERC20 _token, uint256[] calldata _commitments) internal {
        for (uint256 i; i < _commitments.length; ++i) {
            uint256 commitment = _commitments[i];
            _tree.incrementalTreeData.insert(commitment);
            emit Events.NewCommitment(_token, commitment, _tree.incrementalTreeData.numberOfLeaves);
        }
    }

    function isHistoryRoot(TreeData storage _tree, uint256 _root) internal view returns (bool) {
        // ex: 32 - 27 = 5
        uint256 start = Constants.VALID_HISTORY_ROOTS_SIZE - _tree.historyRootsIdx;
        // ex: 5 + 32 = 37
        uint256 end = start + Constants.VALID_HISTORY_ROOTS_SIZE;
        // ex: 5, 6, 7, ...36
        for (start; start < end; ++start) {
            // ex: (32 - (5 % 32)) % 32 = 27 (27, 26, 25, ... 1, 0, 31, 30, 29, 28)
            uint256 rootIdx = (Constants.VALID_HISTORY_ROOTS_SIZE -
                (start % Constants.VALID_HISTORY_ROOTS_SIZE)) % Constants.VALID_HISTORY_ROOTS_SIZE;
            if (_root == _tree.historyRoots[rootIdx]) return true;
        }
        return false;
    }

    function isLastestRoot(TreeData storage _tree, uint256 _root) internal view returns (bool) {
        return _root == _tree.incrementalTreeData.root;
    }

    function isValidRoot(TreeData storage _tree, uint256 _root) internal view returns (bool) {
        return isLastestRoot(_tree, _root) || isHistoryRoot(_tree, _root);
    }
}
