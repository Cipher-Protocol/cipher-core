// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IncrementalBinaryTree, IncrementalTreeData} from "@zk-kit/incremental-merkle-tree.sol/IncrementalBinaryTree.sol";
import {CipherStorage, TreeData, RelayerInfo, Proof, PublicSignals, PublicInfo} from "./CipherStorage.sol";
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
    error InvalidFeeSetting(uint16 fee);
    error InvalidRoot(uint256 root);

    event NewTokenTree(IERC20 token, uint256 merkleTreeDepth, uint256 zeroValue);
    event NewRelayer(address relayer, uint16 fee, string url);

    constructor(address verifierAddr, uint16 _fee) CipherStorage(verifierAddr) {
        if (_fee > CipherConfig.FEE_BASE) revert InvalidFeeSetting(_fee);
        fee = _fee;
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
    function registerAsRelayer(uint16 feeRate, string memory url) external {
        relayers[msg.sender] = RelayerInfo({feeRate: feeRate, numOfTx: 0, url: url});
        emit NewRelayer(msg.sender, fee, url);
    }

    function createTx(Proof calldata proof, PublicInfo calldata publicInfo) external payable {
        IERC20 token = IERC20(_parseData(publicInfo.encodedData));
        TreeData storage tree = treeData[token];
        if (tree.incrementalTreeData.depth == 0) revert TokenTreeNotExists(token);

        PublicSignals calldata publicSignals = proof.publicSignals;

        // TODO: move to internal function _beforeCreateTx
        /* ========== before core logic start ========== */
        // check root is valid
        if (!publicSignals.root.isValidRoot(tree)) revert InvalidRoot(publicSignals.root);

        token.handleTransferFrom(msg.sender, publicSignals.publicInAmt);

        publicInfo.requireValidPublicInfo(publicSignals.publicInfoHash);
        // check utxoType(nAmB), n is the number of INPUT nullifiers, m is the number of OUTPUT commitments
        publicInfo.utxoType.requireValidUtxoType(
            publicSignals.inputNullifiers.length,
            publicSignals.outputCommitments.length
        );

        /* ========== before core logic end ========== */

        // TODO: move to internal function _createTx
        /* ========== core logic start ========== */

        if (
            // NOTE: publicSignals: root, publicInAmt, publicOutAmt, publicInfoHash, inputNullifier, outputCommitment
            // TODO: circuit public need add: token??
            // TODO: public data: need to from contract storage, Ex. root
            !cipherVerifier.verifyProof(proof, publicInfo.utxoType)
        ) revert InvalidProof(proof);

        tree.updateNullifiers(token, publicSignals.inputNullifiers);
        // update original root to history roots before insert new commitment
        tree.updateHistoryRoot(publicSignals.root);
        tree.insertCommitments(token, publicSignals.outputCommitments);

        /* ========== core logic end ========== */

        // TODO: move to internal function _afterCreateTx
        /* ========== after core logic start ========== */
        uint256 feeAmt;
        if (publicInfo.feeRate > 0) {
            feeAmt = (publicSignals.publicOutAmt * publicInfo.feeRate) / CipherConfig.FEE_BASE;
        } else {
            feeAmt = (publicSignals.publicOutAmt * fee) / CipherConfig.FEE_BASE;
        }

        if (publicSignals.publicOutAmt > 0) {
            if (publicInfo.recipient == address(0)) revert InvalidRecipientAddr();
            token.handleTransfer(publicInfo.recipient, publicSignals.publicOutAmt - feeAmt);
        }

        if (feeAmt > 0) token.handleTransfer(publicInfo.relayer, feeAmt);
        /* ========== after core logic end ========== */
    }

    function setFee(uint16 newFee) external onlyOwner {
        if (newFee > CipherConfig.FEE_BASE) revert InvalidFeeSetting(newFee);
        fee = newFee;
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

    function _parseData(bytes memory encodedData) internal pure virtual returns (address) {
        return abi.decode(encodedData, (address));
    }

    // function _beforeCreateTx(UtxoData memory utxoData, PublicInfo memory publicInfo) internal virtual {}
}
