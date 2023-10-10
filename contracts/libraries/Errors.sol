// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Proof} from "../utils/DataType.sol";

library Errors {
    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        Cipher.sol
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    error TokenTreeAlreadyInitialized(IERC20 token);
    error TokenTreeNotExists(IERC20 token);
    error InvalidProof(Proof proof);
    error InvalidRecipientAddr();
    error InvalidRoot(uint256 root);
    error InvalidMaxAllowableFeeRate(uint16 maxAllowableFeeRate);
    error InvalidRelayerFeeRate(uint16 feeRate, uint16 maxAllowableFeeRate);

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        Helper.sol
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    error InvalidNullifierNum(uint256 nullifierNum);
    error InvalidCommitmentNum(uint256 commitmentNum);
    error InvalidUtxoType(bytes2 utxoType, uint256 nullifierNum, uint256 commitmentNum);
    error InvalidPublicInfo(uint256 publicInfoHash, uint256 calcPublicInfoHash);

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        TokenTree.sol
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    error InvalidNullifier(uint256 nullifier);

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        TokenTransfer.sol
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    error InvalidMsgValue(uint256 msgValue);
    error TransferFailed(address payable receiver, uint256 amount);
    error AmountInconsistent(uint256 amount, uint256 transferredAmt);
}
