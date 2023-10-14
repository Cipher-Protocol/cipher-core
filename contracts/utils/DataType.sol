// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

struct Proof {
    uint256[2] a;
    uint256[2][2] b;
    uint256[2] c;
    PublicSignals publicSignals;
}

struct PublicSignals {
    uint256 root;
    uint256 publicInAmt;
    uint256 publicOutAmt;
    uint256 publicInfoHash;
    uint256[] inputNullifiers;
    uint256[] outputCommitments;
}

struct PublicInfo {
    uint16 maxAllowableFeeRate;
    address payable recipient;
    IERC20 token;
    uint32 deadline;
}

struct RelayerInfo {
    address payable registeredAddr;
    address payable feeReceiver;
    // transfered amount * feeRate / FEE_BASE = fee amount
    // i.e. 1000 * 300 / 10000 = 30 (3% fee)
    uint16 feeRate;
}
