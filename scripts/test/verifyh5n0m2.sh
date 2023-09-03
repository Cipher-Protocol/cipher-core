#!/bin/bash

BUILD_DIR=./build/circuits/test/h5n0m2

if [ ! -d "$BUILD_DIR" ]; then
    echo "No build directory found. Creating build directory..."
    mkdir -p "$BUILD_DIR" 
fi

circom ./circuits/test/h5n0m2.circom --r1cs --wasm --sym --c -o "$BUILD_DIR"

node "$BUILD_DIR"/h5n0m2_js/generate_witness.js "$BUILD_DIR"/h5n0m2_js/h5n0m2.wasm ./test/circuit/h5n0m2/input.json "$BUILD_DIR"/witness.wtns

snarkjs groth16 setup "$BUILD_DIR"/h5n0m2.r1cs ./ptau/pot12_final.ptau "$BUILD_DIR"/h5n0m2_0000.zkey

snarkjs zkey contribute "$BUILD_DIR"/h5n0m2_0000.zkey "$BUILD_DIR"/h5n0m2_0001.zkey --name="1st Contributor LFG!!" -e="some random text"

snarkjs zkey export verificationkey "$BUILD_DIR"/h5n0m2_0001.zkey "$BUILD_DIR"/verification_key.json

snarkjs groth16 prove "$BUILD_DIR"/h5n0m2_0001.zkey "$BUILD_DIR"/witness.wtns "$BUILD_DIR"/proof.json "$BUILD_DIR"/public.json

snarkjs groth16 verify "$BUILD_DIR"/verification_key.json "$BUILD_DIR"/public.json "$BUILD_DIR"/proof.json

snarkjs zkey export solidityverifier "$BUILD_DIR"/h5n0m2_0001.zkey "$BUILD_DIR"/h5n0m2Verifier.sol