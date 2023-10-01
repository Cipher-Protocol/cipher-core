export interface CircuitUtxoTxInput {
  inputNullifier: bigint;
  inAmount: bigint;
  inPrivKey: bigint;
  inSalt: bigint;
  inPathIndices: bigint;
  inPathElements: bigint[];
}

export interface CircuitUtxoTxOutput {
  outputCommitment: bigint;
  outAmount: bigint;
  outPubkey: bigint;
  outSalt: bigint;
}

export interface CircuitUtxoTxBase {
  root: bigint;
  publicInAmt: bigint;
  publicOutAmt: bigint;
  extDataHash: bigint;
}

export interface CircuitUtxoTransaction {
  base: CircuitUtxoTxBase;
  input: CircuitUtxoTxInput[];
  output: CircuitUtxoTxOutput[];
}
