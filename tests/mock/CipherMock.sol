// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity ^0.8.19;

import {Cipher} from "../../contracts/Cipher.sol";

contract CipherMock is Cipher {
    constructor(address verifierAddr, address poseidonT3Addr) Cipher(verifierAddr, poseidonT3Addr) {}
}
