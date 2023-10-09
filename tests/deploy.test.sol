// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {PoseidonT3} from "poseidon-solidity/PoseidonT3.sol";
import {CipherVerifier} from "../contracts/CipherVerifier.sol";
import {Cipher} from "../contracts/Cipher.sol";
import {
    DEFAULT_FEE,
    DEFAULT_ETH_ADDRESS,
    DEFAULT_ETH_IERC20,
    DEFAULT_TREE_DEPTH,
    SNARK_FIELD_SIZE
} from "./utils.sol";

contract DeployTest is Test {
    address internal poseidonT3;

    address internal merkleTree;

    CipherVerifier internal verifier;

    Cipher internal main;

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
        main = new Cipher(address(verifier), DEFAULT_FEE);
    }

    function testTreeDepth() external {
        assertEq(main.getTreeDepth(DEFAULT_ETH_IERC20), DEFAULT_TREE_DEPTH);
    }

    function testTreeZeroes() external {
        uint256 defaultZeroValue = uint256(keccak256(abi.encode(DEFAULT_ETH_ADDRESS))) % SNARK_FIELD_SIZE;
        assertEq(defaultZeroValue, main.getTreeZeroes(DEFAULT_ETH_IERC20, 0));

        uint256 zero = defaultZeroValue;
        for (uint256 i = 1; i < DEFAULT_TREE_DEPTH; i++) {
            zero = PoseidonT3.hash([zero, zero]);
            assertEq(zero, main.getTreeZeroes(DEFAULT_ETH_IERC20, i));
        }
    }

    function testTreeRoot() external {
        uint256 zero = uint256(keccak256(abi.encode(DEFAULT_ETH_ADDRESS))) % SNARK_FIELD_SIZE;
        for (uint256 i = 0; i < DEFAULT_TREE_DEPTH; i++) {
            zero = PoseidonT3.hash([zero, zero]);
        }
        assertEq(zero, main.getTreeRoot(DEFAULT_ETH_IERC20));
        assertEq(0, main.getTreeLeafNum(DEFAULT_ETH_IERC20));
    }
}
