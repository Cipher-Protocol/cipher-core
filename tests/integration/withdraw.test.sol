// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseTest} from "../Base_Test.sol";
import {TestDataFile} from "../utils/loadTestdata.sol";

import {Proof, PublicInfo, PublicSignals} from "../../contracts/DataType.sol";

contract IntegrationCipherWithdraw is BaseTest, TestDataFile {
    function test_0_n0m1_n1m0() external {
        Proof memory proof;
        PublicInfo memory info;
        PublicSignals memory signal;

        // tx 0
        (proof, info, signal) = loadTestdata("withdraw/0_n0m1_n1m0.json", "0");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 1
        (proof, info, signal) = loadTestdata("withdraw/0_n0m1_n1m0.json", "1");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
    }

    function test_1_n0m1_n1m1() external {
        Proof memory proof;
        PublicInfo memory info;
        PublicSignals memory signal;

        // tx 0
        (proof, info, signal) = loadTestdata("withdraw/1_n0m1_n1m1.json", "0");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 1
        (proof, info, signal) = loadTestdata("withdraw/1_n0m1_n1m1.json", "1");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
    }

    function test_2_n0m2_n2m0() external {
        Proof memory proof;
        PublicInfo memory info;
        PublicSignals memory signal;

        // tx 0
        (proof, info, signal) = loadTestdata("withdraw/2_n0m2_n2m0.json", "0");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 1
        (proof, info, signal) = loadTestdata("withdraw/2_n0m2_n2m0.json", "1");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
    }

    function test_3_n0m2_n2m1() external {
        Proof memory proof;
        PublicInfo memory info;
        PublicSignals memory signal;

        // tx 0
        (proof, info, signal) = loadTestdata("withdraw/3_n0m2_n2m1.json", "0");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 1
        (proof, info, signal) = loadTestdata("withdraw/3_n0m2_n2m1.json", "1");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
    }

    function test_4_n0m4_n4m0() external {
        Proof memory proof;
        PublicInfo memory info;
        PublicSignals memory signal;

        // tx 0
        (proof, info, signal) = loadTestdata("withdraw/4_n0m4_n4m0.json", "0");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 1
        (proof, info, signal) = loadTestdata("withdraw/4_n0m4_n4m0.json", "1");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
    }

    function test_5_n0m4_n4m1() external {
        Proof memory proof;
        PublicInfo memory info;
        PublicSignals memory signal;

        // tx 0
        (proof, info, signal) = loadTestdata("withdraw/5_n0m4_n4m1.json", "0");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 1
        (proof, info, signal) = loadTestdata("withdraw/5_n0m4_n4m1.json", "1");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
    }
}
