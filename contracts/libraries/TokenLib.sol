// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Constants} from "./Constants.sol";
import {Errors} from "./Errors.sol";

library TokenLib {
    using SafeERC20 for IERC20;

    /// @notice Customized transfer function to support both native token and ERC20 token
    /// @param _token The token to transfer
    /// @param _receiver The receiver address
    /// @param _amount The amount to transfer
    function tokenTransfer(IERC20 _token, address payable _receiver, uint256 _amount) internal {
        if (_token == Constants.DEFAULT_NATIVE_TOKEN) {
            (bool success, bytes memory data) = _receiver.call{value: _amount}("");
            if (!success) revert Errors.TransferNativeTokenFailed(_receiver, _amount, data);
        } else {
            _token.safeTransfer(_receiver, _amount);
        }
    }

    /// @notice Customized transferFrom function to support both native token and ERC20 token
    /// @dev If transfer native token, `msg.value` should equal to input amount
    ///      If transfer ERC20 token, `msg.value` should equal to 0
    /// @param _token The token to transfer
    /// @param _receiver The receiver address
    /// @param _amount The amount to transfer
    function tokenTransferFrom(IERC20 _token, address _receiver, uint256 _amount) internal {
        if (_token == Constants.DEFAULT_NATIVE_TOKEN) {
            // if transfer native token, `msg.value` should equal to input amount
            if (msg.value != _amount) revert Errors.InvalidMsgValue(msg.value);
        } else {
            // if transfer ERC20, `msg.value` should equal to 0
            if (msg.value != 0) revert Errors.InvalidMsgValue(msg.value);
            uint256 beforeBalance = _token.balanceOf(address(this));
            _token.safeTransferFrom(_receiver, address(this), _amount);
            uint256 transferredAmt = _token.balanceOf(address(this)) - beforeBalance;
            if (_amount != transferredAmt) revert Errors.AmountInconsistent(_amount, transferredAmt);
        }
    }
}
