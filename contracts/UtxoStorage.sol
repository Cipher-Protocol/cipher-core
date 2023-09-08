// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IncrementalTreeData} from "@zk-kit/incremental-merkle-tree.sol/IncrementalBinaryTree.sol";
import {IVerifier} from "./interfaces/IVerifier.sol";

abstract contract UtxoStorage {
    address internal constant DEFAULT_ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    uint256 internal constant SNARK_SCALAR_FIELD =
        21888242871839275222246405745257275088548364400416034343698204186575808495617;

    IVerifier internal immutable _verifier;

    uint32 internal _totalLeaves;

    IncrementalTreeData internal _treeData;

    mapping(uint256 => bool) internal _nullifiers;

    constructor(address verifierAddr) {
        _verifier = IVerifier(verifierAddr);
    }
}
