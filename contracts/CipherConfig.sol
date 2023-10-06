// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Cipher Protocol Configurations Library
 * @notice The library contains all the constants used in Cipher Protocol
 */
library CipherConfig {
    /// @notice The address to represent ETH token when using ETH in Cipher Protocol
    address internal constant DEFAULT_ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    /// @notice The default tree depth for the incremental tree
    uint256 internal constant DEFAULT_TREE_DEPTH = 24;
    /// @notice The snark scalar field
    uint256 internal constant SNARK_SCALAR_FIELD =
        21888242871839275222246405745257275088548364400416034343698204186575808495617;
    /// @notice The fee base for calculating fee amount
    uint16 internal constant FEE_BASE = 10000;
    /// @notice The size of valid history roots
    uint8 internal constant VALID_HISTORY_ROOTS_SIZE = 32;
}
