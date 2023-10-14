import { writeFileSync } from "fs";
import { resolve } from "path";
import {
  CipherCoinInfo,
  CipherTransferableCoin,
  CipherBaseCoin,
} from "./CipherCoin";
import { toDecimalStringObject } from "../helper";
import { PoseidonHash } from "../poseidonHash";
import { FIELD_SIZE_BIGINT } from "../utxo.helper";
import { proveByName } from "../../prove";
import {
  PublicInfoStruct,
  ProofStruct,
} from "../../../typechain-types/contracts/Cipher";
import { assert } from "chai";
import { utils, BigNumber } from "ethers";
import { IncrementalQuinTree } from "../IncrementalQuinTree";

export const ethTokenAddress = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE";

/** Methods */
export function initTree(depth: number, zeroLeaf: string): IncrementalQuinTree {
  const _leavesPerNode = 2;
  const tree = new IncrementalQuinTree(
    depth,
    BigInt(zeroLeaf),
    _leavesPerNode,
    PoseidonHash
  );
  return tree;
}

export function getCoinInfoFromAmt(
  amt: bigint,
  {
    inRandom,
    inSaltOrSeed,
  }: {
    inRandom: bigint;
    inSaltOrSeed: bigint;
  }
) {
  const coinInfo: CipherCoinInfo = {
    key: {
      inSaltOrSeed,
      hashedSaltOrUserId: PoseidonHash([inSaltOrSeed]),
      inRandom,
    },
    amount: amt,
  };
  return coinInfo;
}

export function createCoin(
  tree: IncrementalQuinTree,
  {
    amount,
    inRandom,
    inSaltOrSeed,
  }: {
    amount: bigint;
    inRandom: bigint;
    inSaltOrSeed: bigint;
  }
) {
  const coinInfo = getCoinInfoFromAmt(amount, {
    inRandom,
    inSaltOrSeed,
  });
  const leafId = tree.nextIndex;
  return new CipherTransferableCoin(coinInfo, tree, leafId);
}

export interface CipherTxRequest {
  publicInAmt: bigint;
  publicOutAmt: bigint;
  privateInCoins: CipherTransferableCoin[];
  privateOutCoins: CipherBaseCoin[];
}

