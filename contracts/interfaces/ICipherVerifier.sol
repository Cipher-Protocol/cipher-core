// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Proof} from "../utils/DataType.sol";

interface ICipherVerifier {
    function verifyProof(
        Proof calldata proof,
        bytes2 utxoType // utxoType for dynamic publicSignals size
    ) external returns (bool);
}
