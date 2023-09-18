// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IncrementalTreeData} from "@zk-kit/incremental-merkle-tree.sol/IncrementalBinaryTree.sol";
import {IVerifier} from "./interfaces/IVerifier.sol";

struct TreeData {
    IncrementalTreeData incrementalTreeData;
    mapping(uint256 => bool) nullifiers;
}

abstract contract UtxoStorage {
    type Currency is address;

    address internal constant DEFAULT_ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    uint256 internal constant SNARK_SCALAR_FIELD =
        21888242871839275222246405745257275088548364400416034343698204186575808495617;

    IVerifier internal immutable verifier;

    mapping(Currency => TreeData) internal treeData;

    constructor(address verifierAddr) {
        verifier = IVerifier(verifierAddr);
    }
}
