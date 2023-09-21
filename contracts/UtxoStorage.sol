// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IncrementalTreeData} from "@zk-kit/incremental-merkle-tree.sol/IncrementalBinaryTree.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IVerifier} from "./interfaces/IVerifier.sol";

struct TreeData {
    IncrementalTreeData incrementalTreeData;
    mapping(uint256 => bool) nullifiers;
}

struct RelayerInfo {
    uint16 fee;
    uint240 numOfTx;
    string url;
}

abstract contract UtxoStorage {
    address internal constant DEFAULT_ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    uint256 internal constant DEFAULT_TREE_DEPTH = 20;

    uint256 internal constant SNARK_SCALAR_FIELD =
        21888242871839275222246405745257275088548364400416034343698204186575808495617;

    uint16 internal constant FEE_BASE = 10000;

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
