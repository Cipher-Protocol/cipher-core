// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IncrementalTreeData} from "@zk-kit/incremental-merkle-tree.sol/IncrementalBinaryTree.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IVerifier} from "./interfaces/IVerifier.sol";

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
    uint16 fee;
    uint240 numOfTx;
    string url;
}

contract CipherStorage {
    address internal constant DEFAULT_ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    uint256 internal constant DEFAULT_TREE_DEPTH = 5;

    uint256 internal constant SNARK_SCALAR_FIELD =
        21888242871839275222246405745257275088548364400416034343698204186575808495617;

    uint16 internal constant FEE_BASE = 10000;

    uint8 internal constant VALID_HISTORY_ROOTS_SIZE = 32;

    IVerifier internal immutable verifier;

    // transfered amount * fee / FEE_BASE = fee amount
    // i.e. 1000 * 300 / 10000 = 30 (3% fee)
    uint16 internal fee;

    mapping(IERC20 => TreeData) internal treeData;

    mapping(address => RelayerInfo) internal relayers;

    constructor(address verifierAddr) {
        verifier = IVerifier(verifierAddr);
    }
}
