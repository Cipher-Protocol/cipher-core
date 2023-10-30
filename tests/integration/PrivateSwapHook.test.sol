// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {BaseTest} from "../Base_Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {IHooks} from "@uniswap/v4-core/contracts/interfaces/IHooks.sol";
import {PoolManager} from "@uniswap/v4-core/contracts/PoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/contracts/types/PoolKey.sol";
import {Currency} from "@uniswap/v4-core/contracts/types/Currency.sol";
import {TickMath} from "@uniswap/v4-core/contracts/libraries/TickMath.sol";
import {Cipher} from "../../contracts/Cipher.sol";
import {CipherVerifier} from "../../contracts/CipherVerifier.sol";
import {ERC20Mock} from "../../contracts/mock/ERC20Mock.sol";
import {PrivateSwapHook} from "../../contracts/integrations/uniswapV4/PrivateSwapHook.sol";
import {HookFactory} from "../../contracts/integrations/uniswapV4/HookFactory.sol";

contract PrivateSwapHookTest is Test {
    using stdJson for string;

    address internal user1;

    address internal poseidonT3;

    address internal merkleTree;

    CipherVerifier internal verifier;

    Cipher internal cipher;

    PrivateSwapHook internal privateSwapHook;

    HookFactory internal hookFactory;

    uint256 internal constant CONTROLLER_GAS_LIMIT = 50000;
    IPoolManager internal poolManager;
    // IPoolManager constant poolManager = IPoolManager(0x862Fa52D0c8Bca8fBCB5213C9FEbC49c87A52912);

    ERC20Mock internal erc20;
    // ERC20Mock constant usdc = ERC20Mock(0x07865c6E87B9F70255377e024ace6630C1Eaa37F);

    PoolKey internal poolKey;

    function setUp() external virtual {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/tests/utils/PoseidonT3.json");
        string memory json = vm.readFile(path);

        vm.createSelectFork("https://eth-goerli.g.alchemy.com/v2/jeFJuYIBL2oK6D2faoJ5y3HT8uJtyUkt", 9923545);

        // deploy poseidonT3 library
        address addr;
        bytes memory creation = json.readBytes(".creationCode");
        assembly {
            addr := create(0, add(0x20, creation), mload(creation))
        }
        poseidonT3 = addr;

        // deploy verifier
        verifier = new CipherVerifier();

        // deploy cipher
        cipher = new Cipher(address(verifier), address(poseidonT3));

        // deploy pool manager
        poolManager = new PoolManager(CONTROLLER_GAS_LIMIT);

        // deploy hook factory
        hookFactory = new HookFactory(poolManager, cipher);

        bytes32 salt = hookFactory.getValidSalt();
        address hookAddr = hookFactory.deployHook(salt);
        privateSwapHook = PrivateSwapHook(hookAddr);

        // deploy erc20
        erc20 = new ERC20Mock("Test", "T", 18);

        poolKey = PoolKey({
            currency0: Currency.wrap(address(0)),
            currency1: Currency.wrap(address(erc20)),
            fee: 3000,
            hooks: IHooks(address(privateSwapHook)),
            tickSpacing: 60
        });

        //TODO: set sqrtPriceX96
        uint160 sqrtPriceX96 = 1 << 96;
        vm.assume(sqrtPriceX96 >= TickMath.MIN_SQRT_RATIO);
        vm.assume(sqrtPriceX96 < TickMath.MAX_SQRT_RATIO);
        poolManager.initialize(poolKey, sqrtPriceX96, "0x00");

        user1 = makeAddr("user1");
        erc20.mint(user1, 100 ether);

        vm.deal(address(this), 100 ether);
    }

    function testPrivateSwap() external {
        // IPoolManager.SwapParams memory swapParams = IPoolManager.SwapParams({
        //     zeroForOne: true,
        //     amountSpecified: int256(-100),
        //     sqrtPriceLimitX96: uint160(0)
        // });
        // vm.startPrank(user1);
        // poolManager.swap(poolKey, swapParams, "0x00");
        // vm.stopPrank();
    }
}
