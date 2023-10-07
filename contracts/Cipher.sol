// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IncrementalBinaryTree, IncrementalTreeData} from "@zk-kit/incremental-merkle-tree.sol/IncrementalBinaryTree.sol";
import {CipherStorage, TreeData, Proof, PublicSignals, PublicInfo, RelayerInfo} from "./CipherStorage.sol";
import {CipherConfig} from "./CipherConfig.sol";
import {CipherLib} from "./CipherLib.sol";
import {ICipherVerifier} from "./interfaces/ICipherVerifier.sol";

import "hardhat/console.sol";

contract Cipher is CipherStorage, Ownable {
    using IncrementalBinaryTree for IncrementalTreeData;
    using CipherLib for *;

    error TokenTreeAlreadyInitialized(IERC20 token);
    error TokenTreeNotExists(IERC20 token);
    error InvalidProof(Proof proof);
    error InvalidRecipientAddr();
    error InvalidRoot(uint256 root);
    error InvalidMaxAllowableFeeRate(uint16 maxAllowableFeeRate);
    error InvalidRelayerFeeRate(uint16 feeRate, uint16 maxAllowableFeeRate);

    event NewTokenTree(IERC20 token, uint256 merkleTreeDepth, uint256 zeroValue);
    event NewRelayer(address relayer, string relayerMetadataUri);
    event RelayerUpdated(address relayer, string newRelayerMetadataUri);
    event NewRoot(IERC20 token, uint256 root);
    event RelayInfo(address sender, RelayerInfo relayerInfo, uint256 feeAmt);

    constructor(address verifierAddr) CipherStorage(verifierAddr) {
        IERC20 defaultEthToken = IERC20(CipherConfig.DEFAULT_ETH_ADDRESS);
        // NOTE: reference railgun's implementation
        uint256 zeroValue = uint256(keccak256(abi.encode(defaultEthToken))) % CipherConfig.SNARK_SCALAR_FIELD;
        treeData[defaultEthToken].incrementalTreeData.init(CipherConfig.DEFAULT_TREE_DEPTH, zeroValue);
        emit NewTokenTree(defaultEthToken, CipherConfig.DEFAULT_TREE_DEPTH, zeroValue);
    }

    function initTokenTree(IERC20 token) external {
        TreeData storage tree = treeData[token];
        if (tree.incrementalTreeData.depth != 0) revert TokenTreeAlreadyInitialized(token);

        uint256 zeroValue = uint256(keccak256(abi.encode(token))) % CipherConfig.SNARK_SCALAR_FIELD;
        tree.incrementalTreeData.init(CipherConfig.DEFAULT_TREE_DEPTH, zeroValue);
        emit NewTokenTree(token, CipherConfig.DEFAULT_TREE_DEPTH, zeroValue);
    }

    // TODO: not completed
    function registerAsRelayer(string memory relayerMetadataUri) external {
        relayerMetadataUris[msg.sender] = relayerMetadataUri;
        emit NewRelayer(msg.sender, relayerMetadataUri);
    }

    function updateRelayerMetadataUri(string memory newRelayerMetadataUri) external {
        relayerMetadataUris[msg.sender] = newRelayerMetadataUri;
        emit RelayerUpdated(msg.sender, newRelayerMetadataUri);
    }

    function createTx(Proof calldata proof, PublicInfo calldata publicInfo) external payable {
        IERC20 token = publicInfo.token;
        TreeData storage tree = treeData[token];
        if (tree.incrementalTreeData.depth == 0) revert TokenTreeNotExists(token);

        PublicSignals calldata publicSignals = proof.publicSignals;

        // TODO: move to internal function _beforeCreateTx
        /* ========== before core logic start ========== */
        // check root is valid
        if (!publicSignals.root.isValidRoot(tree)) revert InvalidRoot(publicSignals.root);

        token.handleTransferFrom(msg.sender, publicSignals.publicInAmt);

        publicInfo.requireValidPublicInfo(publicSignals.publicInfoHash);
        bytes2 utxoType = CipherLib.calcUtxoType(
            publicSignals.inputNullifiers.length,
            publicSignals.outputCommitments.length
        );

        /* ========== before core logic end ========== */

        // TODO: move to internal function _createTx
        /* ========== core logic start ========== */
        if (!cipherVerifier.verifyProof(proof, utxoType)) revert InvalidProof(proof);

        tree.updateNullifiers(token, publicSignals.inputNullifiers);
        // update original root to history roots before insert new commitment
        tree.updateHistoryRoot(publicSignals.root);
        tree.insertCommitments(token, publicSignals.outputCommitments);
        // TODO: emit a event for whole info
        emit NewRoot(token, tree.incrementalTreeData.root);

        /* ========== core logic end ========== */

        // TODO: move to internal function _afterCreateTx
        /* ========== after core logic start ========== */

        if (publicSignals.publicOutAmt > 0) {
            if (publicInfo.recipient == address(0)) revert InvalidRecipientAddr();
            token.handleTransfer(publicInfo.recipient, publicSignals.publicOutAmt);
        }

        /* ========== after core logic end ========== */
    }

    function createTxWithRelayer(
        Proof calldata proof,
        PublicInfo calldata publicInfo,
        RelayerInfo calldata relayerInfo
    ) external payable {
        IERC20 token = publicInfo.token;
        TreeData storage tree = treeData[token];
        if (tree.incrementalTreeData.depth == 0) revert TokenTreeNotExists(token);

        PublicSignals calldata publicSignals = proof.publicSignals;

        // TODO: move to internal function _beforeCreateTx
        /* ========== before core logic start ========== */
        // check root is valid
        if (!publicSignals.root.isValidRoot(tree)) revert InvalidRoot(publicSignals.root);

        token.handleTransferFrom(msg.sender, publicSignals.publicInAmt);

        publicInfo.requireValidPublicInfo(publicSignals.publicInfoHash);
        bytes2 utxoType = CipherLib.calcUtxoType(
            publicSignals.inputNullifiers.length,
            publicSignals.outputCommitments.length
        );

        /* ========== before core logic end ========== */

        // TODO: move to internal function _createTx
        /* ========== core logic start ========== */
        if (!cipherVerifier.verifyProof(proof, utxoType)) revert InvalidProof(proof);

        tree.updateNullifiers(token, publicSignals.inputNullifiers);
        // update original root to history roots before insert new commitment
        tree.updateHistoryRoot(publicSignals.root);
        tree.insertCommitments(token, publicSignals.outputCommitments);
        // TODO: emit a event for whole info
        emit NewRoot(token, tree.incrementalTreeData.root);

        /* ========== core logic end ========== */

        // TODO: move to internal function _afterCreateTx
        /* ========== after core logic start ========== */
        // TODO: check position of this line
        if (publicInfo.maxAllowableFeeRate > CipherConfig.FEE_BASE)
            revert InvalidMaxAllowableFeeRate(publicInfo.maxAllowableFeeRate);
        if (relayerInfo.feeRate > publicInfo.maxAllowableFeeRate)
            revert InvalidRelayerFeeRate(relayerInfo.feeRate, publicInfo.maxAllowableFeeRate);

        if (publicSignals.publicOutAmt > 0) {
            if (publicInfo.recipient == address(0)) revert InvalidRecipientAddr();
            uint256 feeAmt = (publicSignals.publicOutAmt * relayerInfo.feeRate) / CipherConfig.FEE_BASE;
            token.handleTransfer(publicInfo.recipient, publicSignals.publicOutAmt - feeAmt);
            token.handleTransfer(relayerInfo.feeReceiver, feeAmt);
            emit RelayInfo(msg.sender, relayerInfo, feeAmt);
        }
        /* ========== after core logic end ========== */
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

    function getVerifier() external view returns (ICipherVerifier) {
        return cipherVerifier;
    }

    function isNullified(IERC20 token, uint256 nullifier) external view returns (bool) {
        return treeData[token].nullifiers[nullifier];
    }

    function isValidRoot(IERC20 token, uint256 root) external view returns (bool) {
        return root.isValidRoot(treeData[token]);
    }

    // function _beforeCreateTx(UtxoData memory utxoData, PublicInfo memory publicInfo) internal virtual {}
}
