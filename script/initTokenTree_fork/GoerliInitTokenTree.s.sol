// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {InitTokenTree} from "../InitTokenTree.s.sol";

contract GoerliInitTokenTree is InitTokenTree {
    uint256 goerli;

    function _initFork() internal override {
        goerli = vm.createFork("goerli");
    }

    function _selectFork() internal override {
        vm.selectFork(goerli);
    }

    function _loadTokens() internal pure override returns (address[] memory ret) {
        ret = new address[](2);
        ret[0] = 0xC04B0d3107736C32e19F1c62b2aF67BE61d63a05; // wbtc
        ret[1] = 0x07865c6E87B9F70255377e024ace6630C1Eaa37F; // usdc
    }

    function _loadCipherConfig() internal pure override returns (address) {
        return 0x4A412EBbe9bf88C49B22cCe759d52c67bef37115;
    }
}
