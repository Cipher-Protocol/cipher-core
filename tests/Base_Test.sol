// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {PoseidonT3} from "poseidon-solidity/PoseidonT3.sol";

import {CipherVerifier} from "../contracts/CipherVerifier.sol";
import {Cipher} from "../contracts/Cipher.sol";
import {ERC20Mock} from "../contracts/mock/ERC20Mock.sol";

abstract contract BaseTest is Test {
    address internal poseidonT3;

    address internal merkleTree;

    CipherVerifier internal verifier;

    Cipher internal main;

    ERC20Mock internal erc20;

    function setUp() external virtual {
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

        vm.deal(address(this), 100 ether);
    }
}
