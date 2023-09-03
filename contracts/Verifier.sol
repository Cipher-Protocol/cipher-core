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
    // Scalar field size
    uint256 constant r = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    // Base field size
    uint256 constant q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // Verifn2m2_ication Key data
    uint256 constant alphax = 20491192805390485299153009773594534940189261866228447918068658471970481763042;
    uint256 constant alphay = 9383485363053290200918347156157836566562967994039712273449902621266178545958;
    uint256 constant betax1 = 4252822878758300859123897981450591353533073413197771768651442665752259397132;
    uint256 constant betax2 = 6375614351688725206403948262868962793625744043794305715222011528459656738731;
    uint256 constant betay1 = 21847035105528745403288232691147584728191162732299865338377159692350059136679;
    uint256 constant betay2 = 10505242626370262277552901082094356697409835680220590971873171140371331206856;
    uint256 constant gammax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gammax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gammay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gammay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;

    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        uint[] calldata _pubSignals, // remove fix size
        bytes1 _type
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
                case 0x02 {
                    deltax1 := n0m2_deltax1
                    deltax2 := n0m2_deltax2
                    deltay1 := n0m2_deltay1
                    deltay2 := n0m2_deltay2
                }
                case 0x22 {
                    deltax1 := n2m2_deltax1
                    deltax2 := n2m2_deltax2
                    deltay1 := n2m2_deltay1
                    deltay2 := n2m2_deltay2
                }
                default {
                    // this is not allowed
                }
            }

            function getIC0(utxoType) -> IC0x, IC0y {
                switch utxoType
                case 0x02 {
                    IC0x := n0m2_IC0x
                    IC0y := n0m2_IC0y
                }
                case 0x22 {
                    IC0x := n2m2_IC0x
                    IC0y := n2m2_IC0y
                }
                default {
                    // this is not allowed
                }
            }

            function g1_mulAccC_dispatcher(_pVk, utxoType, pubSignals) {
                switch utxoType
                case 0x02 {
                    g1_mulAccC(_pVk, n0m2_IC1x, n0m2_IC1y, calldataload(add(pubSignals, 0)))
                    g1_mulAccC(_pVk, n0m2_IC2x, n0m2_IC2y, calldataload(add(pubSignals, 32)))
                    g1_mulAccC(_pVk, n0m2_IC3x, n0m2_IC3y, calldataload(add(pubSignals, 64)))
                    g1_mulAccC(_pVk, n0m2_IC4x, n0m2_IC4y, calldataload(add(pubSignals, 96)))
                    g1_mulAccC(_pVk, n0m2_IC5x, n0m2_IC5y, calldataload(add(pubSignals, 128)))
                    g1_mulAccC(_pVk, n0m2_IC6x, n0m2_IC6y, calldataload(add(pubSignals, 160)))
                }
                case 0x22 {
                    g1_mulAccC(_pVk, n2m2_IC1x, n2m2_IC1y, calldataload(add(pubSignals, 0)))
                    g1_mulAccC(_pVk, n2m2_IC2x, n2m2_IC2y, calldataload(add(pubSignals, 32)))
                    g1_mulAccC(_pVk, n2m2_IC3x, n2m2_IC3y, calldataload(add(pubSignals, 64)))
                    g1_mulAccC(_pVk, n2m2_IC4x, n2m2_IC4y, calldataload(add(pubSignals, 96)))
                    g1_mulAccC(_pVk, n2m2_IC5x, n2m2_IC5y, calldataload(add(pubSignals, 128)))
                    g1_mulAccC(_pVk, n2m2_IC6x, n2m2_IC6y, calldataload(add(pubSignals, 160)))
                    g1_mulAccC(_pVk, n2m2_IC7x, n2m2_IC7y, calldataload(add(pubSignals, 192)))
                    g1_mulAccC(_pVk, n2m2_IC8x, n2m2_IC8y, calldataload(add(pubSignals, 224)))
                }
                default {
                    // this is not allowed
                }
            }

            function checkPairing(pA, pB, pC, pubSignals, pMem, utxoType) -> isOk {
                let _pPairing := add(pMem, pPairing)
                let _pVk := add(pMem, pVk)

                let IC0x, IC0y := getIC0(utxoType)
                mstore(_pVk, IC0x)
                mstore(add(_pVk, 32), IC0y)

                // Compute the linear combination vk_x

                // g1_mulAccC(_pVk, IC1x, IC1y, calldataload(add(pubSignals, 0)))

                // g1_mulAccC(_pVk, IC2x, IC2y, calldataload(add(pubSignals, 32)))

                // g1_mulAccC(_pVk, IC3x, IC3y, calldataload(add(pubSignals, 64)))

                // g1_mulAccC(_pVk, IC4x, IC4y, calldataload(add(pubSignals, 96)))

                // g1_mulAccC(_pVk, IC5x, IC5y, calldataload(add(pubSignals, 128)))

                // g1_mulAccC(_pVk, IC6x, IC6y, calldataload(add(pubSignals, 160)))

                // g1_mulAccC(_pVk, IC7x, IC7y, calldataload(add(pubSignals, 192)))

                // g1_mulAccC(_pVk, IC8x, IC8y, calldataload(add(pubSignals, 224)))

                g1_mulAccC_dispatcher(_pVk, utxoType, pubSignals)

                // -A
                mstore(_pPairing, calldataload(pA))
                mstore(add(_pPairing, 32), mod(sub(q, calldataload(add(pA, 32))), q))

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

            // checkField(calldataload(add(_pubSignals, 0)))

            // checkField(calldataload(add(_pubSignals, 32)))

            // checkField(calldataload(add(_pubSignals, 64)))

            // checkField(calldataload(add(_pubSignals, 96)))

            // checkField(calldataload(add(_pubSignals, 128)))

            // checkField(calldataload(add(_pubSignals, 160)))

            // checkField(calldataload(add(_pubSignals, 192)))

            // checkField(calldataload(add(_pubSignals, 224)))

            // checkField(calldataload(add(_pubSignals, 256)))

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
