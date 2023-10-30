// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "../Base_Test.sol";

contract TestTokenLib is BaseTest {
    using TokenLib for IERC20;

    function testTokenTransfer() external {
        // native ether transfer
        assertEq(userBob.balance, 0);
        IERC20(Constants.DEFAULT_NATIVE_TOKEN_ADDRESS).tokenTransfer(payable(userBob), 1 ether);
        assertEq(userBob.balance, 1 ether);

        // erc20 transfer
        assertEq(erc20.balanceOf(userBob), 0);
        IERC20(erc20).tokenTransfer(payable(userBob), 1 ether);
        assertEq(erc20.balanceOf(userBob), 1 ether);
    }

    function testTokenTransferFrom() external {
        // native ether transferFrom
        tokenLibMock.doTransferFrom{value: 1 ether}(IERC20(Constants.DEFAULT_NATIVE_TOKEN_ADDRESS), address(this), 1 ether);
        assertEq(address(tokenLibMock).balance, 1 ether);

        // erc20 transferFrom
        IERC20(erc20).approve(address(tokenLibMock), 10 ether);
        tokenLibMock.doTransferFrom(erc20, address(this), 10 ether);
        assertEq(erc20.balanceOf(address(tokenLibMock)), 10 ether);
    }
}
