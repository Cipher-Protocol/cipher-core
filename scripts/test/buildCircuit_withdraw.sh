#!/bin/bash

BUILD_DIR=./build/circuits/withdraw

if [ ! -d "$BUILD_DIR" ]; then
    echo "No build directory found. Creating build directory..."
    mkdir -p "$BUILD_DIR" 
fi

circom ./circuits/withdraw.circom --r1cs --wasm --sym --c -o "$BUILD_DIR"

node "$BUILD_DIR"/withdraw_js/generate_witness.js "$BUILD_DIR"/withdraw_js/withdraw.wasm ./test/circuit/withdraw/input.json "$BUILD_DIR"/witness.wtns

snarkjs groth16 setup "$BUILD_DIR"/withdraw.r1cs ./ptau/pot14_final.ptau "$BUILD_DIR"/withdraw_0000.zkey

snarkjs zkey contribute "$BUILD_DIR"/withdraw_0000.zkey "$BUILD_DIR"/withdraw_0001.zkey --name="1st Contributor LFG!!" -e="some random text"

snarkjs zkey export verificationkey "$BUILD_DIR"/withdraw_0001.zkey "$BUILD_DIR"/verification_key.json

snarkjs groth16 prove "$BUILD_DIR"/withdraw_0001.zkey "$BUILD_DIR"/witness.wtns "$BUILD_DIR"/proof.json "$BUILD_DIR"/public.json

snarkjs groth16 verify "$BUILD_DIR"/verification_key.json "$BUILD_DIR"/public.json "$BUILD_DIR"/proof.json

snarkjs zkey export solidityverifier "$BUILD_DIR"/withdraw_0001.zkey "$BUILD_DIR"/withdrawVerifier.sol
