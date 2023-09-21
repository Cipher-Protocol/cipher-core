// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IVerifier {
    function verifyProof(
        uint256[2] calldata _pA,
        uint256[2][2] calldata _pB,
        uint256[2] calldata _pC,
        uint256[] calldata _pubSignals, // remove fixed size
        bytes2 _type // _type for dynamic _pubSignals size
    ) external returns (bool);
}
