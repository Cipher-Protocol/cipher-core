// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "../Base_Test.sol";

contract TestCipherConstructor is BaseTest {
    function testTreeDepth() external {
        assertEq(main.getTreeDepth(Constants.DEFAULT_NATIVE_TOKEN), Constants.DEFAULT_TREE_DEPTH);
    }

    function testTreeRoot() external {
        uint256 zero = Constants.DEFAULT_LEAF_ZERO_VALUE;
        for (uint256 i = 0; i < Constants.DEFAULT_TREE_DEPTH; i++) {
            zero = IPoseidonT3(poseidonT3).poseidon([zero, zero]);
        }
        assertEq(zero, main.getTreeRoot(Constants.DEFAULT_NATIVE_TOKEN));
        assertEq(0, main.getTreeLeafNum(Constants.DEFAULT_NATIVE_TOKEN));
    }
}
