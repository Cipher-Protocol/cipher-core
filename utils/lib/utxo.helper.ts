import { BigNumber, utils } from "ethers";
import { SNARK_FIELD_SIZE } from "../../config";
import { PoseidonHash } from "./poseidonHash";
import { IncrementalQuinTree } from "./IncrementalQuinTree";
import { assert } from "./helper";
export const FIELD_SIZE_BIGINT = BigInt(SNARK_FIELD_SIZE);

export function getUtxoType(nIn: number, mOut: number): string {
  if (isNaN(nIn) || isNaN(mOut)) {
    throw new Error(`Invalid nNum=${nIn}, mNum=${mOut}`);
  }

  if (nIn < 0 || nIn > 255) {
    throw new Error(`Invalid nNum=${nIn}, should be 0 ~ 255`);
  }

  if (mOut < 0 || mOut > 255) {
    throw new Error(`Invalid mNum=${mOut}, should be 0 ~ 255`);
  }

  const nHex = nIn.toString().padStart(2, "0");
  const mHex = mOut.toString().padStart(2, "0");

  const hexCode = `0x${nHex}${mHex}`;
  return hexCode;
}

export function getPublicKey(privateKey: bigint) {
  return PoseidonHash([privateKey]);
}

export function getAmountHash(amount: string): BigNumber {
  return BigNumber.from(
    utils.keccak256(
      utils.defaultAbiCoder.encode(["uint256"], [BigNumber.from(amount)])
    )
  ).mod(BigNumber.from(SNARK_FIELD_SIZE));
}

export function generateCommitment(
  amount: bigint,
  publicKey: bigint,
  salt: bigint
) {
  assert(amount <= FIELD_SIZE_BIGINT, "amount is too large");
  assert(publicKey <= FIELD_SIZE_BIGINT, "publicKey is too large");
  assert(salt <= FIELD_SIZE_BIGINT, "salt is too large");

  const commitmentHash = PoseidonHash([amount, publicKey, salt]);
  return commitmentHash;
}

export function generateSignature(
  tree: IncrementalQuinTree,
  indices: bigint,
  commitment: bigint,
  privateKey: bigint
) {
  const signature = PoseidonHash([privateKey, commitment, indices]);
  return signature;
}

export function generateNullifier(
  commitment: bigint,
  indices: bigint,
  signature: bigint
) {
  const nullifier = PoseidonHash([commitment, indices, signature]);
  return nullifier;
}

export function indicesToPathIndices(indices: number[]): bigint {
  // pathIndices bits is an array of 0/1 selectors telling whether given pathElement is on the left or right side of merkle path
  let binaryString = "";
  for (const index of indices) {
    // Assuming 0 for left and 1 for right
    binaryString += index % 2 === 0 ? "0" : "1";
  }
  // reverse
  binaryString = binaryString.split("").reverse().join("");
  return BigInt("0b" + binaryString);
}
