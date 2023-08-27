#!/bin/bash

BUILD_DIR=./build/circuits/withdraw

if [ ! -d "$BUILD_DIR" ]; then
    echo "No build directory found. Creating build directory..."
    mkdir -p "$BUILD_DIR" 
fi

circom ./circuits/withdraw.circom --r1cs --wasm --sym --c -o ./build/circuits/withdraw

node ./build/circuits/withdraw/withdraw_js/generate_witness.js ./build/circuits/withdraw/withdraw_js/withdraw.wasm ./test/circuit/withdraw/input.json ./build/circuits/withdraw/witness.wtns

snarkjs groth16 setup ./build/circuits/withdraw/withdraw.r1cs ./ptau/pot14_final.ptau ./build/circuits/withdraw/withdraw_0000.zkey

snarkjs zkey contribute ./build/circuits/withdraw/withdraw_0000.zkey ./build/circuits/withdraw/withdraw_0001.zkey --name="1st Contributor LFG!!" -v

snarkjs zkey export verificationkey ./build/circuits/withdraw/withdraw_0001.zkey ./build/circuits/withdraw/verification_key.json

snarkjs groth16 prove ./build/circuits/withdraw/withdraw_0001.zkey ./build/circuits/withdraw/witness.wtns ./build/circuits/withdraw/proof.json ./build/circuits/withdraw/public.json

snarkjs groth16 verify ./build/circuits/withdraw/verification_key.json ./build/circuits/withdraw/public.json ./build/circuits/withdraw/proof.json


