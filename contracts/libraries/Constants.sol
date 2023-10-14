// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library Constants {
    /// @dev The address to represent native token on deployed network (i.e. ETH on Ethereum)
    address internal constant DEFAULT_NATIVE_TOKEN_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /// @dev The native token on deployed network
    IERC20 internal constant DEFAULT_NATIVE_TOKEN = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    /// @dev The default tree depth for the incremental tree
    uint256 internal constant DEFAULT_TREE_DEPTH = 24;

    /// @dev The snark scalar field
    uint256 internal constant SNARK_SCALAR_FIELD =
        21888242871839275222246405745257275088548364400416034343698204186575808495617;

    /// @dev The fee base for calculating fee amount
    uint16 internal constant FEE_BASE = 10000;

    /// @dev The size of valid history roots
    uint8 internal constant VALID_HISTORY_ROOTS_SIZE = 32;

    /// @dev The number of one bytes in decimal
    uint256 internal constant NUM_OF_ONE_BYTES = 256;
}
