// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// intefaces
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ICipher} from "./interfaces/ICipher.sol";
import {ICipherVerifier} from "./interfaces/ICipherVerifier.sol";

// libraries
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IncrementalBinaryTree, IncrementalTreeData} from "@zk-kit/incremental-merkle-tree.sol/IncrementalBinaryTree.sol";
import {Constants} from "./libraries/Constants.sol";
import {Errors} from "./libraries/Errors.sol";
import {Events} from "./libraries/Events.sol";
import {Helper} from "./libraries/Helper.sol";
import {TokenTransfer} from "./libraries/TokenTransfer.sol";
import {TreeData, LibTreeData} from "./libraries/TreeData.sol";
import {Proof, PublicInfo, PublicSignals, RelayerInfo} from "./utils/DataType.sol";

contract Cipher is ICipher, Ownable {
    using IncrementalBinaryTree for IncrementalTreeData;
    using LibTreeData for TreeData;
    using TokenTransfer for IERC20;

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        Constants & Immutable
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    ICipherVerifier internal immutable cipherVerifier;

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        Storage
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    mapping(IERC20 => TreeData) internal treeData;
    mapping(address => string) internal relayerMetadataUris;

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        Constructor
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    constructor(address verifierAddr) {
        cipherVerifier = ICipherVerifier(verifierAddr);
        _initTokenTree(IERC20(Constants.DEFAULT_ETH_ADDRESS));
    }

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        User-facing external function
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    function initTokenTree(IERC20 token) external {
        _initTokenTree(token);
    }

    function createTx(Proof calldata proof, PublicInfo calldata publicInfo) external payable {
        IERC20 token = publicInfo.token;
        TreeData storage tree = treeData[token];
        if (tree.incrementalTreeData.depth == 0) revert Errors.TokenTreeNotExists(token);

        PublicSignals calldata publicSignals = proof.publicSignals;

        // TODO: move to internal function _beforeCreateTx
        /* ========== before core logic start ========== */
        // check root is valid
        // if (!publicSignals.root.isValidRoot(tree)) revert Errors.InvalidRoot(publicSignals.root);
        if (!tree.isValidRoot(publicSignals.root)) revert Errors.InvalidRoot(publicSignals.root);

        token.handleTransferFrom(msg.sender, publicSignals.publicInAmt);

        Helper.requireValidPublicInfo(publicInfo, publicSignals.publicInfoHash);
        bytes2 utxoType = Helper.calcUtxoType(
            publicSignals.inputNullifiers.length,
            publicSignals.outputCommitments.length
        );

        /* ========== before core logic end ========== */

        // TODO: move to internal function _createTx
        /* ========== core logic start ========== */
        if (!cipherVerifier.verifyProof(proof, utxoType)) revert Errors.InvalidProof(proof);

        tree.updateNullifiers(token, publicSignals.inputNullifiers);
        // update original root to history roots before insert new commitment
        tree.updateHistoryRoot(publicSignals.root);
        tree.insertCommitments(token, publicSignals.outputCommitments);
        // TODO: emit a event for whole info
        emit Events.NewRoot(token, tree.incrementalTreeData.root);

        /* ========== core logic end ========== */

        // TODO: move to internal function _afterCreateTx
        /* ========== after core logic start ========== */

        if (publicSignals.publicOutAmt > 0) {
            if (publicInfo.recipient == address(0)) revert Errors.InvalidRecipientAddr();
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
        if (tree.incrementalTreeData.depth == 0) revert Errors.TokenTreeNotExists(token);

        PublicSignals calldata publicSignals = proof.publicSignals;

        // TODO: move to internal function _beforeCreateTx
        /* ========== before core logic start ========== */
        // check root is valid
        if (!tree.isValidRoot(publicSignals.root)) revert Errors.InvalidRoot(publicSignals.root);

        token.handleTransferFrom(msg.sender, publicSignals.publicInAmt);

        Helper.requireValidPublicInfo(publicInfo, publicSignals.publicInfoHash);
        bytes2 utxoType = Helper.calcUtxoType(
            publicSignals.inputNullifiers.length,
            publicSignals.outputCommitments.length
        );

        /* ========== before core logic end ========== */

        // TODO: move to internal function _createTx
        /* ========== core logic start ========== */
        if (!cipherVerifier.verifyProof(proof, utxoType)) revert Errors.InvalidProof(proof);

        tree.updateNullifiers(token, publicSignals.inputNullifiers);
        // update original root to history roots before insert new commitment
        tree.updateHistoryRoot(publicSignals.root);
        tree.insertCommitments(token, publicSignals.outputCommitments);
        // TODO: emit a event for whole info
        emit Events.NewRoot(token, tree.incrementalTreeData.root);

        /* ========== core logic end ========== */

        // TODO: move to internal function _afterCreateTx
        /* ========== after core logic start ========== */
        // TODO: check position of this line
        if (publicInfo.maxAllowableFeeRate > Constants.FEE_BASE)
            revert Errors.InvalidMaxAllowableFeeRate(publicInfo.maxAllowableFeeRate);
        if (relayerInfo.feeRate > publicInfo.maxAllowableFeeRate)
            revert Errors.InvalidRelayerFeeRate(relayerInfo.feeRate, publicInfo.maxAllowableFeeRate);

        if (publicSignals.publicOutAmt > 0) {
            if (publicInfo.recipient == address(0)) revert Errors.InvalidRecipientAddr();
            uint256 feeAmt = (publicSignals.publicOutAmt * relayerInfo.feeRate) / Constants.FEE_BASE;
            token.handleTransfer(publicInfo.recipient, publicSignals.publicOutAmt - feeAmt);
            token.handleTransfer(relayerInfo.feeReceiver, feeAmt);
            emit Events.RelayInfo(msg.sender, relayerInfo, feeAmt);
        }
        /* ========== after core logic end ========== */
    }

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        Relayer External function
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    // TODO: not completed
    function registerAsRelayer(string memory relayerMetadataUri) external {
        relayerMetadataUris[msg.sender] = relayerMetadataUri;
        emit Events.NewRelayer(msg.sender, relayerMetadataUri);
    }

    function updateRelayerMetadataUri(string memory newRelayerMetadataUri) external {
        relayerMetadataUris[msg.sender] = newRelayerMetadataUri;
        emit Events.RelayerUpdated(msg.sender, newRelayerMetadataUri);
    }

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        View function
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
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
        return treeData[token].isValidRoot(root);
    }

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        Internal function
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    function _initTokenTree(IERC20 token) internal {
        TreeData storage tree = treeData[token];
        if (tree.incrementalTreeData.depth != 0) revert Errors.TokenTreeAlreadyInitialized(token);

        // NOTE: reference railgun's implementation
        uint256 zeroValue = uint256(keccak256(abi.encode(token))) % Constants.SNARK_SCALAR_FIELD;
        tree.incrementalTreeData.init(Constants.DEFAULT_TREE_DEPTH, zeroValue);
        emit Events.NewTokenTree(token, Constants.DEFAULT_TREE_DEPTH, zeroValue);
    }

    // function _beforeCreateTx(UtxoData memory utxoData, PublicInfo memory publicInfo) internal virtual {}
}
