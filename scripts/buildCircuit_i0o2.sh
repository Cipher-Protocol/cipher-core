mkdir -p ./build
mkdir -p ./build/utxo_i0o2

circom ./circuits/utxo.circom --r1cs --wasm --sym --c -o ./build/utxo_i0o2

node ./build/utxo_i0o2/utxo_js/generate_witness.js ./build/utxo_i0o2/utxo_js/utxo.wasm ./test/circuit/utxo_i0o2/input.json ./build/utxo_i0o2/witness.wtns

snarkjs groth16 setup ./build/utxo_i0o2/utxo.r1cs ./ptau/pot12_final.ptau ./build/utxo_i0o2/utxo_i0o2_0000.zkey

snarkjs zkey contribute ./build/utxo_i0o2/utxo_i0o2_0000.zkey ./build/utxo_i0o2/utxo_i0o2_0001.zkey --name="1st Contributor LFG!!" -v

snarkjs zkey export verificationkey ./build/utxo_i0o2/utxo_i0o2_0001.zkey ./build/utxo_i0o2/verification_key.json

snarkjs groth16 prove ./build/utxo_i0o2/utxo_i0o2_0001.zkey ./build/utxo_i0o2/witness.wtns ./build/utxo_i0o2/proof.json ./build/utxo_i0o2/public.json

snarkjs groth16 verify ./build/utxo_i0o2/verification_key.json ./build/utxo_i0o2/public.json ./build/utxo_i0o2/proof.json


