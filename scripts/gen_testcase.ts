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
import { CipherCoinInfo, CipherPayableCoin } from "./lib/utxo/coin";
import { Cipher } from "../typechain-types";
import { resolve } from "path";
import { proveByName } from "./prove";
import { assert, toDecimalStringObject } from "./lib/helper";

const ethTokenAddress = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE";

const SPEC = {
  treeHeight: DEFAULT_TREE_HEIGHT,
  defaultLeafHash: getDefaultLeaf(ethTokenAddress).toString(),
};

async function main() {
  await asyncPoseidonHash;

  const tree = initTree(SPEC.treeHeight, SPEC.defaultLeafHash);

  const decimals = BigNumber.from(10).pow(18);
  const { circuitInput, contractCalldata } = await generateCipherTx(tree, 
    BigInt(BigNumber.from("1").mul(decimals).mod(10).toString()),
    0n,
    [],
    [
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
  const coinInfo: CipherCoinInfo = {
    key: {
      privKey,
      inSaltOrSeed: getPublicKey(privKey),
      inRandom: salt,
    },
    amount: BigInt(randomAmt.toString()),
  };
  return coinInfo;
}

export function getCoinInfoFromAmt(amt: bigint, privKey: bigint, salt: bigint) {
  const coinInfo: CipherCoinInfo = {
    key: {
      privKey,
      inSaltOrSeed: getPublicKey(privKey),
      inRandom: salt,
    },
    amount: amt,
  };
  return coinInfo;
}

export async function generateCipherTx(
  tree: IncrementalQuinTree,
  publicInAmt: bigint,
  publicOutAmt: bigint,
  privateInCoins: CipherPayableCoin[] = [],
  privateOutAmts: bigint[],
) {
  const privateOutCoins: CipherPayableCoin[] = [];
  const previousRoot = tree.root;

  const totalPrivateInAmount = privateInCoins.reduce(
    (acc, coin) => acc + coin.coinInfo.amount,
    0n
  );
  const totalPrivateOutAmount = privateOutAmts.reduce(
    (acc, amt) => acc + amt,
    0n
  );
  assert(publicInAmt + totalPrivateInAmount === publicOutAmt + totalPrivateOutAmount, "inAmounts and outAmounts are not balanced")

  // TODO: How to get privKey and salt?
  const privKey = 1n;
  const salt = 2n;

  const privateInputLength = privateInCoins.length;
  const privateOutputLength = privateOutAmts.length;

  for (let index = 0; index < privateOutputLength; index++) {
    const coinInfo = getCoinInfoFromAmt(privateOutAmts[index], privKey, salt);
    const leafId = tree.nextIndex;
    const payableCoin = new CipherPayableCoin(coinInfo, tree, leafId);
    tree.insert(payableCoin.getCommitment());
    privateOutCoins.push(payableCoin);
  }

  const latestRoot = tree.root;
  const publicInfo: Cipher.PublicInfoStruct = {
    utxoType: getUtxoType(privateInputLength, privateOutputLength),
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
    publicOutAmt,
    publicInfoHash: BigInt(publicInfoHash),

    // 0 Inputs
    inRandom: privateInCoins.map((coin) => coin.coinInfo.key.inRandom),
    inSaltOrSeed: privateInCoins.map((coin) => coin.coinInfo.key.inSaltOrSeed),
    inputNullifier: privateInCoins.map((coin) => coin.getNullifier()),
    inAmount: privateInCoins.map((coin) => coin.coinInfo.amount),
    inPathIndices: privateInCoins.map((coin) => coin.getPathIndices()),
    inPathElements: privateInCoins.map((coin) => coin.getPathElements()),

    // outNumber outputs
    outputCommitment: privateOutCoins.map((coin) => coin.getCommitment()),
    outAmount: privateOutCoins.map((coin) => coin.coinInfo.amount),
    outSaltOrSeed: privateOutCoins.map((coin) => coin.coinInfo.key.inSaltOrSeed),
    outRandom: privateOutCoins.map((coin) => coin.coinInfo.key.inRandom),
  };

  /** Prove */
  const circuitName = `h${tree.depth}n${privateInputLength}m${privateOutputLength}`;
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
    inputNullifiers: privateInCoins.map((coin) => coin.getNullifier().toString()),
    outputCommitments: privateOutCoins.map((coin) => coin.getCommitment().toString()),
  };

  return {
    tree,
    privateOutCoins,
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
