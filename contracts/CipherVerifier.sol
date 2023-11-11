// SPDX-License-Identifier: GPL-3.0
// solhint-disable const-name-snakecase
pragma solidity ^0.8.19;

import {CipherVKeyConst} from "./CipherVKeyConst.sol";
import {Proof} from "./DataType.sol";

/**
 * @title CipherVerifier contract
 * @dev The snark verifier contract for verifying the snark proof (groth16)
 * @dev The custom verifier to support dynamic public signals array for different utxo types (nInputs, nOutputs)
 * @dev The implementation refers to iden3/snarkjs
        https://github.com/iden3/snarkjs/blob/master/templates/verifier_groth16.sol.ejs
 */
contract CipherVerifier is CipherVKeyConst {
    // Memory data
    uint16 internal constant pVk = 0;
    uint16 internal constant pPairing = 128;
    uint16 internal constant pLastMem = 896;

    function verifyProof(Proof calldata proof, bytes2 _type) public view returns (bool) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            function checkField(v) {
                if iszero(lt(v, q)) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            /// @notice Elliptic curve multiplication then accumulation
            /// @dev pR = pR + (x, y) * s
            /// @param pR The pointer to the result
            /// @param x The x coordinate of the point
            /// @param y The y coordinate of the point
            /// @param s The scalar
            function ecMulAcc(pR, x, y, s) {
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

            /// @notice Get the fixed size configurations for the given utxo type
            /// @param utxoType The utxo type
            /// @return IC0x The x coordinate of the default point
            /// @return IC0y The y coordinate of the default point
            /// @return IC1x The x coordinate of the input a[0]
            /// @return IC1y The y coordinate of the input a[1]
            /// @return IC2x The x coordinate of the first b[0][0]
            /// @return IC2y The y coordinate of the first b[0][1]
            /// @return IC3x The x coordinate of the first b[1][0]
            /// @return IC3y The y coordinate of the first b[1][1]
            /// @return IC4x The x coordinate of the output c[0]
            /// @return IC4y The y coordinate of the output c[1]
            function getFixedSizeVkeys(utxoType) -> IC0x, IC0y, IC1x, IC1y, IC2x, IC2y, IC3x, IC3y, IC4x, IC4y {
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
                case hex"0003" {
                    IC0x := n0m3_IC0x
                    IC0y := n0m3_IC0y
                    IC1x := n0m3_IC1x
                    IC1y := n0m3_IC1y
                    IC2x := n0m3_IC2x
                    IC2y := n0m3_IC2y
                    IC3x := n0m3_IC3x
                    IC3y := n0m3_IC3y
                    IC4x := n0m3_IC4x
                    IC4y := n0m3_IC4y
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
                case hex"0102" {
                    IC0x := n1m2_IC0x
                    IC0y := n1m2_IC0y
                    IC1x := n1m2_IC1x
                    IC1y := n1m2_IC1y
                    IC2x := n1m2_IC2x
                    IC2y := n1m2_IC2y
                    IC3x := n1m2_IC3x
                    IC3y := n1m2_IC3y
                    IC4x := n1m2_IC4x
                    IC4y := n1m2_IC4y
                }
                case hex"0103" {
                    IC0x := n1m3_IC0x
                    IC0y := n1m3_IC0y
                    IC1x := n1m3_IC1x
                    IC1y := n1m3_IC1y
                    IC2x := n1m3_IC2x
                    IC2y := n1m3_IC2y
                    IC3x := n1m3_IC3x
                    IC3y := n1m3_IC3y
                    IC4x := n1m3_IC4x
                    IC4y := n1m3_IC4y
                }
                case hex"0104" {
                    IC0x := n1m4_IC0x
                    IC0y := n1m4_IC0y
                    IC1x := n1m4_IC1x
                    IC1y := n1m4_IC1y
                    IC2x := n1m4_IC2x
                    IC2y := n1m4_IC2y
                    IC3x := n1m4_IC3x
                    IC3y := n1m4_IC3y
                    IC4x := n1m4_IC4x
                    IC4y := n1m4_IC4y
                }
                case hex"0200" {
                    IC0x := n2m0_IC0x
                    IC0y := n2m0_IC0y
                    IC1x := n2m0_IC1x
                    IC1y := n2m0_IC1y
                    IC2x := n2m0_IC2x
                    IC2y := n2m0_IC2y
                    IC3x := n2m0_IC3x
                    IC3y := n2m0_IC3y
                    IC4x := n2m0_IC4x
                    IC4y := n2m0_IC4y
                }
                case hex"0201" {
                    IC0x := n2m1_IC0x
                    IC0y := n2m1_IC0y
                    IC1x := n2m1_IC1x
                    IC1y := n2m1_IC1y
                    IC2x := n2m1_IC2x
                    IC2y := n2m1_IC2y
                    IC3x := n2m1_IC3x
                    IC3y := n2m1_IC3y
                    IC4x := n2m1_IC4x
                    IC4y := n2m1_IC4y
                }
                case hex"0202" {
                    IC0x := n2m2_IC0x
                    IC0y := n2m2_IC0y
                    IC1x := n2m2_IC1x
                    IC1y := n2m2_IC1y
                    IC2x := n2m2_IC2x
                    IC2y := n2m2_IC2y
                    IC3x := n2m2_IC3x
                    IC3y := n2m2_IC3y
                    IC4x := n2m2_IC4x
                    IC4y := n2m2_IC4y
                }
                case hex"0203" {
                    IC0x := n2m3_IC0x
                    IC0y := n2m3_IC0y
                    IC1x := n2m3_IC1x
                    IC1y := n2m3_IC1y
                    IC2x := n2m3_IC2x
                    IC2y := n2m3_IC2y
                    IC3x := n2m3_IC3x
                    IC3y := n2m3_IC3y
                    IC4x := n2m3_IC4x
                    IC4y := n2m3_IC4y
                }
                case hex"0204" {
                    IC0x := n2m4_IC0x
                    IC0y := n2m4_IC0y
                    IC1x := n2m4_IC1x
                    IC1y := n2m4_IC1y
                    IC2x := n2m4_IC2x
                    IC2y := n2m4_IC2y
                    IC3x := n2m4_IC3x
                    IC3y := n2m4_IC3y
                    IC4x := n2m4_IC4x
                    IC4y := n2m4_IC4y
                }
                case hex"0300" {
                    IC0x := n3m0_IC0x
                    IC0y := n3m0_IC0y
                    IC1x := n3m0_IC1x
                    IC1y := n3m0_IC1y
                    IC2x := n3m0_IC2x
                    IC2y := n3m0_IC2y
                    IC3x := n3m0_IC3x
                    IC3y := n3m0_IC3y
                    IC4x := n3m0_IC4x
                    IC4y := n3m0_IC4y
                }
                case hex"0301" {
                    IC0x := n3m1_IC0x
                    IC0y := n3m1_IC0y
                    IC1x := n3m1_IC1x
                    IC1y := n3m1_IC1y
                    IC2x := n3m1_IC2x
                    IC2y := n3m1_IC2y
                    IC3x := n3m1_IC3x
                    IC3y := n3m1_IC3y
                    IC4x := n3m1_IC4x
                    IC4y := n3m1_IC4y
                }
                case hex"0302" {
                    IC0x := n3m2_IC0x
                    IC0y := n3m2_IC0y
                    IC1x := n3m2_IC1x
                    IC1y := n3m2_IC1y
                    IC2x := n3m2_IC2x
                    IC2y := n3m2_IC2y
                    IC3x := n3m2_IC3x
                    IC3y := n3m2_IC3y
                    IC4x := n3m2_IC4x
                    IC4y := n3m2_IC4y
                }
                case hex"0303" {
                    IC0x := n3m3_IC0x
                    IC0y := n3m3_IC0y
                    IC1x := n3m3_IC1x
                    IC1y := n3m3_IC1y
                    IC2x := n3m3_IC2x
                    IC2y := n3m3_IC2y
                    IC3x := n3m3_IC3x
                    IC3y := n3m3_IC3y
                    IC4x := n3m3_IC4x
                    IC4y := n3m3_IC4y
                }
                case hex"0304" {
                    IC0x := n3m4_IC0x
                    IC0y := n3m4_IC0y
                    IC1x := n3m4_IC1x
                    IC1y := n3m4_IC1y
                    IC2x := n3m4_IC2x
                    IC2y := n3m4_IC2y
                    IC3x := n3m4_IC3x
                    IC3y := n3m4_IC3y
                    IC4x := n3m4_IC4x
                    IC4y := n3m4_IC4y
                }
                case hex"0400" {
                    IC0x := n4m0_IC0x
                    IC0y := n4m0_IC0y
                    IC1x := n4m0_IC1x
                    IC1y := n4m0_IC1y
                    IC2x := n4m0_IC2x
                    IC2y := n4m0_IC2y
                    IC3x := n4m0_IC3x
                    IC3y := n4m0_IC3y
                    IC4x := n4m0_IC4x
                    IC4y := n4m0_IC4y
                }
                case hex"0401" {
                    IC0x := n4m1_IC0x
                    IC0y := n4m1_IC0y
                    IC1x := n4m1_IC1x
                    IC1y := n4m1_IC1y
                    IC2x := n4m1_IC2x
                    IC2y := n4m1_IC2y
                    IC3x := n4m1_IC3x
                    IC3y := n4m1_IC3y
                    IC4x := n4m1_IC4x
                    IC4y := n4m1_IC4y
                }
                case hex"0402" {
                    IC0x := n4m2_IC0x
                    IC0y := n4m2_IC0y
                    IC1x := n4m2_IC1x
                    IC1y := n4m2_IC1y
                    IC2x := n4m2_IC2x
                    IC2y := n4m2_IC2y
                    IC3x := n4m2_IC3x
                    IC3y := n4m2_IC3y
                    IC4x := n4m2_IC4x
                    IC4y := n4m2_IC4y
                }
                case hex"0404" {
                    IC0x := n4m4_IC0x
                    IC0y := n4m4_IC0y
                    IC1x := n4m4_IC1x
                    IC1y := n4m4_IC1y
                    IC2x := n4m4_IC2x
                    IC2y := n4m4_IC2y
                    IC3x := n4m4_IC3x
                    IC3y := n4m4_IC3y
                    IC4x := n4m4_IC4x
                    IC4y := n4m4_IC4y
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
                case hex"0003" {
                    deltax1 := n0m3_deltax1
                    deltax2 := n0m3_deltax2
                    deltay1 := n0m3_deltay1
                    deltay2 := n0m3_deltay2
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
                case hex"0103" {
                    deltax1 := n1m3_deltax1
                    deltax2 := n1m3_deltax2
                    deltay1 := n1m3_deltay1
                    deltay2 := n1m3_deltay2
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
                case hex"0203" {
                    deltax1 := n2m3_deltax1
                    deltax2 := n2m3_deltax2
                    deltay1 := n2m3_deltay1
                    deltay2 := n2m3_deltay2
                }
                case hex"0204" {
                    deltax1 := n2m4_deltax1
                    deltax2 := n2m4_deltax2
                    deltay1 := n2m4_deltay1
                    deltay2 := n2m4_deltay2
                }
                case hex"0300" {
                    deltax1 := n3m0_deltax1
                    deltax2 := n3m0_deltax2
                    deltay1 := n3m0_deltay1
                    deltay2 := n3m0_deltay2
                }
                case hex"0301" {
                    deltax1 := n3m1_deltax1
                    deltax2 := n3m1_deltax2
                    deltay1 := n3m1_deltay1
                    deltay2 := n3m1_deltay2
                }
                case hex"0302" {
                    deltax1 := n3m2_deltax1
                    deltax2 := n3m2_deltax2
                    deltay1 := n3m2_deltay1
                    deltay2 := n3m2_deltay2
                }
                case hex"0303" {
                    deltax1 := n3m3_deltax1
                    deltax2 := n3m3_deltax2
                    deltay1 := n3m3_deltay1
                    deltay2 := n3m3_deltay2
                }
                case hex"0304" {
                    deltax1 := n3m4_deltax1
                    deltax2 := n3m4_deltax2
                    deltay1 := n3m4_deltay1
                    deltay2 := n3m4_deltay2
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

            /// @notice Elliptic curve multiplication then accumulation for dynamic public signals array (inputNullifiers, outputCommitments)
            /// @param _pVk The pointer to the verification key
            /// @param inputNullifiersPos The pointer to the inputNullifiers array, the first 32 bytes is the length of the array
            /// @param outputCommitmentsPos The pointer to the outputCommitments array, the first 32 bytes is the length of the array
            /// @param utxoType The utxo type
            function dynamicEcMulAcc(_pVk, inputNullifiersPos, outputCommitmentsPos, utxoType) {
                switch utxoType
                case hex"0001" {
                    ecMulAcc(_pVk, n0m1_IC5x, n0m1_IC5y, calldataload(add(outputCommitmentsPos, 32)))
                }
                case hex"0002" {
                    ecMulAcc(_pVk, n0m2_IC5x, n0m2_IC5y, calldataload(add(outputCommitmentsPos, 32)))
                    ecMulAcc(_pVk, n0m2_IC6x, n0m2_IC6y, calldataload(add(outputCommitmentsPos, 64)))
                }
                case hex"0003" {
                    ecMulAcc(_pVk, n0m3_IC5x, n0m3_IC5y, calldataload(add(outputCommitmentsPos, 32)))
                    ecMulAcc(_pVk, n0m3_IC6x, n0m3_IC6y, calldataload(add(outputCommitmentsPos, 64)))
                    ecMulAcc(_pVk, n0m3_IC7x, n0m3_IC7y, calldataload(add(outputCommitmentsPos, 96)))
                }
                case hex"0004" {
                    ecMulAcc(_pVk, n0m4_IC5x, n0m4_IC5y, calldataload(add(outputCommitmentsPos, 32)))
                    ecMulAcc(_pVk, n0m4_IC6x, n0m4_IC6y, calldataload(add(outputCommitmentsPos, 64)))
                    ecMulAcc(_pVk, n0m4_IC7x, n0m4_IC7y, calldataload(add(outputCommitmentsPos, 96)))
                    ecMulAcc(_pVk, n0m4_IC8x, n0m4_IC8y, calldataload(add(outputCommitmentsPos, 128)))
                }
                case hex"0100" {
                    ecMulAcc(_pVk, n1m0_IC5x, n1m0_IC5y, calldataload(add(inputNullifiersPos, 32)))
                }
                case hex"0101" {
                    ecMulAcc(_pVk, n1m1_IC5x, n1m1_IC5y, calldataload(add(inputNullifiersPos, 32)))
                    ecMulAcc(_pVk, n1m1_IC6x, n1m1_IC6y, calldataload(add(outputCommitmentsPos, 32)))
                }
                case hex"0102" {
                    ecMulAcc(_pVk, n1m2_IC5x, n1m2_IC5y, calldataload(add(inputNullifiersPos, 32)))
                    ecMulAcc(_pVk, n1m2_IC6x, n1m2_IC6y, calldataload(add(outputCommitmentsPos, 32)))
                    ecMulAcc(_pVk, n1m2_IC7x, n1m2_IC7y, calldataload(add(outputCommitmentsPos, 64)))
                }
                case hex"0103" {
                    ecMulAcc(_pVk, n1m3_IC5x, n1m3_IC5y, calldataload(add(inputNullifiersPos, 32)))
                    ecMulAcc(_pVk, n1m3_IC6x, n1m3_IC6y, calldataload(add(outputCommitmentsPos, 32)))
                    ecMulAcc(_pVk, n1m3_IC7x, n1m3_IC7y, calldataload(add(outputCommitmentsPos, 64)))
                    ecMulAcc(_pVk, n1m3_IC8x, n1m3_IC8y, calldataload(add(outputCommitmentsPos, 96)))
                }
                case hex"0104" {
                    ecMulAcc(_pVk, n1m4_IC5x, n1m4_IC5y, calldataload(add(inputNullifiersPos, 32)))
                    ecMulAcc(_pVk, n1m4_IC6x, n1m4_IC6y, calldataload(add(outputCommitmentsPos, 32)))
                    ecMulAcc(_pVk, n1m4_IC7x, n1m4_IC7y, calldataload(add(outputCommitmentsPos, 64)))
                    ecMulAcc(_pVk, n1m4_IC8x, n1m4_IC8y, calldataload(add(outputCommitmentsPos, 96)))
                    ecMulAcc(_pVk, n1m4_IC9x, n1m4_IC9y, calldataload(add(outputCommitmentsPos, 128)))
                }
                case hex"0200" {
                    ecMulAcc(_pVk, n2m0_IC5x, n2m0_IC5y, calldataload(add(inputNullifiersPos, 32)))
                    ecMulAcc(_pVk, n2m0_IC6x, n2m0_IC6y, calldataload(add(inputNullifiersPos, 64)))
                }
                case hex"0201" {
                    ecMulAcc(_pVk, n2m1_IC5x, n2m1_IC5y, calldataload(add(inputNullifiersPos, 32)))
                    ecMulAcc(_pVk, n2m1_IC6x, n2m1_IC6y, calldataload(add(inputNullifiersPos, 64)))
                    ecMulAcc(_pVk, n2m1_IC7x, n2m1_IC7y, calldataload(add(outputCommitmentsPos, 32)))
                }
                case hex"0202" {
                    ecMulAcc(_pVk, n2m2_IC5x, n2m2_IC5y, calldataload(add(inputNullifiersPos, 32)))
                    ecMulAcc(_pVk, n2m2_IC6x, n2m2_IC6y, calldataload(add(inputNullifiersPos, 64)))
                    ecMulAcc(_pVk, n2m2_IC7x, n2m2_IC7y, calldataload(add(outputCommitmentsPos, 32)))
                    ecMulAcc(_pVk, n2m2_IC8x, n2m2_IC8y, calldataload(add(outputCommitmentsPos, 64)))
                }
                case hex"0203" {
                    ecMulAcc(_pVk, n2m3_IC5x, n2m3_IC5y, calldataload(add(inputNullifiersPos, 32)))
                    ecMulAcc(_pVk, n2m3_IC6x, n2m3_IC6y, calldataload(add(inputNullifiersPos, 64)))
                    ecMulAcc(_pVk, n2m3_IC7x, n2m3_IC7y, calldataload(add(outputCommitmentsPos, 32)))
                    ecMulAcc(_pVk, n2m3_IC8x, n2m3_IC8y, calldataload(add(outputCommitmentsPos, 64)))
                    ecMulAcc(_pVk, n2m3_IC9x, n2m3_IC9y, calldataload(add(outputCommitmentsPos, 96)))
                }
                case hex"0204" {
                    ecMulAcc(_pVk, n2m4_IC5x, n2m4_IC5y, calldataload(add(inputNullifiersPos, 32)))
                    ecMulAcc(_pVk, n2m4_IC6x, n2m4_IC6y, calldataload(add(inputNullifiersPos, 64)))
                    ecMulAcc(_pVk, n2m4_IC7x, n2m4_IC7y, calldataload(add(outputCommitmentsPos, 32)))
                    ecMulAcc(_pVk, n2m4_IC8x, n2m4_IC8y, calldataload(add(outputCommitmentsPos, 64)))
                    ecMulAcc(_pVk, n2m4_IC9x, n2m4_IC9y, calldataload(add(outputCommitmentsPos, 96)))
                    ecMulAcc(_pVk, n2m4_IC10x, n2m4_IC10y, calldataload(add(outputCommitmentsPos, 128)))
                }
                case hex"0300" {
                    ecMulAcc(_pVk, n3m0_IC5x, n3m0_IC5y, calldataload(add(inputNullifiersPos, 32)))
                    ecMulAcc(_pVk, n3m0_IC6x, n3m0_IC6y, calldataload(add(inputNullifiersPos, 64)))
                    ecMulAcc(_pVk, n3m0_IC7x, n3m0_IC7y, calldataload(add(inputNullifiersPos, 96)))
                }
                case hex"0301" {
                    ecMulAcc(_pVk, n3m1_IC5x, n3m1_IC5y, calldataload(add(inputNullifiersPos, 32)))
                    ecMulAcc(_pVk, n3m1_IC6x, n3m1_IC6y, calldataload(add(inputNullifiersPos, 64)))
                    ecMulAcc(_pVk, n3m1_IC7x, n3m1_IC7y, calldataload(add(inputNullifiersPos, 96)))
                    ecMulAcc(_pVk, n3m1_IC8x, n3m1_IC8y, calldataload(add(outputCommitmentsPos, 32)))
                }
                case hex"0302" {
                    ecMulAcc(_pVk, n3m2_IC5x, n3m2_IC5y, calldataload(add(inputNullifiersPos, 32)))
                    ecMulAcc(_pVk, n3m2_IC6x, n3m2_IC6y, calldataload(add(inputNullifiersPos, 64)))
                    ecMulAcc(_pVk, n3m2_IC7x, n3m2_IC7y, calldataload(add(inputNullifiersPos, 96)))
                    ecMulAcc(_pVk, n3m2_IC8x, n3m2_IC8y, calldataload(add(outputCommitmentsPos, 32)))
                    ecMulAcc(_pVk, n3m2_IC9x, n3m2_IC9y, calldataload(add(outputCommitmentsPos, 64)))
                }
                case hex"0303" {
                    ecMulAcc(_pVk, n3m3_IC5x, n3m3_IC5y, calldataload(add(inputNullifiersPos, 32)))
                    ecMulAcc(_pVk, n3m3_IC6x, n3m3_IC6y, calldataload(add(inputNullifiersPos, 64)))
                    ecMulAcc(_pVk, n3m3_IC7x, n3m3_IC7y, calldataload(add(inputNullifiersPos, 96)))
                    ecMulAcc(_pVk, n3m3_IC8x, n3m3_IC8y, calldataload(add(outputCommitmentsPos, 32)))
                    ecMulAcc(_pVk, n3m3_IC9x, n3m3_IC9y, calldataload(add(outputCommitmentsPos, 64)))
                    ecMulAcc(_pVk, n3m3_IC10x, n3m3_IC10y, calldataload(add(outputCommitmentsPos, 96)))
                }
                case hex"0304" {
                    ecMulAcc(_pVk, n3m4_IC5x, n3m4_IC5y, calldataload(add(inputNullifiersPos, 32)))
                    ecMulAcc(_pVk, n3m4_IC6x, n3m4_IC6y, calldataload(add(inputNullifiersPos, 64)))
                    ecMulAcc(_pVk, n3m4_IC7x, n3m4_IC7y, calldataload(add(inputNullifiersPos, 96)))
                    ecMulAcc(_pVk, n3m4_IC8x, n3m4_IC8y, calldataload(add(outputCommitmentsPos, 32)))
                    ecMulAcc(_pVk, n3m4_IC9x, n3m4_IC9y, calldataload(add(outputCommitmentsPos, 64)))
                    ecMulAcc(_pVk, n3m4_IC10x, n3m4_IC10y, calldataload(add(outputCommitmentsPos, 96)))
                    ecMulAcc(_pVk, n3m4_IC11x, n3m4_IC11y, calldataload(add(outputCommitmentsPos, 128)))
                }
                case hex"0400" {
                    ecMulAcc(_pVk, n4m0_IC5x, n4m0_IC5y, calldataload(add(inputNullifiersPos, 32)))
                    ecMulAcc(_pVk, n4m0_IC6x, n4m0_IC6y, calldataload(add(inputNullifiersPos, 64)))
                    ecMulAcc(_pVk, n4m0_IC7x, n4m0_IC7y, calldataload(add(inputNullifiersPos, 96)))
                    ecMulAcc(_pVk, n4m0_IC8x, n4m0_IC8y, calldataload(add(inputNullifiersPos, 128)))
                }
                case hex"0401" {
                    ecMulAcc(_pVk, n4m1_IC5x, n4m1_IC5y, calldataload(add(inputNullifiersPos, 32)))
                    ecMulAcc(_pVk, n4m1_IC6x, n4m1_IC6y, calldataload(add(inputNullifiersPos, 64)))
                    ecMulAcc(_pVk, n4m1_IC7x, n4m1_IC7y, calldataload(add(inputNullifiersPos, 96)))
                    ecMulAcc(_pVk, n4m1_IC8x, n4m1_IC8y, calldataload(add(inputNullifiersPos, 128)))
                    ecMulAcc(_pVk, n4m1_IC9x, n4m1_IC9y, calldataload(add(outputCommitmentsPos, 32)))
                }
                case hex"0402" {
                    ecMulAcc(_pVk, n4m2_IC5x, n4m2_IC5y, calldataload(add(inputNullifiersPos, 32)))
                    ecMulAcc(_pVk, n4m2_IC6x, n4m2_IC6y, calldataload(add(inputNullifiersPos, 64)))
                    ecMulAcc(_pVk, n4m2_IC7x, n4m2_IC7y, calldataload(add(inputNullifiersPos, 96)))
                    ecMulAcc(_pVk, n4m2_IC8x, n4m2_IC8y, calldataload(add(inputNullifiersPos, 128)))
                    ecMulAcc(_pVk, n4m2_IC9x, n4m2_IC9y, calldataload(add(outputCommitmentsPos, 32)))
                    ecMulAcc(_pVk, n4m2_IC10x, n4m2_IC10y, calldataload(add(outputCommitmentsPos, 64)))
                }
                case hex"0404" {
                    ecMulAcc(_pVk, n4m4_IC5x, n4m4_IC5y, calldataload(add(inputNullifiersPos, 32)))
                    ecMulAcc(_pVk, n4m4_IC6x, n4m4_IC6y, calldataload(add(inputNullifiersPos, 64)))
                    ecMulAcc(_pVk, n4m4_IC7x, n4m4_IC7y, calldataload(add(inputNullifiersPos, 96)))
                    ecMulAcc(_pVk, n4m4_IC8x, n4m4_IC8y, calldataload(add(inputNullifiersPos, 128)))
                    ecMulAcc(_pVk, n4m4_IC9x, n4m4_IC9y, calldataload(add(outputCommitmentsPos, 32)))
                    ecMulAcc(_pVk, n4m4_IC10x, n4m4_IC10y, calldataload(add(outputCommitmentsPos, 64)))
                    ecMulAcc(_pVk, n4m4_IC11x, n4m4_IC11y, calldataload(add(outputCommitmentsPos, 96)))
                    ecMulAcc(_pVk, n4m4_IC12x, n4m4_IC12y, calldataload(add(outputCommitmentsPos, 128)))
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
            // check field for fixed size public signals (root, publicInAmt, publicOutAmt, publicInfoHash)
            checkField(calldataload(add(proof, 288))) // proof.publicSignals.root
            checkField(calldataload(add(proof, 320))) // proof.publicSignals.publicInAmt
            checkField(calldataload(add(proof, 352))) // proof.publicSignals.publicOutAmt
            checkField(calldataload(add(proof, 384))) // proof.publicSignals.publicInfoHash

            // check field for inputNullifiers
            let pos := add(proof, 480)
            let bytesLen := mul(calldataload(pos), 32) // inputNullifiers.length * 32
            pos := add(pos, 32) // inputNullifiers[0], if length > 0
            let end := add(bytesLen, pos)
            // solhint-disable-next-line no-empty-blocks
            for {

            } lt(pos, end) {
                pos := add(pos, 32)
            } {
                checkField(calldataload(pos))
            }

            // check field for outputCommitments
            bytesLen := mul(calldataload(pos), 32) // outputCommitments.length * 32
            pos := add(pos, 32) // outputCommitments[0], if length > 0
            end := add(bytesLen, pos)
            // solhint-disable-next-line no-empty-blocks
            for {

            } lt(pos, end) {
                pos := add(pos, 32)
            } {
                checkField(calldataload(pos))
            }

            let _pPairing := add(pMem, pPairing)
            let _pVk := add(pMem, pVk)

            // get fixed size vkey configs
            let IC0x, IC0y, IC1x, IC1y, IC2x, IC2y, IC3x, IC3y, IC4x, IC4y := getFixedSizeVkeys(_type)

            mstore(_pVk, IC0x)
            mstore(add(_pVk, 32), IC0y)

            // The pointer to the public signals, the first 32 bytes is the offset of the public signals
            let publicSignalsPos := add(proof, 256)
            // G1 point eliptic curve multiplications then accumulations
            // for fixed size public signals (root, publicInAmt, publicOutAmt, publicInfoHash)
            ecMulAcc(_pVk, IC1x, IC1y, calldataload(add(publicSignalsPos, 32))) // proof.publicSignals.root
            ecMulAcc(_pVk, IC2x, IC2y, calldataload(add(publicSignalsPos, 64))) // proof.publicSignals.publicInAmt
            ecMulAcc(_pVk, IC3x, IC3y, calldataload(add(publicSignalsPos, 96))) // proof.publicSignals.publicOutAmt
            ecMulAcc(_pVk, IC4x, IC4y, calldataload(add(publicSignalsPos, 128))) // proof.publicSignals.publicInfoHash

            // inputNullifiers absolute position (inputNullifiersPos)
            // = public signals start position + inputNullifiers offset relative to public signals start position
            let inputNullifiersPos := add(add(publicSignalsPos, 32), calldataload(add(proof, 416)))
            // outputCommitments absolute position (outputCommitmentsPos)
            // = public signals start position + outputCommitments offset relative to public signals start position
            let outputCommitmentsPos := add(add(publicSignalsPos, 32), calldataload(add(proof, 448)))
            dynamicEcMulAcc(_pVk, inputNullifiersPos, outputCommitmentsPos, _type)

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