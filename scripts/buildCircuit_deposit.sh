#!/bin/bash

BUILD_DIR=./build/circuits/deposit

if [ ! -d "$BUILD_DIR" ]; then
    echo "No build directory found. Creating build directory..."
    mkdir -p "$BUILD_DIR" 
fi

circom ./circuits/deposit.circom --r1cs --wasm --sym --c -o ./build/circuits/deposit

node ./build/circuits/deposit/deposit_js/generate_witness.js ./build/circuits/deposit/deposit_js/deposit.wasm ./test/circuit/deposit/input.json ./build/circuits/deposit/witness.wtns

snarkjs groth16 setup ./build/circuits/deposit/deposit.r1cs ./ptau/pot12_final.ptau ./build/circuits/deposit/deposit_0000.zkey

snarkjs zkey contribute ./build/circuits/deposit/deposit_0000.zkey ./build/circuits/deposit/deposit_0001.zkey --name="1st Contributor LFG!!" -v

snarkjs zkey export verificationkey ./build/circuits/deposit/deposit_0001.zkey ./build/circuits/deposit/verification_key.json

snarkjs groth16 prove ./build/circuits/deposit/deposit_0001.zkey ./build/circuits/deposit/witness.wtns ./build/circuits/deposit/proof.json ./build/circuits/deposit/public.json

snarkjs groth16 verify ./build/circuits/deposit/verification_key.json ./build/circuits/deposit/public.json ./build/circuits/deposit/proof.json


