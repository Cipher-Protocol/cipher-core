// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {ICipher} from "../../interfaces/ICipher.sol";
import {PrivateSwapHook} from "./PrivateSwapHook.sol";

contract HookFactory {
    error NoValidSaltFound();
    bytes1 internal constant ADDRESS_PREFIX = 0x04;

    IPoolManager internal immutable poolManager;
    ICipher internal immutable cipher;

    constructor(IPoolManager _poolManager, ICipher _cipher) {
        poolManager = _poolManager;
        cipher = _cipher;
    }

    function deployHook(bytes32 salt) external returns (address) {
        return address(new PrivateSwapHook{salt: salt}(poolManager, cipher));
    }

    function getValidSalt() external view returns (bytes32) {
        for (uint256 i = 0; i < 1500; i++) {
            bytes32 salt = bytes32(i);
            address addr = _calcPrecomputedHookAddr(salt);
            if (_isValidPrefix(addr, ADDRESS_PREFIX)) return salt;
        }
        revert NoValidSaltFound();
    }

    function _calcPrecomputedHookAddr(bytes32 salt) internal view returns (address) {
        bytes32 bytecodeHash = keccak256(
            abi.encodePacked(type(PrivateSwapHook).creationCode, abi.encode(poolManager, cipher))
        );

        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, bytecodeHash));

        return address(uint160(uint256(hash)));
    }

    function _isValidPrefix(address _address, bytes1 _prefix) private pure returns (bool) {
        return bytes1(uint8(uint160(_address) >> (19 * 8))) == _prefix;
    }
}
