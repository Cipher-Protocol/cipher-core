import { IncrementalQuinTree } from "../IncrementalQuinTree";
import { assert } from "../helper";
import { generateCommitment, generateNullifier, generateSignature, indicesToPathIndices } from "../utxo.helper";
import { CircuitUtxoTxInput, CircuitUtxoTxOutput } from "../../types/utxo-circuit.type";

export interface UtxoCoinKey {
  privKey?: bigint;
  pubKey: bigint;
  salt: bigint;
}

export interface UtxoCoinInfo {
  key: UtxoCoinKey;
  amount: bigint;
}

export class UtxoBaseCoin {
  coinInfo!: UtxoCoinInfo;

  constructor({
    key,
    amount,
  }: UtxoCoinInfo) {
    this.coinInfo = {
      key,
      amount,
    };
  }

  getCommitment() {
    return generateCommitment(this.coinInfo.amount, this.coinInfo.key.pubKey, this.coinInfo.key.salt);
  }

  toUtxoTxOutput(): CircuitUtxoTxOutput {
    return {
      outputCommitment: this.getCommitment(),
      outAmount: this.coinInfo.amount,
      outPubkey: this.coinInfo.key.pubKey,
      outSalt: this.coinInfo.key.salt,
    }
  }
}

export class UtxoPayableCoin extends UtxoBaseCoin {
  readonly tree!: IncrementalQuinTree;
  readonly leafId!: number;

  constructor(coinInfo: UtxoCoinInfo, tree: IncrementalQuinTree, leafId: number) {
    super(coinInfo);
    this.tree = tree;

    // TODO: get leafId from tree by commitmentHash
    this.leafId = leafId;
    assert(this.coinInfo.key.privKey, "privKey should not be null");
  }

  getPathIndices() {
    const { indices, } = this.tree.genMerklePath(Number(this.leafId));
    return indicesToPathIndices(indices);
  }

  getNullifier() {
    assert(this.coinInfo.key.privKey, "privKey should not be null");
    const { indices, } = this.tree.genMerklePath(this.leafId);
    const pathIndices = indicesToPathIndices(indices);
    const commitment = this.getCommitment();
    const signature = generateSignature(this.tree, pathIndices, commitment, this.coinInfo.key.privKey)
    return generateNullifier(commitment, pathIndices, signature);
  }

  toUtxoTxInput(): CircuitUtxoTxInput {
    assert(this.coinInfo.key.privKey, "privKey should not be null");
    const inputNullifier = this.getNullifier();
    const { indices, pathElements } = this.tree.genMerklePath(this.leafId);
    const inPathIndices = indicesToPathIndices(indices);
    assert(pathElements.every(v => v.length === 1), "pathElements each length should be 1");
    const inPathElements = pathElements.map(v => v[0]);
      return {
        inputNullifier,
        inAmount: this.coinInfo.amount,
        inPrivKey: this.coinInfo.key.privKey,
        inSalt: this.coinInfo.key.salt,
        inPathIndices,
        inPathElements,
      }
  }
}