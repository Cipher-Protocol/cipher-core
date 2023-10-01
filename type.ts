export type Note = {
  amount: string;
  pubkey: string;
  salt: string;
};

export type SignatureInputArgs = {
  privateKey: string;
  commitment: string;
  merklePath: string;
};

export type NullifierInputArgs = {
  commitment: string;
  merklePath: string;
  signature: string;
};

export type CipherCircuitInputArgs = {
  root: string;
  publicInAmt: string;
  publicOutAmt: string;
  publicInfoHash: string;
  inputNullifier: string[];
  inAmount: string[];
  inPrivateKey: string[];
  inSalt: string[];
  inPathIndices: string[];
  inPathElements: string[][];
  outputCommitment: string[];
  outAmount: string[];
  outPubkey: [string];
  outSalt: string[];
};
