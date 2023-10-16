// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseTest} from "../Base_Test.sol";
import {TestDataFile} from "../utils/loadTestdata.sol";

import {Proof, PublicInfo, PublicSignals} from "../../contracts/DataType.sol";

contract IntegrationCipherTripleTxs is BaseTest, TestDataFile {
    function test_0_n0m1_n1m2_n2m4() external {
        Proof memory proof;
        PublicInfo memory info;
        PublicSignals memory signal;

        // tx 0
        (proof, info, signal) = loadTestdata("tripleTxs/0_n0m1_n1m2_n2m4.json", "0");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 1
        (proof, info, signal) = loadTestdata("tripleTxs/0_n0m1_n1m2_n2m4.json", "1");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 2
        (proof, info, signal) = loadTestdata("tripleTxs/0_n0m1_n1m2_n2m4.json", "2");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
    }


    function test_1_n0m2_n2m4_n4m4() external {
        Proof memory proof;
        PublicInfo memory info;
        PublicSignals memory signal;

        // tx 0
        (proof, info, signal) = loadTestdata("tripleTxs/1_n0m2_n2m4_n4m4.json", "0");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 1
        (proof, info, signal) = loadTestdata("tripleTxs/1_n0m2_n2m4_n4m4.json", "1");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 2
        (proof, info, signal) = loadTestdata("tripleTxs/1_n0m2_n2m4_n4m4.json", "2");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
    }


    function test_2_n0m2_n2m1_n1m4() external {
        Proof memory proof;
        PublicInfo memory info;
        PublicSignals memory signal;

        // tx 0
        (proof, info, signal) = loadTestdata("tripleTxs/2_n0m2_n2m1_n1m4.json", "0");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 1
        (proof, info, signal) = loadTestdata("tripleTxs/2_n0m2_n2m1_n1m4.json", "1");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
        // tx 2
        (proof, info, signal) = loadTestdata("tripleTxs/2_n0m2_n2m1_n1m4.json", "2");
        main.cipherTransact{value: signal.publicInAmt}(proof, info);
    }
}
