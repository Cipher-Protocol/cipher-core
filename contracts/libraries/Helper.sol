// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Constants} from "./Constants.sol";
import {Errors} from "./Errors.sol";
import {PublicInfo} from "../utils/DataType.sol";

library Helper {
    /// @notice Calculate the utxo type
    /// @dev The utxo type is a 2-byte value that represents the number of input nullifiers and output commitments
    ///      The first byte represents the number of input nullifiers
    ///      The second byte represents the number of output commitments
    /// @param inputNullifierNum The number of input nullifiers
    /// @param outputCommitmentNum The number of output commitments
    /// @return utxoType The utxo type
    function calcUtxoType(uint256 inputNullifierNum, uint256 outputCommitmentNum) internal pure returns (bytes2) {
        if (inputNullifierNum > Constants.NUM_OF_ONE_BYTES) revert Errors.InvalidNullifierNum(inputNullifierNum);
        if (outputCommitmentNum > Constants.NUM_OF_ONE_BYTES) revert Errors.InvalidCommitmentNum(outputCommitmentNum);
        return bytes2(uint16((inputNullifierNum << 8) | outputCommitmentNum));
    }

    /// @notice Calculate the public info hash
    /// @dev The calculated public info hash should be equal to the `publicInfoHash` in the proof,
    ///      that ensures it is consistent with the parameters entered in the circuit
    /// @param publicInfo The public info struct
    /// @return publicInfoHash The public info hash
    function calcPublicInfoHash(PublicInfo memory publicInfo) internal pure returns (uint256) {
        return uint256(keccak256(abi.encode(publicInfo))) % Constants.SNARK_SCALAR_FIELD;
    }
}
