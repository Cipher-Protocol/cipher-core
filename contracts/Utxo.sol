// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IncrementalBinaryTree, IncrementalTreeData} from "@zk-kit/incremental-merkle-tree.sol/IncrementalBinaryTree.sol";
import {UtxoStorage, TreeData} from "./UtxoStorage.sol";
import {IVerifier} from "./interfaces/IVerifier.sol";

import "hardhat/console.sol";

contract Utxo is UtxoStorage {
    using SafeERC20 for IERC20;
    using IncrementalBinaryTree for IncrementalTreeData;

    error TokenTreeAlreadyInitialized(IERC20 token);
    error TokenTreeNotExists(IERC20 token);
    error InvalidMsgValue(uint256 msgValue);
    error AmountInconsistent(uint256 amount, uint256 transferredAmt);
    error TransferFailed(address payable receiver, uint256 amount, bytes data);
    error InvalidUtxoType(bytes2 utxoType, uint256 nullifierNum, uint256 commitmentNum);
    error InvalidNullifier(uint256 nullifier);
    error InvalidPublicInfo(uint256 publicInfoHash, uint256 expectedPublicInfoHash);
    error InvalidProof(Proof proof);
    error InvalidRecipientAddr(address recipientAddr);

    event NewTree(IERC20 token, uint256 merkleTreeDepth, uint256 zeroValue);
    event NewNullifier(IERC20 token, uint256 nullifier);
    event NewCommitment(IERC20 token, uint256 commitment, uint256 leafIndex);

    struct PublicInfo {
        bytes2 utxoType;
        address payable recipient;
        address payable relayer;
        uint256 fee;
        bytes data;
    }

    struct UtxoData {
        Proof proof;
        bytes32 root;
        uint256 publicInAmt;
        uint256 publicOutAmt;
        uint256 publicInfoHash;
        uint256[] inputNullifiers;
        uint256[] outputCommitments;
    }

    struct Proof {
        uint256[2] a;
        uint256[2][2] b;
        uint256[2] c;
        uint256[] publicSignals;
    }

    constructor(address verifierAddr) UtxoStorage(verifierAddr) {
        IERC20 defaultEthToken = IERC20(DEFAULT_ETH_ADDRESS);
        uint256 zeroValue = uint256(keccak256(abi.encode(defaultEthToken))) % SNARK_SCALAR_FIELD;
        treeData[defaultEthToken].incrementalTreeData.init(DEFAULT_TREE_DEPTH, zeroValue);
        emit NewTree(defaultEthToken, DEFAULT_TREE_DEPTH, zeroValue);
    }

    function initTokenTree(IERC20 token) external {
        TreeData storage tree = treeData[token];
        if (tree.incrementalTreeData.depth != 0) revert TokenTreeAlreadyInitialized(token);

        uint256 zeroValue = uint256(keccak256(abi.encode(token))) % SNARK_SCALAR_FIELD;
        tree.incrementalTreeData.init(DEFAULT_TREE_DEPTH, zeroValue);
        emit NewTree(token, DEFAULT_TREE_DEPTH, zeroValue);
    }

    function createTx(UtxoData memory utxoData, PublicInfo memory publicInfo) external payable {
        IERC20 token = IERC20(_parseData(publicInfo.data));
        TreeData storage tree = treeData[token];
        if (tree.incrementalTreeData.depth == 0) revert TokenTreeNotExists(token);

        /// before core logic
        if (utxoData.publicInAmt > 0) {
            _transferFrom(token, msg.sender, utxoData.publicInAmt);
        }

        _checkUtxoType(publicInfo.utxoType, utxoData.inputNullifiers.length, utxoData.outputCommitments.length);

        uint256 publicInfoHash = uint256(keccak256(abi.encode(publicInfo))) % SNARK_SCALAR_FIELD;
        if (utxoData.publicInfoHash != publicInfoHash)
            revert InvalidPublicInfo(utxoData.publicInfoHash, publicInfoHash);

        /// core logic
        for (uint256 i; i < utxoData.inputNullifiers.length; ++i) {
            if (tree.nullifiers[utxoData.inputNullifiers[i]]) revert InvalidNullifier(utxoData.inputNullifiers[i]);
        }

        if (
            !verifier.verifyProof(
                utxoData.proof.a,
                utxoData.proof.b,
                utxoData.proof.c,
                utxoData.proof.publicSignals,
                publicInfo.utxoType
            )
        ) revert InvalidProof(utxoData.proof);

        for (uint256 i; i < utxoData.inputNullifiers.length; ++i) {
            uint256 nullifier = utxoData.inputNullifiers[i];
            tree.nullifiers[nullifier] = true;
            emit NewNullifier(token, nullifier);
        }

        for (uint256 i; i < utxoData.outputCommitments.length; ++i) {
            uint256 commitment = utxoData.outputCommitments[i];
            // insert commitment into the tree
            tree.incrementalTreeData.insert(commitment);
            emit NewCommitment(token, commitment, tree.incrementalTreeData.numberOfLeaves);
        }

        /// after core logic
        if (utxoData.publicOutAmt > 0) {
            if (publicInfo.recipient == address(0)) revert InvalidRecipientAddr(publicInfo.recipient);
            _transfer(token, publicInfo.recipient, utxoData.publicOutAmt - publicInfo.fee);
        }

        if (publicInfo.fee > 0) {
            _transfer(token, publicInfo.relayer, publicInfo.fee);
        }
    }

    function getTreeDepth(IERC20 token) external view returns (uint256) {
        return treeData[token].incrementalTreeData.depth;
    }

    function getTreeRoot(IERC20 token) external view returns (uint256) {
        return treeData[token].incrementalTreeData.root;
    }

    function getTreeLeafNum(IERC20 token) external view returns (uint256) {
        return treeData[token].incrementalTreeData.numberOfLeaves;
    }

    function getTreeZeroes(IERC20 token, uint256 level) external view returns (uint256) {
        return treeData[token].incrementalTreeData.zeroes[level];
    }

    function getTreeLastSubtrees(IERC20 token, uint256 level) external view returns (uint256[2] memory) {
        return treeData[token].incrementalTreeData.lastSubtrees[level];
    }

    function isNullify(IERC20 token, uint256 nullifier) external view returns (bool) {
        return treeData[token].nullifiers[nullifier];
    }

    function _checkUtxoType(bytes2 utxoType, uint256 nullifierNum, uint256 commitmentNum) internal pure {
        // the first byte of utxoType should be equal to nullifierNum
        // the second byte of utxoType should be equal to commitmentNum
        if (uint8(utxoType[0]) != nullifierNum || uint8(utxoType[1]) != commitmentNum)
            revert InvalidUtxoType(utxoType, nullifierNum, commitmentNum);
    }

    function _parseData(bytes memory data) internal pure virtual returns (address) {
        return abi.decode(data, (address));
    }

    function _transfer(IERC20 token, address payable receiver, uint256 amount) internal {
        if (address(token) == DEFAULT_ETH_ADDRESS) {
            (bool success, bytes memory data) = receiver.call{value: amount}("");
            if (!success) revert TransferFailed(receiver, amount, data);
        } else {
            token.safeTransfer(receiver, amount);
        }
    }

    function _transferFrom(IERC20 token, address sender, uint256 amount) internal {
        if (address(token) == DEFAULT_ETH_ADDRESS) {
            if (msg.value != amount) revert InvalidMsgValue(msg.value);
        } else {
            if (msg.value != 0) revert InvalidMsgValue(msg.value);
            uint256 balanceBefore = token.balanceOf(address(this));
            token.safeTransferFrom(sender, address(this), amount);
            uint256 balanceAfter = token.balanceOf(address(this));
            uint256 transferredAmt = balanceAfter - balanceBefore;
            if (amount != transferredAmt) revert AmountInconsistent(amount, transferredAmt);
        }
    }

    // function before(UtxoData memory utxoData, PublicInfo memory publicInfo) internal virtual {}

    function verify(address verifierAddr, Proof memory proof, bytes2 _type) external {
        IVerifier verifier = IVerifier(verifierAddr);
        require(verifier.verifyProof(proof.a, proof.b, proof.c, proof.publicSignals, _type), "Invalid proof");
    }
}