// TODO: parameters: publicInfo
export async function generateCipherTx(
  tree: IncrementalQuinTree,
  {
    publicInAmt,
    publicOutAmt,
    privateInCoins,
    privateOutCoins,
  }: CipherTxRequest,
  publicInfo: PublicInfoStruct
) {
  const transferableCoins: CipherTransferableCoin[] = [];
  const currentRoot = tree.root;

  const totalPrivateInAmount = privateInCoins.reduce(
    (acc, coin) => acc + coin.coinInfo.amount,
    0n
  );
  const totalPrivateOutAmount = privateOutCoins.reduce(
    (acc, coin) => acc + coin.coinInfo.amount,
    0n
  );
  assert(
    publicInAmt + totalPrivateInAmount === publicOutAmt + totalPrivateOutAmount,
    "inAmounts and outAmounts are not balanced"
  );

  const privateInputLength = privateInCoins.length;
  const privateOutputLength = privateOutCoins.length;

  for (let i = 0; i < privateInputLength; i++) {
    const ins = privateInCoins[i];
    const inSaltOrSeed = ins.coinInfo.key.inSaltOrSeed as bigint;
    const hashedSaltOrUserId = PoseidonHash([inSaltOrSeed]);
    const commitment = PoseidonHash([
      ins.coinInfo.amount,
      hashedSaltOrUserId,
      ins.coinInfo.key.inRandom,
    ]);
    assert(
      commitment === tree.leaves[ins.leafId],
      "privateInCoins commitment is not in the tree"
    );
  }

  const circuitUtxoInput = {
    // Coin Inputs
    inputNullifier: privateInCoins.map((coin) => coin.getNullifier()),
    inAmount: privateInCoins.map((coin) => coin.coinInfo.amount),
    inSaltOrSeed: privateInCoins.map((coin) => coin.coinInfo.key.inSaltOrSeed),
    inRandom: privateInCoins.map((coin) => coin.coinInfo.key.inRandom),
    inPathIndices: privateInCoins.map((coin) => coin.getPathIndices()),
    inPathElements: privateInCoins.map((coin) => coin.getPathElements()),
  };

  for (let index = 0; index < privateOutputLength; index++) {
    const coin = privateOutCoins[index];
    assert(coin.coinInfo.key.inRandom, "inRandom should not be null");
    assert(coin.coinInfo.key.inSaltOrSeed, "inSaltOrSeed should not be null");
    const coinInfo = getCoinInfoFromAmt(coin.coinInfo.amount, {
      inRandom: coin.coinInfo.key.inRandom,
      inSaltOrSeed: coin.coinInfo.key.inSaltOrSeed,
    });
    const leafId = tree.nextIndex;
    const payableCoin = new CipherTransferableCoin(coinInfo, tree, leafId);
    tree.insert(payableCoin.getCommitment());
    transferableCoins.push(payableCoin);
  }
  const circuitUtxoOutput = {
    // Coin Outputs
    outputCommitment: transferableCoins.map((coin) => coin.getCommitment()),
    outAmount: transferableCoins.map((coin) => coin.coinInfo.amount),
    outHashedSaltOrUserId: transferableCoins.map(
      (coin) => coin.coinInfo.key.hashedSaltOrUserId
    ),
    outRandom: transferableCoins.map((coin) => coin.coinInfo.key.inRandom),
  };
  /** Circuit input */
  const publicInfoHash = toPublicInfoHash(publicInfo);
  const circuitInput = {
    root: currentRoot,
    publicInAmt,
    publicOutAmt,
    publicInfoHash: BigInt(publicInfoHash),
    ...circuitUtxoInput,
    ...circuitUtxoOutput,
  };

  /** Prove */
  const circuitName = `h${tree.depth}n${privateInputLength}m${privateOutputLength}`;
  const heightName = `h${tree.depth}`;
  const specName = `n${privateInputLength}m${privateOutputLength}`;
  const circomBaseDir = resolve(
    __dirname,
    `../../../build/circuits/${heightName}/${specName}`
  );
  const inputPath = resolve(circomBaseDir, "input.json");
  writeFileSync(
    inputPath,
    JSON.stringify(toDecimalStringObject(circuitInput), null, 2)
  );
  const { calldata } = await proveByName(circuitName, inputPath);

  /** Contract calldata */
  const utxoData: ProofStruct = {
    a: calldata[0],
    b: calldata[1],
    c: calldata[2],
    publicSignals: {
      root: utils.hexlify(currentRoot),
      publicInAmt: publicInAmt.toString(),
      publicOutAmt: publicOutAmt.toString(),
      publicInfoHash,
      inputNullifiers: privateInCoins.map((coin) =>
        utils.hexlify(coin.getNullifier())
      ),
      outputCommitments: transferableCoins.map((coin) =>
        utils.hexlify(coin.getCommitment())
      ),
    },
  };

  return {
    tree,
    privateInputLength,
    privateOutputLength,
    transferableCoins,
    circuitInput,
    currentRoot,
    newRoot: tree.root,
    contractCalldata: {
      utxoData,
      publicInfo,
    },
  };
}

function toPublicInfoHash(publicInfo: PublicInfoStruct) {
  const data = utils.defaultAbiCoder.encode(
    ["uint16", "address", "address", "uint32"],
    [
      publicInfo.maxAllowableFeeRate,
      publicInfo.recipient,
      publicInfo.token,
      publicInfo.deadline,
    ]
  );
  return utils.hexlify(
    BigNumber.from(utils.keccak256(data)).mod(FIELD_SIZE_BIGINT)
  );
}
