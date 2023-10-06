import { IncrementalQuinTree } from "@/scripts/lib/IncrementalQuinTree";
import { PoseidonHash } from "@/scripts/lib/poseidonHash";
import {
  generateCommitment,
  indicesToPathIndices,
  generateNullifier,
} from "@/scripts/lib/utxo.helper";
import { assert } from "chai";

export interface CipherCoinKey {
  inSaltOrSeed?: bigint;
  hashedSaltOrUserId: bigint;
  inRandom: bigint;
}

export interface CipherCoinInfo {
  key: CipherCoinKey;
  amount: bigint;
}

export class CipherBaseCoin {
  coinInfo!: CipherCoinInfo;

  constructor({ key, amount }: CipherCoinInfo, leafId: number) {
    this.coinInfo = {
      key,
      amount,
    };
    if (this.coinInfo.key.inSaltOrSeed) {
      const hashedSaltOrUserId = PoseidonHash([this.coinInfo.key.inSaltOrSeed]);
      assert(
        hashedSaltOrUserId === this.coinInfo.key.hashedSaltOrUserId,
        "hashedSaltOrUserId should be equal"
      );
    }
  }

  getCommitment() {
    return generateCommitment(
      this.coinInfo.amount,
      this.coinInfo.key.hashedSaltOrUserId,
      this.coinInfo.key.inRandom
    );
  }
}

export class CipherTransferableCoin extends CipherBaseCoin {
  readonly tree!: IncrementalQuinTree;
  readonly leafId!: number;

  constructor(
    coinInfo: CipherCoinInfo,
    tree: IncrementalQuinTree,
    leafId: number
  ) {
    super(coinInfo, leafId);
    this.tree = tree;
    this.leafId = leafId;
    // TODO: Implement only hashedSaltOrUserId
    assert(this.coinInfo.key.inSaltOrSeed, "privKey should not be null");
  }

  getPathIndices() {
    const { indices } = this.tree.genMerklePath(Number(this.leafId));
    return indicesToPathIndices(indices);
  }

  getPathElements() {
    const { pathElements } = this.tree.genMerklePath(Number(this.leafId));
    assert(
      pathElements.every((v) => v.length === 1),
      "pathElements each length should be 1"
    );
    return pathElements.map((v) => v[0]);
  }

  getNullifier() {
    assert(this.coinInfo.key.inSaltOrSeed, "inSaltOrSeed should not be null");
    const { indices } = this.tree.genMerklePath(this.leafId);
    const pathIndices = indicesToPathIndices(indices);
    const commitment = this.getCommitment();
    return generateNullifier(
      commitment,
      pathIndices,
      this.coinInfo.key.inSaltOrSeed
    );
  }
}
