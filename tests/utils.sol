// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

uint256 constant SNARK_FIELD_SIZE = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

uint256 constant DEFAULT_TREE_DEPTH = 24;

address constant DEFAULT_NATIVE_TOKEN_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

IERC20 constant DEFAULT_NATIVE_TOKEN = IERC20(DEFAULT_NATIVE_TOKEN_ADDRESS);

uint256 constant Z_24 = 10950512088864623017193855008549027964818627314169113560361044208148762403141;

uint256 constant DEFAULT_LEAF_ZERO_VALUE =
    14693734620209785393966954230592927715867821236176778989295931055453090412689;
