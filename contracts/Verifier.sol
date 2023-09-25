// SPDX-Ln2m2_icense-Identifier: GPL-3.0
/*
    Copyright 2021 0KIMS association.

    This file is generated with [snarkJS](https://github.com/iden3/snarkjs).

    snarkJS is a free software: you can redistribute it and/or modify it
    under the terms of the GNU General Publn2m2_ic Ln2m2_icense as published by
    the Free Software Foundation, either version 3 of the Ln2m2_icense, or
    (at your option) any later version.

    snarkJS is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    or FITNESS FOR A PARTn2m2_ICULAR PURPOSE. See the GNU General Publn2m2_ic
    Ln2m2_icense for more details.

    You should have received a copy of the GNU General Publn2m2_ic Ln2m2_icense
    along with snarkJS. If not, see <https://www.gnu.org/ln2m2_icenses/>.
*/
import {VerifierConfig} from "./VerifierConfig.sol";

pragma solidity ^0.8.20;

contract Verifier is VerifierConfig {
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        uint[] calldata _pubSignals, // remove fix size
        bytes2 _type
    ) public view returns (bool) {
        assembly {
            function checkField(v) {
                if iszero(lt(v, q)) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            // G1 function to multiply a G1 value(x,y) to value in an address
            function g1_mulAccC(pR, x, y, s) {
                let success
                let mIn := mload(0x40)
                mstore(mIn, x)
                mstore(add(mIn, 32), y)
                mstore(add(mIn, 64), s)

                success := staticcall(sub(gas(), 2000), 7, mIn, 96, mIn, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }

                mstore(add(mIn, 64), mload(pR))
                mstore(add(mIn, 96), mload(add(pR, 32)))

                success := staticcall(sub(gas(), 2000), 6, mIn, 128, pR, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            function getDelta(utxoType) -> deltax1, deltax2, deltay1, deltay2 {
                switch utxoType
                case hex"0001" {
                    deltax1 := n0m1_deltax1
                    deltax2 := n0m1_deltax2
                    deltay1 := n0m1_deltay1
                    deltay2 := n0m1_deltay2
                }
                case hex"0002" {
                    deltax1 := n0m2_deltax1
                    deltax2 := n0m2_deltax2
                    deltay1 := n0m2_deltay1
                    deltay2 := n0m2_deltay2
                }
                case hex"0004" {
                    deltax1 := n0m4_deltax1
                    deltax2 := n0m4_deltax2
                    deltay1 := n0m4_deltay1
                    deltay2 := n0m4_deltay2
                }
                case hex"0100" {
                    deltax1 := n1m0_deltax1
                    deltax2 := n1m0_deltax2
                    deltay1 := n1m0_deltay1
                    deltay2 := n1m0_deltay2
                }
                case hex"0101" {
                    deltax1 := n1m1_deltax1
                    deltax2 := n1m1_deltax2
                    deltay1 := n1m1_deltay1
                    deltay2 := n1m1_deltay2
                }
                case hex"0102" {
                    deltax1 := n1m2_deltax1
                    deltax2 := n1m2_deltax2
                    deltay1 := n1m2_deltay1
                    deltay2 := n1m2_deltay2
                }
                case hex"0104" {
                    deltax1 := n1m4_deltax1
                    deltax2 := n1m4_deltax2
                    deltay1 := n1m4_deltay1
                    deltay2 := n1m4_deltay2
                }
                case hex"0200" {
                    deltax1 := n2m0_deltax1
                    deltax2 := n2m0_deltax2
                    deltay1 := n2m0_deltay1
                    deltay2 := n2m0_deltay2
                }
                case hex"0201" {
                    deltax1 := n2m1_deltax1
                    deltax2 := n2m1_deltax2
                    deltay1 := n2m1_deltay1
                    deltay2 := n2m1_deltay2
                }
                case hex"0202" {
                    deltax1 := n2m2_deltax1
                    deltax2 := n2m2_deltax2
                    deltay1 := n2m2_deltay1
                    deltay2 := n2m2_deltay2
                }
                case hex"0204" {
                    deltax1 := n2m4_deltax1
                    deltax2 := n2m4_deltax2
                    deltay1 := n2m4_deltay1
                    deltay2 := n2m4_deltay2
                }
                case hex"0400" {
                    deltax1 := n4m0_deltax1
                    deltax2 := n4m0_deltax2
                    deltay1 := n4m0_deltay1
                    deltay2 := n4m0_deltay2
                }
                case hex"0401" {
                    deltax1 := n4m1_deltax1
                    deltax2 := n4m1_deltax2
                    deltay1 := n4m1_deltay1
                    deltay2 := n4m1_deltay2
                }
                case hex"0402" {
                    deltax1 := n4m2_deltax1
                    deltax2 := n4m2_deltax2
                    deltay1 := n4m2_deltay1
                    deltay2 := n4m2_deltay2
                }
                case hex"0404" {
                    deltax1 := n4m4_deltax1
                    deltax2 := n4m4_deltax2
                    deltay1 := n4m4_deltay1
                    deltay2 := n4m4_deltay2
                }

                default {
                    // this is not allowed
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            function getIC0(utxoType) -> IC0x, IC0y {
                switch utxoType
                case hex"0001" {
                    IC0x := n0m1_IC0x
                    IC0y := n0m1_IC0y
                }
                case hex"0002" {
                    IC0x := n0m2_IC0x
                    IC0y := n0m2_IC0y
                }
                case hex"0004" {
                    IC0x := n0m4_IC0x
                    IC0y := n0m4_IC0y
                }
                case hex"0100" {
                    IC0x := n1m0_IC0x
                    IC0y := n1m0_IC0y
                }
                case hex"0101" {
                    IC0x := n1m1_IC0x
                    IC0y := n1m1_IC0y
                }
                case hex"0102" {
                    IC0x := n1m2_IC0x
                    IC0y := n1m2_IC0y
                }
                case hex"0104" {
                    IC0x := n1m4_IC0x
                    IC0y := n1m4_IC0y
                }
                case hex"0200" {
                    IC0x := n2m0_IC0x
                    IC0y := n2m0_IC0y
                }
                case hex"0201" {
                    IC0x := n2m1_IC0x
                    IC0y := n2m1_IC0y
                }
                case hex"0202" {
                    IC0x := n2m2_IC0x
                    IC0y := n2m2_IC0y
                }
                case hex"0204" {
                    IC0x := n2m4_IC0x
                    IC0y := n2m4_IC0y
                }
                case hex"0400" {
                    IC0x := n4m0_IC0x
                    IC0y := n4m0_IC0y
                }
                case hex"0401" {
                    IC0x := n4m1_IC0x
                    IC0y := n4m1_IC0y
                }
                case hex"0402" {
                    IC0x := n4m2_IC0x
                    IC0y := n4m2_IC0y
                }
                case hex"0404" {
                    IC0x := n4m4_IC0x
                    IC0y := n4m4_IC0y
                }

                default {
                    // this is not allowed
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            function g1_mulAccC_dispatcher(_pVk, pubSignals, utxoType) {
                switch utxoType
                case hex"0001" {
                    g1_mulAccC(_pVk, n0m1_IC1x, n0m1_IC1y, calldataload(pubSignals))
                    g1_mulAccC(_pVk, n0m1_IC2x, n0m1_IC2y, calldataload(add(pubSignals, 32)))
                    g1_mulAccC(_pVk, n0m1_IC3x, n0m1_IC3y, calldataload(add(pubSignals, 64)))
                    g1_mulAccC(_pVk, n0m1_IC4x, n0m1_IC4y, calldataload(add(pubSignals, 96)))
                    g1_mulAccC(_pVk, n0m1_IC5x, n0m1_IC5y, calldataload(add(pubSignals, 128)))
                }
                case hex"0002" {
                    g1_mulAccC(_pVk, n0m2_IC1x, n0m2_IC1y, calldataload(pubSignals))
                    g1_mulAccC(_pVk, n0m2_IC2x, n0m2_IC2y, calldataload(add(pubSignals, 32)))
                    g1_mulAccC(_pVk, n0m2_IC3x, n0m2_IC3y, calldataload(add(pubSignals, 64)))
                    g1_mulAccC(_pVk, n0m2_IC4x, n0m2_IC4y, calldataload(add(pubSignals, 96)))
                    g1_mulAccC(_pVk, n0m2_IC5x, n0m2_IC5y, calldataload(add(pubSignals, 128)))
                    g1_mulAccC(_pVk, n0m2_IC6x, n0m2_IC6y, calldataload(add(pubSignals, 160)))
                }
                case hex"0004" {
                    g1_mulAccC(_pVk, n0m4_IC1x, n0m4_IC1y, calldataload(pubSignals))
                    g1_mulAccC(_pVk, n0m4_IC2x, n0m4_IC2y, calldataload(add(pubSignals, 32)))
                    g1_mulAccC(_pVk, n0m4_IC3x, n0m4_IC3y, calldataload(add(pubSignals, 64)))
                    g1_mulAccC(_pVk, n0m4_IC4x, n0m4_IC4y, calldataload(add(pubSignals, 96)))
                    g1_mulAccC(_pVk, n0m4_IC5x, n0m4_IC5y, calldataload(add(pubSignals, 128)))
                    g1_mulAccC(_pVk, n0m4_IC6x, n0m4_IC6y, calldataload(add(pubSignals, 160)))
                    g1_mulAccC(_pVk, n0m4_IC7x, n0m4_IC7y, calldataload(add(pubSignals, 192)))
                    g1_mulAccC(_pVk, n0m4_IC8x, n0m4_IC8y, calldataload(add(pubSignals, 224)))
                }
                case hex"0100" {
                    g1_mulAccC(_pVk, n1m0_IC1x, n1m0_IC1y, calldataload(pubSignals))
                    g1_mulAccC(_pVk, n1m0_IC2x, n1m0_IC2y, calldataload(add(pubSignals, 32)))
                    g1_mulAccC(_pVk, n1m0_IC3x, n1m0_IC3y, calldataload(add(pubSignals, 64)))
                    g1_mulAccC(_pVk, n1m0_IC4x, n1m0_IC4y, calldataload(add(pubSignals, 96)))
                    g1_mulAccC(_pVk, n1m0_IC5x, n1m0_IC5y, calldataload(add(pubSignals, 128)))
                }
                case hex"0101" {
                    g1_mulAccC(_pVk, n1m1_IC1x, n1m1_IC1y, calldataload(pubSignals))
                    g1_mulAccC(_pVk, n1m1_IC2x, n1m1_IC2y, calldataload(add(pubSignals, 32)))
                    g1_mulAccC(_pVk, n1m1_IC3x, n1m1_IC3y, calldataload(add(pubSignals, 64)))
                    g1_mulAccC(_pVk, n1m1_IC4x, n1m1_IC4y, calldataload(add(pubSignals, 96)))
                    g1_mulAccC(_pVk, n1m1_IC5x, n1m1_IC5y, calldataload(add(pubSignals, 128)))
                    g1_mulAccC(_pVk, n1m1_IC6x, n1m1_IC6y, calldataload(add(pubSignals, 160)))
                }
                case hex"0102" {
                    g1_mulAccC(_pVk, n1m2_IC1x, n1m2_IC1y, calldataload(pubSignals))
                    g1_mulAccC(_pVk, n1m2_IC2x, n1m2_IC2y, calldataload(add(pubSignals, 32)))
                    g1_mulAccC(_pVk, n1m2_IC3x, n1m2_IC3y, calldataload(add(pubSignals, 64)))
                    g1_mulAccC(_pVk, n1m2_IC4x, n1m2_IC4y, calldataload(add(pubSignals, 96)))
                    g1_mulAccC(_pVk, n1m2_IC5x, n1m2_IC5y, calldataload(add(pubSignals, 128)))
                    g1_mulAccC(_pVk, n1m2_IC6x, n1m2_IC6y, calldataload(add(pubSignals, 160)))
                    g1_mulAccC(_pVk, n1m2_IC7x, n1m2_IC7y, calldataload(add(pubSignals, 192)))
                }
                case hex"0104" {
                    g1_mulAccC(_pVk, n1m4_IC1x, n1m4_IC1y, calldataload(pubSignals))
                    g1_mulAccC(_pVk, n1m4_IC2x, n1m4_IC2y, calldataload(add(pubSignals, 32)))
                    g1_mulAccC(_pVk, n1m4_IC3x, n1m4_IC3y, calldataload(add(pubSignals, 64)))
                    g1_mulAccC(_pVk, n1m4_IC4x, n1m4_IC4y, calldataload(add(pubSignals, 96)))
                    g1_mulAccC(_pVk, n1m4_IC5x, n1m4_IC5y, calldataload(add(pubSignals, 128)))
                    g1_mulAccC(_pVk, n1m4_IC6x, n1m4_IC6y, calldataload(add(pubSignals, 160)))
                    g1_mulAccC(_pVk, n1m4_IC7x, n1m4_IC7y, calldataload(add(pubSignals, 192)))
                    g1_mulAccC(_pVk, n1m4_IC8x, n1m4_IC8y, calldataload(add(pubSignals, 224)))
                    g1_mulAccC(_pVk, n1m4_IC9x, n1m4_IC9y, calldataload(add(pubSignals, 256)))
                }
                case hex"0200" {
                    g1_mulAccC(_pVk, n2m0_IC1x, n2m0_IC1y, calldataload(pubSignals))
                    g1_mulAccC(_pVk, n2m0_IC2x, n2m0_IC2y, calldataload(add(pubSignals, 32)))
                    g1_mulAccC(_pVk, n2m0_IC3x, n2m0_IC3y, calldataload(add(pubSignals, 64)))
                    g1_mulAccC(_pVk, n2m0_IC4x, n2m0_IC4y, calldataload(add(pubSignals, 96)))
                    g1_mulAccC(_pVk, n2m0_IC5x, n2m0_IC5y, calldataload(add(pubSignals, 128)))
                    g1_mulAccC(_pVk, n2m0_IC6x, n2m0_IC6y, calldataload(add(pubSignals, 160)))
                }
                case hex"0201" {
                    g1_mulAccC(_pVk, n2m1_IC1x, n2m1_IC1y, calldataload(pubSignals))
                    g1_mulAccC(_pVk, n2m1_IC2x, n2m1_IC2y, calldataload(add(pubSignals, 32)))
                    g1_mulAccC(_pVk, n2m1_IC3x, n2m1_IC3y, calldataload(add(pubSignals, 64)))
                    g1_mulAccC(_pVk, n2m1_IC4x, n2m1_IC4y, calldataload(add(pubSignals, 96)))
                    g1_mulAccC(_pVk, n2m1_IC5x, n2m1_IC5y, calldataload(add(pubSignals, 128)))
                    g1_mulAccC(_pVk, n2m1_IC6x, n2m1_IC6y, calldataload(add(pubSignals, 160)))
                    g1_mulAccC(_pVk, n2m1_IC7x, n2m1_IC7y, calldataload(add(pubSignals, 192)))
                }
                case hex"0202" {
                    g1_mulAccC(_pVk, n2m2_IC1x, n2m2_IC1y, calldataload(pubSignals))
                    g1_mulAccC(_pVk, n2m2_IC2x, n2m2_IC2y, calldataload(add(pubSignals, 32)))
                    g1_mulAccC(_pVk, n2m2_IC3x, n2m2_IC3y, calldataload(add(pubSignals, 64)))
                    g1_mulAccC(_pVk, n2m2_IC4x, n2m2_IC4y, calldataload(add(pubSignals, 96)))
                    g1_mulAccC(_pVk, n2m2_IC5x, n2m2_IC5y, calldataload(add(pubSignals, 128)))
                    g1_mulAccC(_pVk, n2m2_IC6x, n2m2_IC6y, calldataload(add(pubSignals, 160)))
                    g1_mulAccC(_pVk, n2m2_IC7x, n2m2_IC7y, calldataload(add(pubSignals, 192)))
                    g1_mulAccC(_pVk, n2m2_IC8x, n2m2_IC8y, calldataload(add(pubSignals, 224)))
                }
                case hex"0204" {
                    g1_mulAccC(_pVk, n2m4_IC1x, n2m4_IC1y, calldataload(pubSignals))
                    g1_mulAccC(_pVk, n2m4_IC2x, n2m4_IC2y, calldataload(add(pubSignals, 32)))
                    g1_mulAccC(_pVk, n2m4_IC3x, n2m4_IC3y, calldataload(add(pubSignals, 64)))
                    g1_mulAccC(_pVk, n2m4_IC4x, n2m4_IC4y, calldataload(add(pubSignals, 96)))
                    g1_mulAccC(_pVk, n2m4_IC5x, n2m4_IC5y, calldataload(add(pubSignals, 128)))
                    g1_mulAccC(_pVk, n2m4_IC6x, n2m4_IC6y, calldataload(add(pubSignals, 160)))
                    g1_mulAccC(_pVk, n2m4_IC7x, n2m4_IC7y, calldataload(add(pubSignals, 192)))
                    g1_mulAccC(_pVk, n2m4_IC8x, n2m4_IC8y, calldataload(add(pubSignals, 224)))
                    g1_mulAccC(_pVk, n2m4_IC9x, n2m4_IC9y, calldataload(add(pubSignals, 256)))
                    g1_mulAccC(_pVk, n2m4_IC10x, n2m4_IC10y, calldataload(add(pubSignals, 288)))
                }
                case hex"0400" {
                    g1_mulAccC(_pVk, n4m0_IC1x, n4m0_IC1y, calldataload(pubSignals))
                    g1_mulAccC(_pVk, n4m0_IC2x, n4m0_IC2y, calldataload(add(pubSignals, 32)))
                    g1_mulAccC(_pVk, n4m0_IC3x, n4m0_IC3y, calldataload(add(pubSignals, 64)))
                    g1_mulAccC(_pVk, n4m0_IC4x, n4m0_IC4y, calldataload(add(pubSignals, 96)))
                    g1_mulAccC(_pVk, n4m0_IC5x, n4m0_IC5y, calldataload(add(pubSignals, 128)))
                    g1_mulAccC(_pVk, n4m0_IC6x, n4m0_IC6y, calldataload(add(pubSignals, 160)))
                    g1_mulAccC(_pVk, n4m0_IC7x, n4m0_IC7y, calldataload(add(pubSignals, 192)))
                    g1_mulAccC(_pVk, n4m0_IC8x, n4m0_IC8y, calldataload(add(pubSignals, 224)))
                }
                case hex"0401" {
                    g1_mulAccC(_pVk, n4m1_IC1x, n4m1_IC1y, calldataload(pubSignals))
                    g1_mulAccC(_pVk, n4m1_IC2x, n4m1_IC2y, calldataload(add(pubSignals, 32)))
                    g1_mulAccC(_pVk, n4m1_IC3x, n4m1_IC3y, calldataload(add(pubSignals, 64)))
                    g1_mulAccC(_pVk, n4m1_IC4x, n4m1_IC4y, calldataload(add(pubSignals, 96)))
                    g1_mulAccC(_pVk, n4m1_IC5x, n4m1_IC5y, calldataload(add(pubSignals, 128)))
                    g1_mulAccC(_pVk, n4m1_IC6x, n4m1_IC6y, calldataload(add(pubSignals, 160)))
                    g1_mulAccC(_pVk, n4m1_IC7x, n4m1_IC7y, calldataload(add(pubSignals, 192)))
                    g1_mulAccC(_pVk, n4m1_IC8x, n4m1_IC8y, calldataload(add(pubSignals, 224)))
                    g1_mulAccC(_pVk, n4m1_IC9x, n4m1_IC9y, calldataload(add(pubSignals, 256)))
                }
                case hex"0402" {
                    g1_mulAccC(_pVk, n4m2_IC1x, n4m2_IC1y, calldataload(pubSignals))
                    g1_mulAccC(_pVk, n4m2_IC2x, n4m2_IC2y, calldataload(add(pubSignals, 32)))
                    g1_mulAccC(_pVk, n4m2_IC3x, n4m2_IC3y, calldataload(add(pubSignals, 64)))
                    g1_mulAccC(_pVk, n4m2_IC4x, n4m2_IC4y, calldataload(add(pubSignals, 96)))
                    g1_mulAccC(_pVk, n4m2_IC5x, n4m2_IC5y, calldataload(add(pubSignals, 128)))
                    g1_mulAccC(_pVk, n4m2_IC6x, n4m2_IC6y, calldataload(add(pubSignals, 160)))
                    g1_mulAccC(_pVk, n4m2_IC7x, n4m2_IC7y, calldataload(add(pubSignals, 192)))
                    g1_mulAccC(_pVk, n4m2_IC8x, n4m2_IC8y, calldataload(add(pubSignals, 224)))
                    g1_mulAccC(_pVk, n4m2_IC9x, n4m2_IC9y, calldataload(add(pubSignals, 256)))
                    g1_mulAccC(_pVk, n4m2_IC10x, n4m2_IC10y, calldataload(add(pubSignals, 288)))
                }
                case hex"0404" {
                    g1_mulAccC(_pVk, n4m4_IC1x, n4m4_IC1y, calldataload(pubSignals))
                    g1_mulAccC(_pVk, n4m4_IC2x, n4m4_IC2y, calldataload(add(pubSignals, 32)))
                    g1_mulAccC(_pVk, n4m4_IC3x, n4m4_IC3y, calldataload(add(pubSignals, 64)))
                    g1_mulAccC(_pVk, n4m4_IC4x, n4m4_IC4y, calldataload(add(pubSignals, 96)))
                    g1_mulAccC(_pVk, n4m4_IC5x, n4m4_IC5y, calldataload(add(pubSignals, 128)))
                    g1_mulAccC(_pVk, n4m4_IC6x, n4m4_IC6y, calldataload(add(pubSignals, 160)))
                    g1_mulAccC(_pVk, n4m4_IC7x, n4m4_IC7y, calldataload(add(pubSignals, 192)))
                    g1_mulAccC(_pVk, n4m4_IC8x, n4m4_IC8y, calldataload(add(pubSignals, 224)))
                    g1_mulAccC(_pVk, n4m4_IC9x, n4m4_IC9y, calldataload(add(pubSignals, 256)))
                    g1_mulAccC(_pVk, n4m4_IC10x, n4m4_IC10y, calldataload(add(pubSignals, 288)))
                    g1_mulAccC(_pVk, n4m4_IC11x, n4m4_IC11y, calldataload(add(pubSignals, 320)))
                    g1_mulAccC(_pVk, n4m4_IC12x, n4m4_IC12y, calldataload(add(pubSignals, 352)))
                }

                default {
                    // this is not allowed
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            function checkPairing(pA, pB, pC, pubSignals, pMem, utxoType) -> isOk {
                let _pPairing := add(pMem, pPairing)
                let _pVk := add(pMem, pVk)

                let IC0x, IC0y := getIC0(utxoType)
                mstore(_pVk, IC0x)
                mstore(add(_pVk, 32), IC0y)

                // Compute the linear combination vk_x
                g1_mulAccC_dispatcher(_pVk, pubSignals, utxoType)

                // -A
                mstore(_pPairing, calldataload(pA))
                mstore(add(_pPairing, 32), mod(sub(q, mod(calldataload(add(pA, 32)), q)), q))

                // B
                mstore(add(_pPairing, 64), calldataload(pB))
                mstore(add(_pPairing, 96), calldataload(add(pB, 32)))
                mstore(add(_pPairing, 128), calldataload(add(pB, 64)))
                mstore(add(_pPairing, 160), calldataload(add(pB, 96)))

                // alpha1
                mstore(add(_pPairing, 192), alphax)
                mstore(add(_pPairing, 224), alphay)

                // beta2
                mstore(add(_pPairing, 256), betax1)
                mstore(add(_pPairing, 288), betax2)
                mstore(add(_pPairing, 320), betay1)
                mstore(add(_pPairing, 352), betay2)

                // vk_x
                mstore(add(_pPairing, 384), mload(add(pMem, pVk)))
                mstore(add(_pPairing, 416), mload(add(pMem, add(pVk, 32))))

                // gamma2
                mstore(add(_pPairing, 448), gammax1)
                mstore(add(_pPairing, 480), gammax2)
                mstore(add(_pPairing, 512), gammay1)
                mstore(add(_pPairing, 544), gammay2)

                // C
                mstore(add(_pPairing, 576), calldataload(pC))
                mstore(add(_pPairing, 608), calldataload(add(pC, 32)))

                // delta2
                // get delta by utxoType
                let deltax1, deltax2, deltay1, deltay2 := getDelta(utxoType)
                mstore(add(_pPairing, 640), deltax1)
                mstore(add(_pPairing, 672), deltax2)
                mstore(add(_pPairing, 704), deltay1)
                mstore(add(_pPairing, 736), deltay2)

                let success := staticcall(sub(gas(), 2000), 8, _pPairing, 768, _pPairing, 0x20)

                isOk := and(success, mload(_pPairing))
            }

            let pMem := mload(0x40)
            mstore(0x40, add(pMem, pLastMem))

            // Validate that all evaluations ∈ F
            let end := mul(_pubSignals.length, 0x20)
            for {
                let i := 0
            } lt(i, end) {
                i := add(i, 0x20)
            } {
                checkField(calldataload(add(_pubSignals.offset, i)))
            }

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals.offset, pMem, _type)

            mstore(0, isValid)
            return(0, 0x20)
        }
    }
}
