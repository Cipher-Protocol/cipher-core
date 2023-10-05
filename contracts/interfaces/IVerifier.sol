// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

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

interface IVerifier {
    function verifyProof(
        // uint256[2] calldata _pA,
        // uint256[2][2] calldata _pB,
        // uint256[2] calldata _pC,
        // uint256[] calldata _pubSignals, // remove fixed size
        Proof calldata proof,
        bytes2 utxoType // _type for dynamic _pubSignals size
    ) external returns (bool);
}
