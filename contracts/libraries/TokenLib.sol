// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Constants} from "./Constants.sol";
import {Errors} from "./Errors.sol";

library TokenLib {
    using SafeERC20 for IERC20;

    /// @notice Customized transfer function to support both native token and ERC20 token
    /// @param token The token to transfer
    /// @param receiver The receiver address
    /// @param amount The amount to transfer
    function tokenTransfer(IERC20 token, address payable receiver, uint256 amount) internal {
        if (token == Constants.DEFAULT_NATIVE_TOKEN) {
            (bool success, bytes memory data) = receiver.call{value: amount}("");
            if (!success) revert Errors.TransferNativeTokenFailed(receiver, amount, data);
        } else {
            token.safeTransfer(receiver, amount);
        }
    }

    /// @notice Customized transferFrom function to support both native token and ERC20 token
    /// @dev If transfer native token, `msg.value` should equal to input amount
    ///      If transfer ERC20 token, `msg.value` should equal to 0
    /// @param token The token to transfer
    /// @param sender The sender address
    /// @param amount The amount to transfer
    function tokenTransferFrom(IERC20 token, address sender, uint256 amount) internal {
        if (token == Constants.DEFAULT_NATIVE_TOKEN) {
            // if transfer native token, `msg.value` should equal to input amount
            if (msg.value != amount) revert Errors.InvalidMsgValue(msg.value);
        } else {
            // if transfer ERC20, `msg.value` should equal to 0
            if (msg.value != 0) revert Errors.InvalidMsgValue(msg.value);
            uint256 transferredAmt = token.balanceOf(address(this));
            token.safeTransferFrom(sender, address(this), amount);
            transferredAmt = token.balanceOf(address(this)) - transferredAmt;
            if (amount != transferredAmt) revert Errors.AmountInconsistent(amount, transferredAmt);
        }
    }
}
