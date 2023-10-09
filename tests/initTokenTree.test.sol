// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {PoseidonT3} from "poseidon-solidity/PoseidonT3.sol";
import {CipherVerifier} from "../contracts/CipherVerifier.sol";
import {Cipher} from "../contracts/Cipher.sol";
import {ERC20Mock} from "../contracts/mock/ERC20Mock.sol";
import {
    DEFAULT_FEE,
    DEFAULT_ETH_ADDRESS,
    DEFAULT_ETH_IERC20,
    DEFAULT_TREE_DEPTH,
    SNARK_FIELD_SIZE
} from "./utils.sol";

contract InitTokenTree is Test {
    address internal poseidonT3;

    address internal merkleTree;

    CipherVerifier internal verifier;

    Cipher internal main;

    ERC20Mock internal erc20;

    // TODO move event and error to another file
    event NewTokenTree(IERC20 indexed token, uint256 merkleTreeDepth, uint256 zeroValue);

    // TODO move event and error to another file
    error TokenTreeAlreadyInitialized(IERC20);

    function setUp() public virtual {
        // deploy poseidonT3 library
        poseidonT3 = address(uint160(uint256(keccak256("poseidon_t3"))));
        deployCodeTo("PoseidonT3.sol:PoseidonT3", poseidonT3);

        // deploy IncrementalBinaryTree library
        merkleTree = address(uint160(uint256(keccak256("merkle_tree"))));
        deployCodeTo("IncrementalBinaryTree.sol:IncrementalBinaryTree", merkleTree);

        // deploy verifier
        verifier = new CipherVerifier();

        // deploy cipher
        main = new Cipher(address(verifier));

        // deploy erc20
        erc20 = new ERC20Mock("Test", "T", 18);
    }

    function testInitTokenTree() external {
        // default zero valuc
        uint256 defaultZeroValue = uint256(keccak256(abi.encode(address(erc20)))) % SNARK_FIELD_SIZE;

        // init token tree
        // - emit `NewTokenTree` event
        // - check tree depth
        vm.expectEmit(true, true, true, true);
        emit NewTokenTree(erc20, DEFAULT_TREE_DEPTH, defaultZeroValue);
        main.initTokenTree(IERC20(erc20));
        assertEq(main.getTreeDepth(erc20), DEFAULT_TREE_DEPTH);

        // zero value
        uint256 z0 = defaultZeroValue;
        uint256 z1;
        for (uint256 i = 1; i < DEFAULT_TREE_DEPTH; i++) {
            z1 = PoseidonT3.hash([z0, z0]);
            z0 = z1;
            assertEq(main.getTreeZeroes(erc20, i), z1);
        }

        // tree root
        uint256 root = defaultZeroValue;
        for (uint256 i = 0; i < DEFAULT_TREE_DEPTH; i++) {
            root = PoseidonT3.hash([root, root]);
        }
        assertEq(main.getTreeRoot(erc20), root);
        assertEq(main.getTreeLeafNum(erc20), 0);
    }

    function testShouldFailedInitTokenTree() external {
        main.initTokenTree(IERC20(erc20));

        vm.expectRevert(
            abi.encodeWithSelector(TokenTreeAlreadyInitialized.selector, IERC20(erc20))
        );
        main.initTokenTree(IERC20(erc20));
    }
}
