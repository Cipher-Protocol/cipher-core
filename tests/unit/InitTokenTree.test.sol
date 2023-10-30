// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "../Base_Test.sol";

contract TestCipherInitTokenTree is BaseTest {
    function testInitTokenTree() external {
        uint256 treeDepth = Constants.DEFAULT_TREE_DEPTH;
        uint256 defaultLeafZeroValue = Constants.DEFAULT_LEAF_ZERO_VALUE;

        // init token tree
        // - emit `NewTokenTree` event
        // - check tree depth
        vm.expectEmit(true, true, true, true);
        emit Events.NewTokenTree(erc20, treeDepth, defaultLeafZeroValue, Constants.Z_24);
        main.initTokenTree(IERC20(erc20));
        assertEq(main.getTreeDepth(erc20), treeDepth);

        // tree root
        uint256 root = defaultLeafZeroValue;
        for (uint256 i = 0; i < treeDepth; i++) {
            root = IPoseidonT3(poseidonT3).poseidon([root, root]);
        }
        assertEq(main.getTreeRoot(erc20), root);
        assertEq(main.getTreeLeafNum(erc20), 0);
    }

    function testShouldFailedInitTokenTree() external {
        main.initTokenTree(IERC20(erc20));

        vm.expectRevert(abi.encodeWithSelector(Errors.TokenTreeAlreadyInitialized.selector, IERC20(erc20)));
        main.initTokenTree(IERC20(erc20));
    }
}
