// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {Cipher} from "../contracts/Cipher.sol";

contract Base_Test is Test {
    address internal poseidonT3;

    address internal merkleTree;
    
    Cipher internal cipher;

    function setUp() public virtual {
      poseidonT3 = address(uint160(uint256(keccak256("poseidon_t3"))));
      deployCodeTo("PoseidonT3.sol:PoseidonT3", poseidonT3);
      merkleTree = address(uint160(uint256(keccak256("merkle_tree"))));
      deployCodeTo("IncrementalBinaryTree.sol:IncrementalBinaryTree", merkleTree);

      cipher = new Cipher(address(0), 0);
    }

    function testLog() external {
      console.logAddress(poseidonT3);
      console.logAddress(merkleTree);
      console.logAddress(address(cipher));
    }
}