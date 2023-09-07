// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IncrementalBinaryTree} from "@zk-kit/incremental-merkle-tree.sol/IncrementalBinaryTree.sol";
import {UtxoStorage} from "./UtxoStorage.sol";
import {IVerifier} from "./interfaces/IVerifier.sol";

contract Utxo is UtxoStorage {
    struct ExtData {
        address recipient;
        int256 extAmount;
        address relayer;
        uint256 fee;
        bytes encryptedOutput1;
        bytes encryptedOutput2;
    }

    struct UtxoData {
        Proof proof;
        bytes32 root;
        bytes32[] inputNullifiers;
        bytes32[] outputCommitments;
        uint256 publicInAmt;
        uint256 publicOutAmt;
        bytes32 extDataHash;
    }

    struct Proof {
        uint256[2] a;
        uint256[2][2] b;
        uint256[2] c;
        uint256[6] publicInputs;
    }

    function verify(address verifierAddr, Proof memory proof) external {
        IVerifier verifier = IVerifier(verifierAddr);
        require(verifier.verifyProof(proof.a, proof.b, proof.c, proof.publicInputs), "Invalid proof");
    }
}
