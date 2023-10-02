import { writeFileSync } from "fs";
import { BigNumber, utils } from "ethers";
import utxoConfig from "../utxo_config.json";
import { IncrementalQuinTree } from "./lib/IncrementalQuinTree";
import { DEFAULT_TREE_HEIGHT } from "../config";
import { PoseidonHash, asyncPoseidonHash } from "./lib/poseidonHash";
import {
  FIELD_SIZE_BIGINT,
  getDefaultLeaf,
  getPublicKey,
  getUtxoType,
} from "./lib/utxo.helper";
import { UtxoCoinInfo, UtxoPayableCoin } from "./lib/utxo/coin";
import { Cipher } from "../typechain-types";
import { resolve } from "path";
import { proveByName } from "./prove";
import { toDecimalStringObject } from "./lib/helper";

const ethTokenAddress = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE";

const SPEC = {
  treeHeight: DEFAULT_TREE_HEIGHT,
  defaultLeafHash: getDefaultLeaf(ethTokenAddress).toString(),
};

async function main() {
  await asyncPoseidonHash;

  const tree = initTree(SPEC.treeHeight, SPEC.defaultLeafHash);
  console.log({
    root: tree.root,
    SPEC,
    utxoConfig,
  });

  const decimals = BigNumber.from(10).pow(18);
  const { circuitInput, contractCalldata } = await genTxForZeroIn(tree, [
    BigInt(BigNumber.from("1").mul(decimals).mod(10).toString()), // 0.1 ETH
    BigInt(BigNumber.from("2").mul(decimals).mod(10).toString()), // 0.2 ETH
  ]);

  console.log({
    circuitInput,
    contractCalldata,
  });
  console.log("done");
}

// main()
//   .then(() => process.exit(0))
//   .catch((error) => {
//     console.error(error);
//     process.exit(1);
//   });

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

export function getRandomAmtCoinInfo(privKey: bigint, salt: bigint) {
  const decimal = BigNumber.from(10).pow(18);
  const randomAmt = BigNumber.from(Math.floor(Math.random() * 10)).mul(decimal); // 0 ~ 9 ETH
  const coinInfo: UtxoCoinInfo = {
    key: {
      privKey,
      pubKey: getPublicKey(privKey),
      salt,
    },
    amount: BigInt(randomAmt.toString()),
  };
  return coinInfo;
}

export function getCoinInfoFromAmt(amt: bigint, privKey: bigint, salt: bigint) {
  const coinInfo: UtxoCoinInfo = {
    key: {
      privKey,
      pubKey: getPublicKey(privKey),
      salt,
    },
    amount: amt,
  };
  return coinInfo;
}

export async function genTxForZeroIn(
  tree: IncrementalQuinTree,
  outAmts: bigint[]
) {
  const coins: UtxoPayableCoin[] = [];
  const previousRoot = tree.root;

  // TODO: How to get privKey and salt?
  const privKey = 1n;
  const salt = 2n;

  const outputLength = outAmts.length;

  for (let index = 0; index < outputLength; index++) {
    const coinInfo = getCoinInfoFromAmt(outAmts[index], privKey, salt);
    const leafId = tree.nextIndex;
    const payableCoin = new UtxoPayableCoin(coinInfo, tree, leafId);
    tree.insert(payableCoin.getCommitment());
    coins.push(payableCoin);
    console.log({
      coinInfo,
      nextIndex: tree.nextIndex,
      root: tree.root,
    });
  }

  const publicInAmt = coins.reduce((acc, item) => {
    return acc + item.coinInfo.amount;
  }, 0n); // deposit amount

  const latestRoot = tree.root;
  const publicInfo: Cipher.PublicInfoStruct = {
    utxoType: getUtxoType(0, outputLength),
    recipient: "0x0000000000000000000000000000000000000000", // no out
    relayer: "0x0000000000000000000000000000000000000000", // no fee
    fee: "0",
    data: utils.defaultAbiCoder.encode(["address"], [ethTokenAddress]),
  };

  /** Circuit input */
  const publicInfoHash = toPublicInfoHash(publicInfo);

  const circuitInput = {
    root: latestRoot,
    publicInAmt,
    publicOutAmt: 0n,
    publicInfoHash: BigInt(publicInfoHash),

    // 0 Inputs
    inRandom: [],
    inSaltOrSeed: [],
    inputNullifier: [],
    inAmount: [],
    inPathIndices: [],
    inPathElements: [],

    // outNumber outputs
    outputCommitment: coins.map((coin) => coin.getCommitment()),
    outAmount: coins.map((coin) => coin.coinInfo.amount),
    outSaltOrSeed: coins.map((coin) => coin.coinInfo.key.pubKey),
    outRandom: coins.map((coin) => coin.coinInfo.key.salt),
  };

  /** Prove */
  const circuitName = `h${tree.depth}n0m${outputLength}`;
  const heightName = circuitName.slice(0, 2);
  const specName = circuitName.slice(2, 6);
  const circomBaseDir = resolve(
    __dirname,
    `../build/circuits/${heightName}/${specName}`
  );
  const inputPath = resolve(circomBaseDir, "input.json");
  writeFileSync(
    inputPath,
    JSON.stringify(toDecimalStringObject(circuitInput), null, 2)
  );
  console.log({
    message: "input.json generated",
    circuitName,
    inputPath,
  });
  const { calldata } = await proveByName(circuitName, inputPath);

  /** Contract calldata */

  const utxoData: Cipher.UtxoDataStruct = {
    proof: {
      a: calldata[0],
      b: calldata[1],
      c: calldata[2],
      publicSignals: calldata[3],
    },
    root: utils.hexlify(previousRoot),
    publicInAmt: publicInAmt.toString(),
    publicOutAmt: "0",
    publicInfoHash,
    inputNullifiers: [], // no input
    outputCommitments: coins.map((coin) => coin.getCommitment().toString()),
  };

  return {
    tree,
    circuitInput,
    contractCalldata: {
      utxoData,
      publicInfo,
    },
  };
}

function toPublicInfoHash(publicInfo: Cipher.PublicInfoStruct) {
  const data = utils.defaultAbiCoder.encode(
    ["tuple(bytes2,address,address,uint256,bytes)"],
    [
      [
        publicInfo.utxoType,
        publicInfo.recipient,
        publicInfo.relayer,
        publicInfo.fee,
        publicInfo.data,
      ],
    ]
  );
  return utils.hexlify(
    BigNumber.from(utils.keccak256(data)).mod(FIELD_SIZE_BIGINT)
  );
}
