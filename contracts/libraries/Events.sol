// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {RelayerInfo} from "../utils/DataType.sol";

library Events {
    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        Cipher.sol
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    event NewTokenTree(IERC20 indexed token);
    event NewRelayer(address indexed relayer, string relayerMetadataUri);
    event RelayerUpdated(address indexed relayer, string newRelayerMetadataUri);
    event NewRoot(IERC20 indexed token, uint256 root);
    event RelayInfo(address sender, RelayerInfo relayerInfo, uint256 feeAmt);

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        TokenTree.sol
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    event NewNullifier(IERC20 indexed token, uint256 nullifier);
    event NewCommitment(IERC20 indexed token, uint256 commitment, uint256 leafIndex);
}
