// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {TokenLib} from "../../contracts/libraries/TokenLib.sol";

contract TokenLibMock {
    using TokenLib for IERC20;

    function doTransfer(IERC20 _erc20, address _sender, uint256 _amount) external payable {
        _erc20.tokenTransfer(payable(_sender), _amount);
    }

    function doTransferFrom(IERC20 _erc20, address _sender, uint256 _amount) external payable {
        _erc20.tokenTransferFrom(payable(_sender), _amount);
    }
}
