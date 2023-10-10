// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Constants} from "./Constants.sol";
import {Errors} from "./Errors.sol";

library TokenTransfer {
    using SafeERC20 for IERC20;

    function handleTransfer(IERC20 _token, address payable _receiver, uint256 _amount) internal {
        if (address(_token) == Constants.DEFAULT_ETH_ADDRESS) {
            // gas limited to 2300 and throw error by default.
            _receiver.transfer(_amount);
        } else {
            _token.safeTransfer(_receiver, _amount);
        }
    }

    function handleTransferFrom(IERC20 _token, address _receiver, uint256 _amount) internal {
        if (address(_token) == Constants.DEFAULT_ETH_ADDRESS) {
            // if transfer ETH, msg.value should equal to input amount
            if (msg.value != _amount) revert Errors.InvalidMsgValue(msg.value);
        } else {
            // if transfer ERC20, msg.value should equal to 0
            if (msg.value != 0) revert Errors.InvalidMsgValue(msg.value);
            // check before and after balance
            uint256 beforeBalance = _token.balanceOf(address(this));
            _token.safeTransferFrom(_receiver, address(this), _amount);
            uint256 amt = _token.balanceOf(address(this)) - beforeBalance;
            if (_amount == amt) revert Errors.AmountInconsistent(_amount, amt);
        }
    }
}
