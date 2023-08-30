pragma circom 2.1.6;

include "../node_modules/circomlib/circuits/comparators.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";
include "./merkleProof.circom";
include "./keypair.circom";

/*
Utxo structure:
{
    amount,
    pubkey,
    salt
}

commitment = hash(amount, pubKey, salt)
nullifier = hash(commitment, merklePath, sign(privKey, commitment, merklePath))
*/

// Universal JoinSplit transaction with nIns inputs and 2 outputs
template Utxo(levels, nIns, nOuts, zeroLeaf) {
    signal input root; // public
    // extAmount = external amount used for deposits and withdrawals
    // correct extAmount range is enforced on the smart contract

    signal input publicInAmt; // public
    signal input publicOutAmt; // public
    signal input extDataHash; // public

    // data for transaction inputs
    signal input inputNullifier[nIns]; // public
    signal input inAmount[nIns];
    signal input inPrivateKey[nIns];
    signal input inSalt[nIns];
    signal input inPathIndices[nIns];
    signal input inPathElements[nIns][levels];

    // data for transaction outputs
    signal input outputCommitment[nOuts]; // public
    signal input outAmount[nOuts];
    signal input outPubkey[nOuts];
    signal input outSalt[nOuts];

    component inKeypair[nIns];
    component inSignature[nIns];
    component inCommitmentHasher[nIns];
    component inNullifierHasher[nIns];
    component inTree[nIns];
    component inCheckRoot[nIns];

    component publicInAmtCheck;
    component publicOutAmtCheck;

    // check public input amount greater than or equal to zero
    // publicInAmtCheck = GreaterEqThan(252);
    // publicInAmtCheck.in[0] <== publicInAmt;
    // publicInAmtCheck.in[1] <== 0;
    // publicInAmtCheck.out === 1;
    publicInAmtCheck = LessThan(252);
    publicInAmtCheck.in[0] <== publicInAmt;
    publicInAmtCheck.in[1] <== 0;
    publicInAmtCheck.out === 0;

    // check public output amount greater than or equal to zero
    // publicOutAmtCheck = GreaterEqThan(252);
    // publicOutAmtCheck.in[0] <== publicOutAmt;
    // publicOutAmtCheck.in[1] <== 0;
    // publicOutAmtCheck.out === 1;
    publicOutAmtCheck = LessThan(252);
    publicOutAmtCheck.in[0] <== publicOutAmt;
    publicOutAmtCheck.in[1] <== 0;
    publicOutAmtCheck.out === 0;

    var sumIns = 0;
    // verify correctness of transaction inputs
    for (var tx = 0; tx < nIns; tx++) {
        inKeypair[tx] = Keypair();
        inKeypair[tx].privateKey <== inPrivateKey[tx];

        inCommitmentHasher[tx] = Poseidon(3);
        inCommitmentHasher[tx].inputs[0] <== inAmount[tx];
        inCommitmentHasher[tx].inputs[1] <== inKeypair[tx].publicKey;
        inCommitmentHasher[tx].inputs[2] <== inSalt[tx];

        inSignature[tx] = Signature();
        inSignature[tx].privateKey <== inPrivateKey[tx];
        inSignature[tx].commitment <== inCommitmentHasher[tx].out;
        inSignature[tx].merklePath <== inPathIndices[tx];

        inNullifierHasher[tx] = Poseidon(3);
        inNullifierHasher[tx].inputs[0] <== inCommitmentHasher[tx].out;
        inNullifierHasher[tx].inputs[1] <== inPathIndices[tx];
        inNullifierHasher[tx].inputs[2] <== inSignature[tx].out;
        inNullifierHasher[tx].out === inputNullifier[tx];

        inTree[tx] = MerkleProof(levels);
        inTree[tx].leaf <== inCommitmentHasher[tx].out;
        inTree[tx].pathIndices <== inPathIndices[tx];
        for (var i = 0; i < levels; i++) {
            inTree[tx].pathElements[i] <== inPathElements[tx][i];
        }

        // check merkle proof only if amount is non-zero
        inCheckRoot[tx] = ForceEqualIfEnabled();
        inCheckRoot[tx].in[0] <== root;
        inCheckRoot[tx].in[1] <== inTree[tx].root;
        inCheckRoot[tx].enabled <== inAmount[tx];

        // We don't need to range check input amounts, since all inputs are valid UTXOs that
        // were already checked as outputs in the previous transaction (or zero amount UTXOs that don't
        // need to be checked either).

        sumIns += inAmount[tx];
    }

    component outCommitmentHasher[nOuts];
    component outAmountCheck[nOuts];
    var sumOuts = 0;

    // verify correctness of transaction outputs
    for (var tx = 0; tx < nOuts; tx++) {
        outCommitmentHasher[tx] = Poseidon(3);
        outCommitmentHasher[tx].inputs[0] <== outAmount[tx];
        outCommitmentHasher[tx].inputs[1] <== outPubkey[tx];
        outCommitmentHasher[tx].inputs[2] <== outSalt[tx];
        outCommitmentHasher[tx].out === outputCommitment[tx];

        // Check that amount fits into 248 bits to prevent overflow
        outAmountCheck[tx] = Num2Bits(248);
        outAmountCheck[tx].in <== outAmount[tx];

        sumOuts += outAmount[tx];
    }

    // check that there are no same nullifiers among all inputs
    component sameNullifiers[nIns * (nIns - 1) / 2];
    var index = 0;
    for (var i = 0; i < nIns - 1; i++) {
      for (var j = i + 1; j < nIns; j++) {
          sameNullifiers[index] = IsEqual();
          sameNullifiers[index].in[0] <== inputNullifier[i];
          sameNullifiers[index].in[1] <== inputNullifier[j];
          sameNullifiers[index].out === 0;
          index++;
      }
    }

    // verify amount invariant
    sumIns + publicInAmt === sumOuts + publicOutAmt;

    // optional safety constraint to make sure extDataHash cannot be changed
    signal extDataSquare <== extDataHash * extDataHash;
}