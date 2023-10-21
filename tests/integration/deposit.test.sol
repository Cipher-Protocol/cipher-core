// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {BaseTest} from "../Base_Test.sol";
import {TestDataFile} from "../utils/loadTestdata.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Proof, PublicInfo, PublicSignals} from "../../contracts/DataType.sol";

contract IntegrationCipherDeposit is BaseTest, TestDataFile {
    function test_0_n0m1() external {
        (Proof memory proof, PublicInfo memory info, PublicSignals memory signal) = loadTestdata("deposit/0_n0m1.json", "0");
        { // avoid stack too deep
            main.cipherTransact{value: signal.publicInAmt}(proof, info);
        }
    }

    function test_1_n0m2() external {
        (Proof memory proof, PublicInfo memory info, PublicSignals memory signal) = loadTestdata("deposit/1_n0m2.json", "0");
        { // avoid stack too deep
            main.cipherTransact{value: signal.publicInAmt}(proof, info);
        }
    }

    function test_2_n0m4() external {
        (Proof memory proof, PublicInfo memory info, PublicSignals memory signal) = loadTestdata("deposit/2_n0m4.json", "0");
        { // avoid stack too deep
            main.cipherTransact{value: signal.publicInAmt}(proof, info);
        }
    }
}
