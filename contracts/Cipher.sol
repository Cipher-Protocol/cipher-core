// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// intefaces
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ICipher} from "./interfaces/ICipher.sol";
import {ICipherVerifier} from "./interfaces/ICipherVerifier.sol";
import {IPoseidonT3} from "./interfaces/IPoseidonT3.sol";

// libraries
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {IncrementalBinaryTree, IncrementalTreeData} from "@zk-kit/incremental-merkle-tree.sol/IncrementalBinaryTree.sol";
import {Constants} from "./libraries/Constants.sol";
import {Errors} from "./libraries/Errors.sol";
import {Events} from "./libraries/Events.sol";
import {Helper} from "./libraries/Helper.sol";
import {TokenLib} from "./libraries/TokenLib.sol";
import {TreeData, TreeLib} from "./libraries/TreeLib.sol";
import {Proof, PublicInfo, PublicSignals, RelayerInfo} from "./utils/DataType.sol";

import "hardhat/console.sol";

contract Cipher is ICipher {
    using IncrementalBinaryTree for IncrementalTreeData;
    using Strings for string;
    using Math for uint256;
    using TreeLib for TreeData;
    using TokenLib for IERC20;

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        Immutable
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    ICipherVerifier internal immutable cipherVerifier;
    IPoseidonT3 internal immutable poseidonT3;

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        Storage
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    mapping(IERC20 => TreeData) internal treeData;
    mapping(address => string) internal relayerMetadataUris;

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        Constructor
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    constructor(address verifierAddr, address poseidonT3Addr) {
        cipherVerifier = ICipherVerifier(verifierAddr);
        poseidonT3 = IPoseidonT3(poseidonT3Addr);
        _initTokenTree(Constants.DEFAULT_NATIVE_TOKEN);
    }

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        User-facing external function
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    /// @inheritdoc ICipher
    function initTokenTree(IERC20 token) external {
        _initTokenTree(token);
    }

    /// @inheritdoc ICipher
    function cipherTransact(Proof calldata proof, PublicInfo calldata publicInfo) external payable {
        IERC20 token = publicInfo.token;
        PublicSignals calldata publicSignals = proof.publicSignals;
        _cipherTransact(token, proof, publicInfo, publicSignals);
        if (publicSignals.publicOutAmt > 0) _selfWithdraw(token, publicInfo, publicSignals);
    }

    /// @inheritdoc ICipher
    function cipherTransactWithRelayer(
        Proof calldata proof,
        PublicInfo calldata publicInfo,
        RelayerInfo calldata relayerInfo
    ) external payable {
        _checkFeeAndRelayerInfo(publicInfo.maxAllowableFeeRate, relayerInfo);
        IERC20 token = publicInfo.token;
        PublicSignals calldata publicSignals = proof.publicSignals;
        _cipherTransact(token, proof, publicInfo, publicSignals);
        if (publicSignals.publicOutAmt > 0) _withdrawWithRelayer(token, publicInfo, publicSignals, relayerInfo);
    }

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        Relayer External function
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    // TODO: not completed
    /// @inheritdoc ICipher
    function registerAsRelayer(string memory relayerMetadataUri) external {
        relayerMetadataUris[msg.sender] = relayerMetadataUri;
        emit Events.NewRelayer(msg.sender, relayerMetadataUri);
    }

    /// @inheritdoc ICipher
    function updateRelayerMetadataUri(string memory newRelayerMetadataUri) external {
        relayerMetadataUris[msg.sender] = newRelayerMetadataUri;
        emit Events.RelayerUpdated(msg.sender, newRelayerMetadataUri);
    }

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        View function
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    // /// @inheritdoc ICipher
    // function getTreeDepth(IERC20 token) external view returns (uint256) {
    //     return treeData[token].depth;
    // }

    /// @inheritdoc ICipher
    function getTreeRoot(IERC20 token) external view returns (uint256) {
        return treeData[token].root;
    }

    /// @inheritdoc ICipher
    function getTreeLeafNum(IERC20 token) external view returns (uint256) {
        return treeData[token].numberOfLeaves;
    }

    // /// @inheritdoc ICipher
    // function getTreeZeroes(IERC20 token, uint256 level) external view returns (uint256) {
    //     return treeData[token].incrementalTreeData.zeroes[level];
    // }

    /// @inheritdoc ICipher
    function getTreeLastSubtrees(IERC20 token, uint256 level) external view returns (uint256[2] memory) {
        return treeData[token].lastSubtrees[level];
    }

    /// @inheritdoc ICipher
    function getRelayerMetadataUri(address relayerAddr) external view returns (string memory) {
        return relayerMetadataUris[relayerAddr];
    }

    /// @inheritdoc ICipher
    function getVerifier() external view returns (ICipherVerifier) {
        return cipherVerifier;
    }

    /// @inheritdoc ICipher
    function isNullified(IERC20 token, uint256 nullifier) external view returns (bool) {
        return treeData[token].nullifiers[nullifier];
    }

    /// @inheritdoc ICipher
    function isValidRoot(IERC20 token, uint256 root) external view returns (bool) {
        return treeData[token].isValidRoot(root);
    }

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        Internal function
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    function _initTokenTree(IERC20 token) internal {
        TreeData storage tree = treeData[token];
        if (tree.root != 0) revert Errors.TokenTreeAlreadyInitialized(token);

        // // NOTE: reference railgun's implementation
        // uint256 zeroValue = uint256(keccak256(abi.encode(token))) % Constants.SNARK_SCALAR_FIELD;
        tree.init();
        emit Events.NewTokenTree(token);
    }

    function _cipherTransact(
        IERC20 token,
        Proof calldata proof,
        PublicInfo calldata publicInfo,
        PublicSignals calldata publicSignals
    ) internal {
        /* ======== check public info ======== */
        // solhint-disable-next-line not-rely-on-time
        if (publicInfo.deadline < block.timestamp) revert Errors.ExpiredDeadline(publicInfo.deadline);
        uint256 calcPublicInfoHash = Helper.calcPublicInfoHash(publicInfo);
        if (publicSignals.publicInfoHash != calcPublicInfoHash)
            revert Errors.InvalidPublicInfo(publicSignals.publicInfoHash, calcPublicInfoHash);

        /* ======== check with token tree state ======== */
        TreeData storage tree = treeData[token];
        if (tree.root == 0) revert Errors.TokenTreeNotExists(token);
        if (!tree.isValidRoot(publicSignals.root)) revert Errors.InvalidRoot(publicSignals.root);

        /* ======== transfer token in ======== */
        if (publicSignals.publicInAmt > 0) {
            token.tokenTransferFrom(msg.sender, publicSignals.publicInAmt);
        } else {
            // if publicInAmt is 0, msg.value should equal to 0
            if (msg.value != 0) revert Errors.InvalidMsgValue(msg.value);
        }

        /* ======== verify proof ======== */
        uint256 inputNullifierLen = publicSignals.inputNullifiers.length;
        uint256 outputCommitmentLen = publicSignals.outputCommitments.length;
        bytes2 utxoType = Helper.calcUtxoType(inputNullifierLen, outputCommitmentLen);
        if (!cipherVerifier.verifyProof(proof, utxoType)) revert Errors.InvalidProof(proof);

        /* ======== update token tree state ======== */
        if (inputNullifierLen > 0) tree.updateNullifiers(token, publicSignals.inputNullifiers, inputNullifierLen);
        if (outputCommitmentLen > 0) {
            // update original root to history roots before insert new commitment
            tree.updateHistoryRoot(publicSignals.root);
            tree.insertCommitments(token, poseidonT3, publicSignals.outputCommitments, outputCommitmentLen);
            // TODO: emit a event for whole info
            emit Events.NewRoot(token, tree.root);
        }
    }

    function _checkFeeAndRelayerInfo(uint16 maxAllowableFeeRate, RelayerInfo calldata relayerInfo) internal view {
        // TODO: check position of this line
        if (maxAllowableFeeRate > Constants.FEE_BASE) revert Errors.InvalidMaxAllowableFeeRate(maxAllowableFeeRate);

        if (relayerInfo.feeRate > maxAllowableFeeRate)
            revert Errors.InvalidRelayerFeeRate(relayerInfo.feeRate, maxAllowableFeeRate);

        if (relayerInfo.feeReceiver == address(0)) revert Errors.InvalidFeeReceiverAddr();

        if (relayerMetadataUris[relayerInfo.registeredAddr].equal(""))
            revert Errors.NotRegisteredRelayer(relayerInfo.registeredAddr);
    }

    function _selfWithdraw(
        IERC20 token,
        PublicInfo calldata publicInfo,
        PublicSignals calldata publicSignals
    ) internal {
        if (publicInfo.recipient == address(0)) revert Errors.InvalidRecipientAddr();

        token.tokenTransfer(publicInfo.recipient, publicSignals.publicOutAmt);
    }

    function _withdrawWithRelayer(
        IERC20 token,
        PublicInfo calldata publicInfo,
        PublicSignals calldata publicSignals,
        RelayerInfo calldata relayerInfo
    ) internal {
        if (publicInfo.recipient == address(0)) revert Errors.InvalidRecipientAddr();

        // checked relayerInfo.feeRate <= publicInfo.maxAllowableFeeRate <= Constants.FEE_BASE in `_checkFeeAndRelayerInfo`
        uint256 feeAmt = publicSignals.publicOutAmt.mulDiv(relayerInfo.feeRate, Constants.FEE_BASE);
        token.tokenTransfer(publicInfo.recipient, publicSignals.publicOutAmt - feeAmt);
        token.tokenTransfer(relayerInfo.feeReceiver, feeAmt);
        emit Events.RelayInfo(msg.sender, relayerInfo, feeAmt);
    }
}
