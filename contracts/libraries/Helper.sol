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

    function calcPublicInfoHash(PublicInfo memory publicInfo) internal pure returns (uint256) {
        return uint256(keccak256(abi.encode(publicInfo))) % Constants.SNARK_SCALAR_FIELD;
    }
}
