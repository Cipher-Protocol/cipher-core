// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Cipher} from "../contracts/Cipher.sol";

abstract contract InitTokenTree is Script {
    using stdJson for string;

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        variables
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    uint256 private privkey;
    Cipher private cipher;


    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        modifier
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    modifier broadcast() {
        vm.startBroadcast(privkey);
        _;
        vm.stopBroadcast();
    }

    modifier selectFork() {
        _selectFork();
        _;
    }

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        Script external functions
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    function setUp() external {
        privkey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        cipher = Cipher(_loadCipherConfig());
    }

    function run() external {
        address[] memory tokens = _loadTokens();
        for (uint256 i = 0; i < tokens.length;) {
            cipher.initTokenTree(IERC20(tokens[i]));
            unchecked {
                ++i;
            }
        }
    }

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        internal virtual funcitons
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    function _initFork() internal virtual;

    function _selectFork() internal virtual;

    function _loadTokens() internal pure virtual returns (address[] memory);

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        private funcitons
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    function _loadCipherConfig() private pure returns (address cipherAddr) {
        cipherAddr = 0xDb1ba478F71d91CD0D55b7e852B634228d42A719;
    }
}
