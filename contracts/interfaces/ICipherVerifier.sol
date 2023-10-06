// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Proof} from "../CipherStorage.sol";

interface ICipherVerifier {
    function verifyProof(
        Proof calldata proof,
        bytes2 utxoType // utxoType for dynamic publicSignals size
    ) external returns (bool);
}
