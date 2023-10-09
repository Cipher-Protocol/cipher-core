// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Constants} from "./Constants.sol";
import {Errors} from "./Errors.sol";
import {PublicInfo} from "../utils/DataType.sol";

library Helper {
    function calcUtxoType(uint256 inputNullifierNum, uint256 outputCommitmentNum) internal pure returns (bytes2) {
        if (inputNullifierNum > Constants.NUM_OF_ONE_BYTES) revert Errors.InvalidNullifierNum(inputNullifierNum);
        if (outputCommitmentNum > Constants.NUM_OF_ONE_BYTES) revert Errors.InvalidCommitmentNum(outputCommitmentNum);
        return bytes2(uint16((inputNullifierNum << 8) | outputCommitmentNum));
    }

    function requireValidUtxoType(bytes2 utxoType, uint256 nullifierNum, uint256 commitmentNum) internal pure {
        // The first byte of utxoType should be equal to nullifierNum &&
        // The second byte of utxoType should be equal to commitmentNum
        if (uint8(utxoType[0]) != nullifierNum || uint8(utxoType[1]) != commitmentNum)
            revert Errors.InvalidUtxoType(utxoType, nullifierNum, commitmentNum);
    }

    function requireValidPublicInfo(PublicInfo memory publicInfo, uint256 publicInfoHash) internal pure {
        uint256 calcPublicInfoHash = uint256(keccak256(abi.encode(publicInfo))) % Constants.SNARK_SCALAR_FIELD;
        if (publicInfoHash != calcPublicInfoHash) revert Errors.InvalidPublicInfo(publicInfoHash, calcPublicInfoHash);
    }
}
