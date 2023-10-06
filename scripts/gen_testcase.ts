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
import {
  ProofStruct,
  PublicInfoStruct,
} from "../typechain-types/contracts/Cipher";

const ethTokenAddress = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE";

const SPEC = {
  treeHeight: DEFAULT_TREE_HEIGHT,
  defaultLeafHash: getDefaultLeaf(ethTokenAddress).toString(),
};

async function main() {
  await asyncPoseidonHash;

  const tree = initTree(SPEC.treeHeight, SPEC.defaultLeafHash);

  const decimals = BigNumber.from(10).pow(18);
  const { circuitInput, contractCalldata } = await generateCipherTx(
    tree,
    BigInt(BigNumber.from("1").mul(decimals).mod(10).toString()),
    0n,
    [],
    [
      BigInt(BigNumber.from("1").mul(decimals).mod(10).toString()), // 0.1 ETH
      BigInt(BigNumber.from("2").mul(decimals).mod(10).toString()), // 0.2 ETH
    ]
  );

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

export function getRandomAmtCoinInfo(
  privKey: bigint,
  {
    inRandom,
    inSaltOrSeed,
  }: {
    inRandom: bigint;
    inSaltOrSeed: bigint;
  }
) {
  const decimal = BigNumber.from(10).pow(18);
  const randomAmt = BigNumber.from(Math.floor(Math.random() * 10)).mul(decimal); // 0 ~ 9 ETH
  const coinInfo: CipherCoinInfo = {
    key: {
      inSaltOrSeed: inSaltOrSeed,
      hashedSaltOrUserId: PoseidonHash([inSaltOrSeed]),
      inRandom,
    },
    amount: BigInt(randomAmt.toString()),
  };
  return coinInfo;
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

export async function generateCipherTx(
  tree: IncrementalQuinTree,
  publicInAmt: bigint,
  publicOutAmt: bigint,
  privateInCoins: CipherPayableCoin[] = [],
  privateOutAmts: bigint[]
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
  assert(
    publicInAmt + totalPrivateInAmount === publicOutAmt + totalPrivateOutAmount,
    "inAmounts and outAmounts are not balanced"
  );

  const privateInputLength = privateInCoins.length;
  const privateOutputLength = privateOutAmts.length;

  for (let index = 0; index < privateOutputLength; index++) {
    const coinInfo = getCoinInfoFromAmt(privateOutAmts[index], {
      inRandom: 1n, // TODO: How to get inRandom?
      inSaltOrSeed: 2n, // TODO: get from user sign or random
    });
    const leafId = tree.nextIndex;
    const payableCoin = new CipherPayableCoin(coinInfo, tree, leafId);
    tree.insert(payableCoin.getCommitment());
    privateOutCoins.push(payableCoin);
  }

  const latestRoot = tree.root;
  const publicInfo: PublicInfoStruct = {
    utxoType: getUtxoType(privateInputLength, privateOutputLength),
    feeRate: "0",
    relayer: "0x0000000000000000000000000000000000000000", // no fee
    recipient: "0xffffffffffffffffffffffffffffffffffffffff", // TODO: get from user address
    encodedData: utils.defaultAbiCoder.encode(["address"], [ethTokenAddress]),
  };

  /** Circuit input */
  const publicInfoHash = toPublicInfoHash(publicInfo);

  const circuitInput = {
    root: previousRoot,
    publicInAmt,
    publicOutAmt,
    publicInfoHash: BigInt(publicInfoHash),

    // Coin Inputs
    inputNullifier: privateInCoins.map((coin) => coin.getNullifier()),
    inAmount: privateInCoins.map((coin) => coin.coinInfo.amount),
    inSaltOrSeed: privateInCoins.map((coin) => coin.coinInfo.key.inSaltOrSeed),
    inRandom: privateInCoins.map((coin) => coin.coinInfo.key.inRandom),
    inPathIndices: privateInCoins.map((coin) => coin.getPathIndices()),
    inPathElements: privateInCoins.map((coin) => coin.getPathElements()),

    // Coin Outputs
    outputCommitment: privateOutCoins.map((coin) => coin.getCommitment()),
    outAmount: privateOutCoins.map((coin) => coin.coinInfo.amount),
    outHashedSaltOrUserId: privateOutCoins.map(
      (coin) => coin.coinInfo.key.hashedSaltOrUserId
    ),
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
  const utxoData: ProofStruct = {
    a: calldata[0],
    b: calldata[1],
    c: calldata[2],
    publicSignals: {
      root: utils.hexlify(previousRoot),
      publicInAmt: publicInAmt.toString(),
      publicOutAmt: publicOutAmt.toString(),
      publicInfoHash,
      inputNullifiers: privateInCoins.map((coin) =>
        utils.hexlify(coin.getNullifier())
      ),
      outputCommitments: privateOutCoins.map((coin) =>
        utils.hexlify(coin.getCommitment())
      ),
    },
  };

  return {
    tree,
    privateInputLength,
    privateOutputLength,
    privateOutCoins,
    circuitInput,
    contractCalldata: {
      utxoData,
      publicInfo,
    },
  };
}

function toPublicInfoHash(publicInfo: PublicInfoStruct) {
  const data = utils.defaultAbiCoder.encode(
    ["tuple(bytes2,uint16,address,address,bytes)"],
    [
      [
        publicInfo.utxoType,
        publicInfo.feeRate,
        publicInfo.relayer,
        publicInfo.recipient,
        publicInfo.encodedData,
      ],
    ]
  );
  return utils.hexlify(
    BigNumber.from(utils.keccak256(data)).mod(FIELD_SIZE_BIGINT)
  );
}
