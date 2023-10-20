// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {BaseTest} from "./Base_Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IPoseidonT3} from "../contracts/interfaces/IPoseidonT3.sol";
import {CipherVerifier} from "../contracts/CipherVerifier.sol";
import {Cipher} from "../contracts/Cipher.sol";
import {ERC20Mock} from "../contracts/mock/ERC20Mock.sol";
import {DEFAULT_NATIVE_TOKEN_ADDRESS, DEFAULT_NATIVE_TOKEN, DEFAULT_TREE_DEPTH, SNARK_FIELD_SIZE, Z_24, DEFAULT_LEAF_ZERO_VALUE} from "./utils.sol";

contract InitTokenTree is BaseTest {
    // TODO move event and error to another file
    event NewTokenTree(IERC20 indexed token, uint256 depth, uint256 zeroValue, uint256 root);

    // TODO move event and error to another file
    error TokenTreeAlreadyInitialized(IERC20);

    function testInitTokenTree() external {
        // init token tree
        // - emit `NewTokenTree` event
        // - check tree depth
        vm.expectEmit(true, true, true, true);
        emit NewTokenTree(erc20, DEFAULT_TREE_DEPTH, DEFAULT_LEAF_ZERO_VALUE, Z_24);
        main.initTokenTree(IERC20(erc20));
        assertEq(main.getTreeDepth(erc20), DEFAULT_TREE_DEPTH);

        // tree root
        uint256 root = DEFAULT_LEAF_ZERO_VALUE;
        for (uint256 i = 0; i < DEFAULT_TREE_DEPTH; i++) {
            root = IPoseidonT3(poseidonT3).poseidon([root, root]);
        }
        assertEq(main.getTreeRoot(erc20), root);
        assertEq(main.getTreeLeafNum(erc20), 0);
    }

    function testShouldFailedInitTokenTree() external {
        main.initTokenTree(IERC20(erc20));

        vm.expectRevert(abi.encodeWithSelector(TokenTreeAlreadyInitialized.selector, IERC20(erc20)));
        main.initTokenTree(IERC20(erc20));
    }
}
