// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DeploymentBase} from "../Deploy.s.sol";

contract GoerliDeployment is DeploymentBase {
    uint256 goerli;

    function _initFork() internal override {
        goerli = vm.createFork("goerli");
    }

    function _selectFork() internal override {
        vm.selectFork(goerli);
    }
}
