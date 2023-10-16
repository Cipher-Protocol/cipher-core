// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseTest} from "../Base_Test.sol";
import {TestDataFile} from "../utils/loadTestdata.sol";

import {Proof, PublicInfo, PublicSignals} from "../../contracts/DataType.sol";

contract IntegrationCipherMultipleTxs is BaseTest, TestDataFile {
    function test_0_n0m1_n1m4_n4m1_n1m2_n2m0() external {
        Proof memory proof;
        PublicInfo memory info;
        PublicSignals memory signal;

        // tx 0
        (proof, info, signal) = loadTestdata("multipleTxs/0_n0m1_n1m4_n4m1_n1m2_n2m0.json", "0");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 1
        (proof, info, signal) = loadTestdata("multipleTxs/0_n0m1_n1m4_n4m1_n1m2_n2m0.json", "1");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 2
        (proof, info, signal) = loadTestdata("multipleTxs/0_n0m1_n1m4_n4m1_n1m2_n2m0.json", "2");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 3
        (proof, info, signal) = loadTestdata("multipleTxs/0_n0m1_n1m4_n4m1_n1m2_n2m0.json", "3");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 4
        (proof, info, signal) = loadTestdata("multipleTxs/0_n0m1_n1m4_n4m1_n1m2_n2m0.json", "4");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
    }

    function test_1_n0m4_n4m4_n4m1_n1m1_n1m2_n2m1_n1m0() external {
        Proof memory proof;
        PublicInfo memory info;
        PublicSignals memory signal;

        // tx 0
        (proof, info, signal) = loadTestdata("multipleTxs/1_n0m4_n4m4_n4m1_n1m1_n1m2_n2m1_n1m0.json", "0");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 1
        (proof, info, signal) = loadTestdata("multipleTxs/1_n0m4_n4m4_n4m1_n1m1_n1m2_n2m1_n1m0.json", "1");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 2
        (proof, info, signal) = loadTestdata("multipleTxs/1_n0m4_n4m4_n4m1_n1m1_n1m2_n2m1_n1m0.json", "2");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 3
        (proof, info, signal) = loadTestdata("multipleTxs/1_n0m4_n4m4_n4m1_n1m1_n1m2_n2m1_n1m0.json", "3");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 4
        (proof, info, signal) = loadTestdata("multipleTxs/1_n0m4_n4m4_n4m1_n1m1_n1m2_n2m1_n1m0.json", "4");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 5
        (proof, info, signal) = loadTestdata("multipleTxs/1_n0m4_n4m4_n4m1_n1m1_n1m2_n2m1_n1m0.json", "5");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 6
        (proof, info, signal) = loadTestdata("multipleTxs/1_n0m4_n4m4_n4m1_n1m1_n1m2_n2m1_n1m0.json", "6");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
    }
}
