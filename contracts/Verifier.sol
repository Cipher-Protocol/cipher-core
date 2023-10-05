// SPDX-License-Identifier: GPL-3.0
/*
    Copyright 2021 0KIMS association.

    This file is generated with [snarkJS](https://github.com/iden3/snarkjs).

    snarkJS is a free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    snarkJS is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
    License for more details.

    You should have received a copy of the GNU General Public License
    along with snarkJS. If not, see <https://www.gnu.org/licenses/>.
*/
import {VerifierConfig} from "./VerifierConfig.sol";
import {Proof} from "./interfaces/IVerifier.sol";
import "hardhat/console.sol";

pragma solidity ^0.8.20;

contract Verifier is VerifierConfig {
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;
    uint16 constant pLastMem = 896;

    function verifyProof(Proof calldata proof, bytes2 _type) public view returns (bool) {
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

            function getFixedSizeConfigs(utxoType) -> IC0x, IC0y, IC1x, IC1y, IC2x, IC2y, IC3x, IC3y, IC4x, IC4y {
                switch utxoType
                case hex"0001" {
                    IC0x := n0m1_IC0x
                    IC0y := n0m1_IC0y
                    IC1x := n0m1_IC1x
                    IC1y := n0m1_IC1y
                    IC2x := n0m1_IC2x
                    IC2y := n0m1_IC2y
                    IC3x := n0m1_IC3x
                    IC3y := n0m1_IC3y
                    IC4x := n0m1_IC4x
                    IC4y := n0m1_IC4y
                }
                case hex"0002" {
                    IC0x := n0m2_IC0x
                    IC0y := n0m2_IC0y
                    IC1x := n0m2_IC1x
                    IC1y := n0m2_IC1y
                    IC2x := n0m2_IC2x
                    IC2y := n0m2_IC2y
                    IC3x := n0m2_IC3x
                    IC3y := n0m2_IC3y
                    IC4x := n0m2_IC4x
                    IC4y := n0m2_IC4y
                }
                case hex"0004" {
                    IC0x := n0m4_IC0x
                    IC0y := n0m4_IC0y
                    IC1x := n0m4_IC1x
                    IC1y := n0m4_IC1y
                    IC2x := n0m4_IC2x
                    IC2y := n0m4_IC2y
                    IC3x := n0m4_IC3x
                    IC3y := n0m4_IC3y
                    IC4x := n0m4_IC4x
                    IC4y := n0m4_IC4y
                }
                case hex"0100" {
                    IC0x := n1m0_IC0x
                    IC0y := n1m0_IC0y
                    IC1x := n1m0_IC1x
                    IC1y := n1m0_IC1y
                    IC2x := n1m0_IC2x
                    IC2y := n1m0_IC2y
                    IC3x := n1m0_IC3x
                    IC3y := n1m0_IC3y
                    IC4x := n1m0_IC4x
                    IC4y := n1m0_IC4y
                }
                case hex"0101" {
                    IC0x := n1m1_IC0x
                    IC0y := n1m1_IC0y
                    IC1x := n1m1_IC1x
                    IC1y := n1m1_IC1y
                    IC2x := n1m1_IC2x
                    IC2y := n1m1_IC2y
                    IC3x := n1m1_IC3x
                    IC3y := n1m1_IC3y
                    IC4x := n1m1_IC4x
                    IC4y := n1m1_IC4y
                }

                default {
                    // this is not allowed
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            function getDeltas(utxoType) -> deltax1, deltax2, deltay1, deltay2 {
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

                default {
                    // this is not allowed
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            function dynamicMulAcc(_pVk, inputNullifiersOffset, outputCommitmentsOffset, utxoType) {
                switch utxoType
                case hex"0001" {
                    g1_mulAccC(_pVk, n0m1_IC5x, n0m1_IC5y, calldataload(add(outputCommitmentsOffset, 32)))
                }
                case hex"0002" {
                    g1_mulAccC(_pVk, n0m2_IC5x, n0m2_IC5y, calldataload(add(outputCommitmentsOffset, 32)))
                    g1_mulAccC(_pVk, n0m2_IC6x, n0m2_IC6y, calldataload(add(outputCommitmentsOffset, 64)))
                }
                case hex"0004" {
                    g1_mulAccC(_pVk, n0m4_IC5x, n0m4_IC5y, calldataload(add(outputCommitmentsOffset, 32)))
                    g1_mulAccC(_pVk, n0m4_IC6x, n0m4_IC6y, calldataload(add(outputCommitmentsOffset, 64)))
                    g1_mulAccC(_pVk, n0m4_IC7x, n0m4_IC7y, calldataload(add(outputCommitmentsOffset, 96)))
                    g1_mulAccC(_pVk, n0m4_IC8x, n0m4_IC8y, calldataload(add(outputCommitmentsOffset, 128)))
                }
                case hex"0100" {
                    g1_mulAccC(_pVk, n1m0_IC5x, n1m0_IC5y, calldataload(add(inputNullifiersOffset, 32)))
                }
                case hex"0101" {
                    g1_mulAccC(_pVk, n1m1_IC5x, n1m1_IC5y, calldataload(add(inputNullifiersOffset, 32)))
                    g1_mulAccC(_pVk, n1m1_IC6x, n1m1_IC6y, calldataload(add(outputCommitmentsOffset, 32)))
                }

                default {
                    // this is not allowed
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            /**
             * | calldata layout:
             * | ------------------ | ------------- | ----------------- | ----------------------------------------------------
             * | pos                | pos           | pos               | value
             * | (absolute)         | (rel proof)   | (rel pubSignals)  |
             * | 0                  |               |                   | function selector
             * | 4                  |               |                   | proof.offset (64)
             * | 36                 |               |                   | uxtoType (right-padded to 32 bytes)
             * | ------------------ | ------------- | ----------------- | ----------------------------------------------------
             * | 68 + 0             | 0             |                   | proof.a[0]
             * | 68 + 32            | 32            |                   | proof.a[1]
             * | 68 + 64            | 64            |                   | proof.b[0][0]
             * | 68 + 96            | 96            |                   | proof.b[0][1]
             * | 68 + 128           | 128           |                   | proof.b[1][0]
             * | 68 + 160           | 160           |                   | proof.b[1][1]
             * | 68 + 192           | 192           |                   | proof.c[0]
             * | 68 + 224           | 224           |                   | proof.c[1]
             * | 68 + 256           | 256           |                   | proof.publicSignals.offset (288)
             * | ------------------ | ------------- | ----------------- | ----------------------------------------------------
             * | 68 + 288           | 288           | 0                 | proof.publicSignals.root
             * | 68 + 320           | 320           | 32                | proof.publicSignals.publicInAmt
             * | 68 + 352           | 352           | 64                | proof.publicSignals.publicOutAmt
             * | 68 + 384           | 384           | 96                | proof.publicSignals.publicInfoHash
             * | 68 + 416           | 416           | 128               | proof.publicSignals.inputNullifiers.offset (192)
             * | 68 + 448           | 448           | 160               | proof.publicSignals.outputCommitments.offset (224 + 32*n)
             * | 68 + 480           | 480           | 192               | proof.publicSignals.inputNullifiers.length (n)
             * | 68 + 512           | 512           | 224               | proof.publicSignals.inputNullifiers[0]
             * | 68 + ...           | ...           | ...               | ...
             * | 68 + 512 + 32*n    | 512 + 32*n    | 224 + 32n         | proof.publicSignals.outputCommitments.length (m)
             * | 68 + 544 + 32*n    | 544 + 32*n    | 256 + 32n         | proof.publicSignals.outputCommitments[0]
             * | 68 + ...           | ...           | ...               | ...
             * | ------------------ | ------------- | ----------------- | ----------------------------------------------------
             */

            let pMem := mload(0x40)
            mstore(0x40, add(pMem, pLastMem))

            // Validate that all evaluations ∈ F
            // check field for root, publicInAmt, publicOutAmt, publicInfoHash
            checkField(calldataload(add(proof, 288))) // proof.publicSignals.root
            checkField(calldataload(add(proof, 320))) // proof.publicSignals.publicInAmt
            checkField(calldataload(add(proof, 352))) // proof.publicSignals.publicOutAmt
            checkField(calldataload(add(proof, 384))) // proof.publicSignals.publicInfoHash

            // check field for inputNullifiers
            let pos := add(proof, 480)
            let bytesLen := mul(calldataload(pos), 32) // inputNullifiers.length * 32
            pos := add(pos, 32) // inputNullifiers[0]
            let end := add(bytesLen, pos)
            for {

            } lt(pos, end) {
                pos := add(pos, 32)
            } {
                checkField(calldataload(pos))
            }

            // check field for outputCommitments
            bytesLen := mul(calldataload(pos), 32) // outputCommitments.length * 32
            pos := add(pos, 32) // outputCommitments[0]
            end := add(bytesLen, pos)
            for {

            } lt(pos, end) {
                pos := add(pos, 32)
            } {
                checkField(calldataload(pos))
            }

            let _pPairing := add(pMem, pPairing)
            let _pVk := add(pMem, pVk)

            let IC0x, IC0y, IC1x, IC1y, IC2x, IC2y, IC3x, IC3y, IC4x, IC4y := getFixedSizeConfigs(_type)

            mstore(_pVk, IC0x)
            mstore(add(_pVk, 32), IC0y)

            let publicSignalsOffset := add(proof, 256)
            g1_mulAccC(_pVk, IC1x, IC1y, calldataload(add(publicSignalsOffset, 32)))
            g1_mulAccC(_pVk, IC2x, IC2y, calldataload(add(publicSignalsOffset, 64)))
            g1_mulAccC(_pVk, IC3x, IC3y, calldataload(add(publicSignalsOffset, 96)))
            g1_mulAccC(_pVk, IC4x, IC4y, calldataload(add(publicSignalsOffset, 128)))

            let inputNullifiersOffset := add(add(publicSignalsOffset, 32), calldataload(add(proof, 416)))
            let outputCommitmentsOffset := add(add(publicSignalsOffset, 32), calldataload(add(proof, 448)))
            dynamicMulAcc(_pVk, inputNullifiersOffset, outputCommitmentsOffset, _type)

            // -A
            mstore(_pPairing, calldataload(proof))
            mstore(add(_pPairing, 32), mod(sub(q, mod(calldataload(add(proof, 32)), q)), q))

            // B
            let pB := add(proof, 64)
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
            mstore(add(_pPairing, 384), mload(_pVk))
            mstore(add(_pPairing, 416), mload(add(_pVk, 32)))

            // gamma2
            mstore(add(_pPairing, 448), gammax1)
            mstore(add(_pPairing, 480), gammax2)
            mstore(add(_pPairing, 512), gammay1)
            mstore(add(_pPairing, 544), gammay2)

            // C
            let pC := add(proof, 192)
            mstore(add(_pPairing, 576), calldataload(pC))
            mstore(add(_pPairing, 608), calldataload(add(pC, 32)))

            // delta2
            let deltax1, deltax2, deltay1, deltay2 := getDeltas(_type)
            mstore(add(_pPairing, 640), deltax1)
            mstore(add(_pPairing, 672), deltax2)
            mstore(add(_pPairing, 704), deltay1)
            mstore(add(_pPairing, 736), deltay2)

            let success := staticcall(sub(gas(), 2000), 8, _pPairing, 768, _pPairing, 0x20)
            success := and(success, mload(_pPairing))

            mstore(0, success)
            return(0, 0x20)
        }
    }
}
