#!/bin/bash

BUILD_DIR=./build/circuits

//TODO: for loop to run all following commands for all circuits
for {
  circom ./build/circuits/${...}.circom --r1cs --wasm --sym --c -o "$BUILD_DIR"/${...}

  snarkjs groth16 setup "$BUILD_DIR"/${...}/${...}.r1cs ./ptau/pot12_final.ptau "$BUILD_DIR"/${...}/${...}_0000.zkey

  snarkjs zkey contribute "$BUILD_DIR"/${...}/${...}_0000.zkey "$BUILD_DIR"/${...}/${...}_0001.zkey --name="1st Contributor LFG!!" -e="some random text"

  snarkjs zkey export solidityverifier "$BUILD_DIR"/${...}/${...}_0001.zkey "$BUILD_DIR"/${...}/${...}Verifier.sol
}