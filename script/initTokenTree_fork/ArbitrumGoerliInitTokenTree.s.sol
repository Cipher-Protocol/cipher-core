// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {InitTokenTree} from "../InitTokenTree.s.sol";

contract ArbitrumGoerliInitTokenTree is InitTokenTree {
    uint256 arbitrum_goerli;

    function _initFork() internal override {
        arbitrum_goerli = vm.createFork("arbitrum_goerli");
    }

    function _selectFork() internal override {
        vm.selectFork(arbitrum_goerli);
    }
    function _loadTokens() internal pure override returns (address[] memory ret) {
        ret = new address[](2);
        ret[0] = 0xe39Ab88f8A4777030A534146A9Ca3B52bd5D43A3; // weth
        ret[1] = 0x8FB1E3fC51F3b789dED7557E680551d93Ea9d892; // usdc
    }

    function _loadCipherConfig() internal pure override returns (address) {
        return 0x4A412EBbe9bf88C49B22cCe759d52c67bef37115;
    }
}
