// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {BaseTest} from "./Base_Test.sol";
import {IPoseidonT3} from "../contracts/interfaces/IPoseidonT3.sol";
import {CipherVerifier} from "../contracts/CipherVerifier.sol";
import {Cipher} from "../contracts/Cipher.sol";
import {DEFAULT_NATIVE_TOKEN_ADDRESS, DEFAULT_NATIVE_TOKEN, DEFAULT_TREE_DEPTH, SNARK_FIELD_SIZE, DEFAULT_LEAF_ZERO_VALUE} from "./utils.sol";

contract DeployTest is BaseTest {
    function testTreeDepth() external {
        assertEq(main.getTreeDepth(DEFAULT_NATIVE_TOKEN), DEFAULT_TREE_DEPTH);
    }

    function testTreeRoot() external {
        uint256 zero = DEFAULT_LEAF_ZERO_VALUE;
        for (uint256 i = 0; i < DEFAULT_TREE_DEPTH; i++) {
            zero = IPoseidonT3(poseidonT3).poseidon([zero, zero]);
        }
        assertEq(zero, main.getTreeRoot(DEFAULT_NATIVE_TOKEN));
        assertEq(0, main.getTreeLeafNum(DEFAULT_NATIVE_TOKEN));
    }
}
