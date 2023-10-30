// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {BaseTest} from "../Base_Test.sol";
import {TestDataFile} from "../utils/loadTestdata.sol";

import {Proof, PublicInfo, PublicSignals} from "../../contracts/DataType.sol";

contract IntegrationCipherDoubleTxs is BaseTest, TestDataFile {
    function test_0_n0m1_n1m0() external {
        Proof memory proof;
        PublicInfo memory info;
        PublicSignals memory signal;

        // tx 0
        (proof, info, signal) = loadTestdata("doubleTxs/0_n0m1_n1m0.json", "0");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 1
        (proof, info, signal) = loadTestdata("doubleTxs/0_n0m1_n1m0.json", "1");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
    }

    function test_1_n0m1_n1m1() external {
        Proof memory proof;
        PublicInfo memory info;
        PublicSignals memory signal;

        // tx 0
        (proof, info, signal) = loadTestdata("doubleTxs/1_n0m1_n1m1.json", "0");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 1
        (proof, info, signal) = loadTestdata("doubleTxs/1_n0m1_n1m1.json", "1");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
    }

    function test_2_n0m1_n1m2() external {
        Proof memory proof;
        PublicInfo memory info;
        PublicSignals memory signal;

        // tx 0
        (proof, info, signal) = loadTestdata("doubleTxs/2_n0m1_n1m2.json", "0");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 1
        (proof, info, signal) = loadTestdata("doubleTxs/2_n0m1_n1m2.json", "1");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
    }

    function test_3_n0m1_n1m4() external {
        Proof memory proof;
        PublicInfo memory info;
        PublicSignals memory signal;

        // tx 0
        (proof, info, signal) = loadTestdata("doubleTxs/3_n0m1_n1m4.json", "0");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 1
        (proof, info, signal) = loadTestdata("doubleTxs/3_n0m1_n1m4.json", "1");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
    }

    function test_4_n0m2_n2m0() external {
        Proof memory proof;
        PublicInfo memory info;
        PublicSignals memory signal;

        // tx 0
        (proof, info, signal) = loadTestdata("doubleTxs/4_n0m2_n2m0.json", "0");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 1
        (proof, info, signal) = loadTestdata("doubleTxs/4_n0m2_n2m0.json", "1");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
    }

    function test_5_n0m2_n2m1() external {
        Proof memory proof;
        PublicInfo memory info;
        PublicSignals memory signal;

        // tx 0
        (proof, info, signal) = loadTestdata("doubleTxs/5_n0m2_n2m1.json", "0");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 1
        (proof, info, signal) = loadTestdata("doubleTxs/5_n0m2_n2m1.json", "1");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
    }

    function test_6_n0m2_n2m2() external {
        Proof memory proof;
        PublicInfo memory info;
        PublicSignals memory signal;

        // tx 0
        (proof, info, signal) = loadTestdata("doubleTxs/6_n0m2_n2m2.json", "0");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 1
        (proof, info, signal) = loadTestdata("doubleTxs/6_n0m2_n2m2.json", "1");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
    }

    function test_7_n0m2_n2m4() external {
        Proof memory proof;
        PublicInfo memory info;
        PublicSignals memory signal;

        // tx 0
        (proof, info, signal) = loadTestdata("doubleTxs/7_n0m2_n2m4.json", "0");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 1
        (proof, info, signal) = loadTestdata("doubleTxs/7_n0m2_n2m4.json", "1");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
    }

    function test_8_n0m4_n4m0() external {
        Proof memory proof;
        PublicInfo memory info;
        PublicSignals memory signal;

        // tx 0
        (proof, info, signal) = loadTestdata("doubleTxs/8_n0m4_n4m0.json", "0");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 1
        (proof, info, signal) = loadTestdata("doubleTxs/8_n0m4_n4m0.json", "1");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
    }

    function test_9_n0m4_n4m1() external {
        Proof memory proof;
        PublicInfo memory info;
        PublicSignals memory signal;

        // tx 0
        (proof, info, signal) = loadTestdata("doubleTxs/9_n0m4_n4m1.json", "0");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 1
        (proof, info, signal) = loadTestdata("doubleTxs/9_n0m4_n4m1.json", "1");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
    }

    function test_10_n0m4_n4m2() external {
        Proof memory proof;
        PublicInfo memory info;
        PublicSignals memory signal;

        // tx 0
        (proof, info, signal) = loadTestdata("doubleTxs/10_n0m4_n4m2.json", "0");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 1
        (proof, info, signal) = loadTestdata("doubleTxs/10_n0m4_n4m2.json", "1");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
    }

    function test_11_n0m4_n4m4() external {
        Proof memory proof;
        PublicInfo memory info;
        PublicSignals memory signal;

        // tx 0
        (proof, info, signal) = loadTestdata("doubleTxs/11_n0m4_n4m4.json", "0");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 1
        (proof, info, signal) = loadTestdata("doubleTxs/11_n0m4_n4m4.json", "1");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
    }
}
