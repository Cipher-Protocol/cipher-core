// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Cipher} from "../../contracts/Cipher.sol";
import {PublicInfo, PublicSignals} from "../../contracts/DataType.sol";

contract CipherMock is Cipher {
    constructor(address verifierAddr, address poseidonT3Addr) Cipher(verifierAddr, poseidonT3Addr) {}

    function selfWithdraw(
        IERC20 token,
        PublicInfo calldata publicInfo,
        PublicSignals calldata publicSignals
    ) external returns (bool) {
        _selfWithdraw(token, publicInfo, publicSignals);
        return true;
    }
}
