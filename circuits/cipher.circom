pragma circom 2.1.6;

include "../node_modules/circomlib/circuits/comparators.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";
include "./merkleProof.circom";
include "./signature.circom";

/*
commitment = hash(amount, hashedSaltOrUserId, random)
nullifier = hash(commitment, leafIdx, saltOrSeed)
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
    // seed = sign(msg) by user's EOA
    // salt for keeping cipher transferable, seed for a specified user
    signal input inSaltOrSeed[nIns]; 
    signal input inRandom[nIns];
    signal input inPathIndices[nIns];
    signal input inPathElements[nIns][levels];

    // utxo output signals
    signal input outputCommitment[mOuts]; // public
    signal input outAmount[mOuts];
    signal input outHashedSaltOrUserId[mOuts]; // output hashed salt or UserId
    signal input outRandom[mOuts];

    // internal calculation signals
    // UserId = hash(seed)
    signal inHashedSaltOrUserId[nIns];
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
        // calculate hashed salt or UserId from input salt or seed
        inHashedSaltOrUserId[i] <== Poseidon(1)([inSaltOrSeed[i]]);

        // calculate input commitment hash from input signal
        inCommitmentHash[i] <== Poseidon(3)([inAmount[i], inHashedSaltOrUserId[i], inRandom[i]]);
        
        //TODO: check why need this?
        // calculate signature from input signal
        // inSignature[i] <== Signature()(inSaltOrSeed[i], inCommitmentHash[i], inPathIndices[i]);
        // inNullifier[i] <== Poseidon(3)([inCommitmentHash[i], inPathIndices[i], inSignature[i]]);
        
        // calculate nullifier from input signal
        inNullifier[i] <== Poseidon(3)([inCommitmentHash[i], inPathIndices[i], inSaltOrSeed[i]]);
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
        outCommitmentHash[i] <== Poseidon(3)([outAmount[i], outHashedSaltOrUserId[i], outRandom[i]]);
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