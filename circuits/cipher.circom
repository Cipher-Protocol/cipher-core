pragma circom 2.1.6;

include "../node_modules/circomlib/circuits/comparators.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";
include "./merkleProof.circom";
include "./keypair.circom";
include "./signature.circom";

/*
commitment = hash(amount, pubKey, salt)
nullifier = hash(commitment, leafIdx, hash(privKey, commitment, leafIdx))
*/

// Universal JoinSplit transaction with n inputs and m outputs
template Cipher(levels, nIns, mOuts) {
    signal input root; // public
    signal input publicInAmt; // public
    signal input publicOutAmt; // public
    signal input publicInfoHash; // public

    // utxo input signals
    signal input inputNullifier[nIns]; // public
    signal input inAmount[nIns];
    signal input inPrivKey[nIns];
    signal input inSalt[nIns];
    signal input inPathIndices[nIns];
    signal input inPathElements[nIns][levels];

    // utxo output signals
    signal input outputCommitment[mOuts]; // public
    signal input outAmount[mOuts];
    signal input outPubkey[mOuts];
    signal input outSalt[mOuts];

    // internal calculation signals
    signal inPubKey[nIns];
    signal inCommitmentHash[nIns];
    signal inSignature[nIns];
    signal inNullifier[nIns];
    signal inTreeRoot[nIns];
    signal outCommitmentHash[mOuts];

    // initialize sumIns and sumOuts
    var sumIns = 0;
    var sumOuts = 0;

    // check public input amount greater than or equal to zero
    _ <== Num2Bits(252)(publicInAmt);
    signal signal_pub_in_gtEq <== GreaterEqThan(252)([publicInAmt,0]);
    signal_pub_in_gtEq === 1;

    // check public output amount greater than or equal to zero
    _ <== Num2Bits(252)(publicOutAmt);
    signal signal_pub_out_gtEq <== GreaterEqThan(252)([publicOutAmt,0]);
    signal_pub_out_gtEq === 1;


    // verify correctness of utxo inputs
    for (var i = 0; i < nIns; i++) {
        // calculate public key from input private key
        inPubKey[i] <== Keypair()(inPrivKey[i]);

        // calculate input commitment hash from input signal
        inCommitmentHash[i] <== Poseidon(3)([inAmount[i], inPubKey[i], inSalt[i]]);
        
        // calculate signature from input signal
        inSignature[i] <== Signature()(inPrivKey[i], inCommitmentHash[i], inPathIndices[i]);
        
        // calculate nullifier from input signal
        inNullifier[i] <== Poseidon(3)([inCommitmentHash[i], inPathIndices[i], inSignature[i]]);
        // check that nullifier matches the public input
        inNullifier[i] === inputNullifier[i];

        // calculate input root from input signal
        inTreeRoot[i] <== MerkleProof(levels)(inCommitmentHash[i], inPathElements[i], inPathIndices[i]);
        // check that calculated root matches the public input signal root if inAmount is not zero
        ForceEqualIfEnabled()(inAmount[i], [inTreeRoot[i], root]);

        // update sumIns
        sumIns += inAmount[i];
    }

    // verify correctness of utxo outputs
    for (var i = 0; i < mOuts; i++) {
        // calculate output commitment hash
        outCommitmentHash[i] <== Poseidon(3)([outAmount[i], outPubkey[i], outSalt[i]]);
        // check that output commitment hash matches the public input
        outCommitmentHash[i] === outputCommitment[i];
        // Check that amount fits into 248 bits to prevent overflow
        _ <== Num2Bits(248)(outAmount[i]);

        sumOuts += outAmount[i];
    }

    // check that nullifiers are not the same 
    signal sameNullifiers[nIns * (nIns - 1) / 2];
    var index = 0;
    for (var i = 0; i < nIns - 1; i++) {
      for (var j = i + 1; j < nIns; j++) {
            // check is not equal
            sameNullifiers[index] <== IsEqual()([inputNullifier[i], inputNullifier[j]]);
            sameNullifiers[index] === 0;
            index++;
      }
    }

    // verify amount invariant
    sumIns + publicInAmt === sumOuts + publicOutAmt;

    // optional safety constraint to make sure publicInfoHash cannot be changed
    signal publicInfoSquare <== publicInfoHash * publicInfoHash;
}