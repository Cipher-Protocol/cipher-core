// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IncrementalTreeData} from "@zk-kit/incremental-merkle-tree.sol/IncrementalBinaryTree.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ICipherVerifier} from "./interfaces/ICipherVerifier.sol";

struct TreeData {
    IncrementalTreeData incrementalTreeData;
    /// @notice The index of the latest root in history roots
    uint8 historyRootsIdx;
    /// @notice History roots (The 32 valid roots before the latest root)
    /// @notice To avoid others updating the root when user calculating the proof in client side
    uint256[32] historyRoots;
    mapping(uint256 => bool) nullifiers;
}

struct RelayerInfo {
    uint16 feeRate;
    uint240 numOfTx;
    string url;
}

struct Proof {
    uint256[2] a;
    uint256[2][2] b;
    uint256[2] c;
    PublicSignals publicSignals;
}

struct PublicSignals {
    uint256 root;
    uint256 publicInAmt;
    uint256 publicOutAmt;
    uint256 publicInfoHash;
    uint256[] inputNullifiers;
    uint256[] outputCommitments;
}

struct PublicInfo {
    bytes2 utxoType;
    uint16 feeRate;
    address payable relayer;
    address payable recipient;
    bytes encodedData; // NOTE: abi.encode([tokenAddress, ...])
}

contract CipherStorage {
    ICipherVerifier internal immutable cipherVerifier;

    // transfered amount * fee / FEE_BASE = fee amount
    // i.e. 1000 * 300 / 10000 = 30 (3% fee)
    uint16 internal fee;

    mapping(IERC20 => TreeData) internal treeData;

    mapping(address => RelayerInfo) internal relayers;

    constructor(address cipherVerifierAddr) {
        cipherVerifier = ICipherVerifier(cipherVerifierAddr);
    }
}
