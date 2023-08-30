// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IncrementalBinaryTree} from "@zk-kit/incremental-merkle-tree.sol/IncrementalBinaryTree.sol";
import {UtxoStorage} from "./UtxoStorage.sol";

contract Utxo is UtxoStorage {
    struct ExtData {
        address recipient;
        int256 extAmount;
        address relayer;
        uint256 fee;
        bytes encryptedOutput1;
        bytes encryptedOutput2;
    }

    struct Proof {
        bytes proof;
        bytes32 root;
        bytes32[] inputNullifiers;
        bytes32[] outputCommitments;
        uint256 publicInAmt;
        uint256 publicOutAmt;
        bytes32 extDataHash;
    }
}
