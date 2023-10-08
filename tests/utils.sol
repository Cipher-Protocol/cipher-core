// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

uint256 constant SNARK_FIELD_SIZE = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

uint256 constant DEFAULT_TREE_HEIGHT = 5;

uint16 constant DEFAULT_FEE = 0;

uint256 constant DEFAULT_TREE_DEPTH = 24;

address constant DEFAULT_ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

IERC20 constant DEFAULT_ETH_IERC20 = IERC20(DEFAULT_ETH_ADDRESS);
