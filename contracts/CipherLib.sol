// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IncrementalBinaryTree, IncrementalTreeData} from "@zk-kit/incremental-merkle-tree.sol/IncrementalBinaryTree.sol";
import {TreeData, PublicInfo} from "./CipherStorage.sol";
import {CipherConfig} from "./CipherConfig.sol";

library CipherLib {
    using IncrementalBinaryTree for IncrementalTreeData;
    using SafeERC20 for IERC20;

    error TransferFailed(address payable receiver, uint256 amount, bytes data);
    error InvalidMsgValue(uint256 msgValue);
    error AmountInconsistent(uint256 amount, uint256 transferredAmt);
    error InvalidUtxoType(bytes2 utxoType, uint256 nullifierNum, uint256 commitmentNum);
    error InvalidPublicInfo(uint256 publicInfoHash, uint256 calcPublicInfoHash);
    error InvalidNullifier(uint256 nullifier);
    error InvalidNullifierNum(uint256 nullifierNum);
    error InvalidCommitmentNum(uint256 commitmentNum);

    event NewNullifier(IERC20 token, uint256 nullifier);
    event NewCommitment(IERC20 token, uint256 commitment, uint256 leafIndex);

    function handleTransfer(IERC20 token, address payable receiver, uint256 amount) internal {
        if (address(token) == CipherConfig.DEFAULT_ETH_ADDRESS) {
            (bool success, bytes memory data) = receiver.call{value: amount}("");
            if (!success) revert TransferFailed(receiver, amount, data);
        } else {
            token.safeTransfer(receiver, amount);
        }
    }

    function handleTransferFrom(IERC20 token, address sender, uint256 amount) internal {
        if (address(token) == CipherConfig.DEFAULT_ETH_ADDRESS) {
            // if transfer ETH, msg.value should equal to input amount
            if (msg.value != amount) revert InvalidMsgValue(msg.value);
        } else {
            // if transfer ERC20, msg.value should equal to 0
            if (msg.value != 0) revert InvalidMsgValue(msg.value);
            if (amount > 0) {
                uint256 transferredAmt = token.balanceOf(address(this));
                token.safeTransferFrom(sender, address(this), amount);
                transferredAmt = token.balanceOf(address(this)) - transferredAmt;
                if (amount != transferredAmt) revert AmountInconsistent(amount, transferredAmt);
            }
        }
    }

    function updateHistoryRoot(TreeData storage tree, uint256 root) internal {
        tree.historyRoots[tree.historyRootsIdx] = root;
        tree.historyRootsIdx = uint8(addmod(tree.historyRootsIdx, 1, CipherConfig.VALID_HISTORY_ROOTS_SIZE));
    }

    function updateNullifiers(TreeData storage tree, IERC20 token, uint256[] calldata nullifiers) internal {
        for (uint256 i; i < nullifiers.length; ++i) {
            uint256 nullifier = nullifiers[i];
            if (tree.nullifiers[nullifier]) revert InvalidNullifier(nullifiers[i]);

            tree.nullifiers[nullifier] = true;
            emit NewNullifier(token, nullifier);
        }
    }

    function insertCommitments(TreeData storage tree, IERC20 token, uint256[] calldata commitments) internal {
        for (uint256 i; i < commitments.length; ++i) {
            uint256 commitment = commitments[i];
            tree.incrementalTreeData.insert(commitment);
            emit NewCommitment(token, commitment, tree.incrementalTreeData.numberOfLeaves);
        }
    }

    function calcUtxoType(uint256 inputNullifierNum, uint256 outputCommitmentNum) internal pure returns (bytes2) {
        if (inputNullifierNum > CipherConfig.NUM_OF_ONE_BYTES) revert InvalidNullifierNum(inputNullifierNum);
        if (outputCommitmentNum > CipherConfig.NUM_OF_ONE_BYTES) revert InvalidCommitmentNum(outputCommitmentNum);
        return bytes2(uint16((inputNullifierNum << 8) | outputCommitmentNum));
    }

    function requireValidUtxoType(bytes2 utxoType, uint256 nullifierNum, uint256 commitmentNum) internal pure {
        // The first byte of utxoType should be equal to nullifierNum &&
        // The second byte of utxoType should be equal to commitmentNum
        if (uint8(utxoType[0]) != nullifierNum || uint8(utxoType[1]) != commitmentNum)
            revert InvalidUtxoType(utxoType, nullifierNum, commitmentNum);
    }

    function requireValidPublicInfo(PublicInfo memory publicInfo, uint256 publicInfoHash) internal pure {
        uint256 calcPublicInfoHash = uint256(keccak256(abi.encode(publicInfo))) % CipherConfig.SNARK_SCALAR_FIELD;
        if (publicInfoHash != calcPublicInfoHash) revert InvalidPublicInfo(publicInfoHash, calcPublicInfoHash);
    }

    function isHistoryRoot(uint256 root, TreeData storage tree) internal view returns (bool) {
        // ex: 32 - 27 = 5
        uint256 start = CipherConfig.VALID_HISTORY_ROOTS_SIZE - tree.historyRootsIdx;
        // ex: 5 + 32 = 37
        uint256 end = start + CipherConfig.VALID_HISTORY_ROOTS_SIZE;
        // ex: 5, 6, 7, ...36
        for (start; start < end; ++start) {
            // ex: (32 - (5 % 32)) % 32 = 27 (27, 26, 25, ... 1, 0, 31, 30, 29, 28)
            uint256 rootIdx = (CipherConfig.VALID_HISTORY_ROOTS_SIZE -
                (start % CipherConfig.VALID_HISTORY_ROOTS_SIZE)) % CipherConfig.VALID_HISTORY_ROOTS_SIZE;
            if (root == tree.historyRoots[rootIdx]) return true;
        }
        return false;
    }

    function isLastestRoot(uint256 root, TreeData storage tree) internal view returns (bool) {
        return root == tree.incrementalTreeData.root;
    }

    function isValidRoot(uint256 root, TreeData storage tree) internal view returns (bool) {
        return isLastestRoot(root, tree) || isHistoryRoot(root, tree);
    }
}
