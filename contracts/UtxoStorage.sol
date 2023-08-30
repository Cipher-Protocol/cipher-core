// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract UtxoStorage {
    mapping(bytes32 => bool) internal nullifiers;
}
