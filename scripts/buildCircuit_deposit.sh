#!/bin/bash

BUILD_DIR=./build/circuits/deposit

if [ ! -d "$BUILD_DIR" ]; then
    echo "No build directory found. Creating build directory..."
    mkdir -p "$BUILD_DIR" 
fi

circom ./circuits/deposit.circom --r1cs --wasm --sym --c -o "$BUILD_DIR"

node "$BUILD_DIR"/deposit_js/generate_witness.js "$BUILD_DIR"/deposit_js/deposit.wasm ./test/circuit/deposit/input.json "$BUILD_DIR"/witness.wtns

snarkjs groth16 setup "$BUILD_DIR"/deposit.r1cs ./ptau/pot12_final.ptau "$BUILD_DIR"/deposit_0000.zkey

snarkjs zkey contribute "$BUILD_DIR"/deposit_0000.zkey "$BUILD_DIR"/deposit_0001.zkey --name="1st Contributor LFG!!" -v

snarkjs zkey export verificationkey "$BUILD_DIR"/deposit_0001.zkey "$BUILD_DIR"/verification_key.json

snarkjs groth16 prove "$BUILD_DIR"/deposit_0001.zkey "$BUILD_DIR"/witness.wtns "$BUILD_DIR"/proof.json "$BUILD_DIR"/public.json

snarkjs groth16 verify "$BUILD_DIR"/verification_key.json "$BUILD_DIR"/public.json "$BUILD_DIR"/proof.json


