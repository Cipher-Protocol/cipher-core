// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "../Base_Test.sol";

contract TestCipherSelfWithdraw is BaseTest {
    function testSelfWithdraw() external {
        PublicInfo memory publicInfo = PublicInfo({
            maxAllowableFeeRate: 0,
            recipient: payable(address(0)),
            token: IERC20(Constants.DEFAULT_NATIVE_TOKEN),
            deadline: 0
        });
        PublicSignals memory publicSignals = PublicSignals({
            root: 0,
            publicInAmt: 0,
            publicOutAmt: 1 ether,
            publicInfoHash: 0,
            inputNullifiers: new uint256[](0),
            outputCommitments: new uint256[](0)
        });

        // expect revert
        vm.expectRevert(Errors.InvalidRecipientAddr.selector);
        main.selfWithdraw(IERC20(Constants.DEFAULT_NATIVE_TOKEN), publicInfo, publicSignals);

        // success
        // publicInfo.recipient = payable(userBob);
        // assertEq(
        //     main.selfWithdraw(IERC20(Constants.DEFAULT_NATIVE_TOKEN), publicInfo, publicSignals),
        //     true
        // );
    }
}
