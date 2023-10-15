// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IPoseidonT3 {
    function poseidon(uint256[2] memory input) external pure returns (uint256);
}
