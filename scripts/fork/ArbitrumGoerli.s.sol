// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DeploymentBase} from "../Deploy.s.sol";

contract ArbitrumGoerliDeployment is DeploymentBase {
    uint256 arbitrum_goerli;

    function _initFork() internal override {
        arbitrum_goerli = vm.createFork("arbitrum_goerli");
    }

    function _selectFork() internal override {
        vm.selectFork(arbitrum_goerli);
    }
}
