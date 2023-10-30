// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/contracts/types/PoolId.sol";
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/contracts/types/Currency.sol";
import {BalanceDelta} from "@uniswap/v4-core/contracts/types/BalanceDelta.sol";
import {PoolKey} from "@uniswap/v4-core/contracts/types/PoolKey.sol";
import {BaseHook} from "@uniswap/v4-periphery/contracts/BaseHook.sol";
import {ICipher} from "../../interfaces/ICipher.sol";
import {Proof, PublicInfo} from "../../DataType.sol";
import {Constants} from "../../libraries/Constants.sol";

contract PrivateSwapHook is BaseHook {
    using SafeERC20 for IERC20;
    using CurrencyLibrary for Currency;

    error SwapExpired(uint256 deadline);

    ICipher public immutable cipher;

    constructor(IPoolManager _poolManager, ICipher _cipher) BaseHook(_poolManager) {
        cipher = _cipher;
    }

    function getHooksCalls() public pure override returns (Hooks.Calls memory) {
        return
            Hooks.Calls({
                beforeInitialize: false,
                afterInitialize: false,
                beforeModifyPosition: false,
                afterModifyPosition: false,
                beforeSwap: false,
                afterSwap: true,
                beforeDonate: false,
                afterDonate: false
            });
    }

    function privateSwap(
        PoolKey calldata poolKey,
        IPoolManager.SwapParams calldata swapParams,
        Proof calldata proof,
        PublicInfo calldata publicInfo
    ) public payable {
        bytes memory hookData = abi.encode(proof, publicInfo);
        poolManager.lock(abi.encodeCall(this.lockAcquiredSwap, (poolKey, swapParams, hookData)));
    }

    function lockAcquiredSwap(
        PoolKey calldata poolKey,
        IPoolManager.SwapParams calldata swapParams,
        bytes calldata hookData
    ) external payable selfOnly {
        poolManager.swap(poolKey, swapParams, hookData);
    }

    function _settle(Currency currency, int128 deltaAmount, Proof memory proof, PublicInfo memory publicInfo) private {
        // token out of pool
        if (deltaAmount < 0) {
            // take to address(this)
            poolManager.take(currency, address(this), uint128(-deltaAmount));

            // Cipher using DEFAULT_NATIVE_TOKEN_ADDRESS for native token
            address currencyAddr = currency.isNative()
                ? Constants.DEFAULT_NATIVE_TOKEN_ADDRESS
                : Currency.unwrap(currency);

            if (currencyAddr == address(publicInfo.token)) {
                require(uint128(-deltaAmount) == proof.publicSignals.publicInAmt, "Invalid publicInAmt");

                if (currencyAddr == Constants.DEFAULT_NATIVE_TOKEN_ADDRESS) {
                    cipher.cipherTransact{value: uint128(-deltaAmount)}(proof, publicInfo);
                } else {
                    IERC20(currencyAddr).safeApprove(address(cipher), uint128(-deltaAmount));
                    cipher.cipherTransact(proof, publicInfo);
                }
            }
            return;
        }

        if (currency.isNative()) {
            poolManager.settle{value: uint128(deltaAmount)}(currency);
            return;
        }

        IERC20(Currency.unwrap(currency)).safeTransferFrom(msg.sender, address(poolManager), uint128(deltaAmount));
        poolManager.settle(currency);
    }

    function afterSwap(
        address,
        PoolKey calldata poolKey,
        IPoolManager.SwapParams calldata,
        BalanceDelta delta,
        bytes calldata hookData
    ) external override poolManagerOnly returns (bytes4) {
        (Proof memory proof, PublicInfo memory publicInfo) = abi.decode(hookData, (Proof, PublicInfo));
        _settle(poolKey.currency0, delta.amount0(), proof, publicInfo);
        _settle(poolKey.currency1, delta.amount1(), proof, publicInfo);

        return PrivateSwapHook.afterSwap.selector;
    }
}
