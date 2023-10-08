import hre from "hardhat";
import "@nomiclabs/hardhat-ethers";
import {
  IncrementalBinaryTree,
  Cipher,
  Cipher__factory,
  CipherVerifier__factory,
  CipherVerifier,
} from "@typechain-types";
import { DEFAULT_TREE_HEIGHT } from "@/config";

import { ethTokenAddress, initTree } from "../utils/lib/cipher/CipherCore";
import { asyncPoseidonHash } from "../utils/lib/poseidonHash";
import { getDefaultLeaf } from "../utils/lib/utxo.helper";
import { IncrementalQuinTree } from "../utils/lib/IncrementalQuinTree";
import { CreateTxTestCase, generateTest } from "./helper/ts.helper";
import { doubleTxsCases } from "@/test/testcase/createTx-all-spec.testcase";

const ethers = hre.ethers;
const SPEC = {
  treeHeight: DEFAULT_TREE_HEIGHT,
  defaultLeafHash: getDefaultLeaf(ethTokenAddress).toString(),
};

describe("deploy", function () {
  let cipherFactory: Cipher__factory;
  let cipher: Cipher;
  let incrementalBinaryTree: IncrementalBinaryTree;
  let cipherVerifierFactory: CipherVerifier__factory;
  let cipherVerifier: CipherVerifier;
  let tree!: IncrementalQuinTree;

  const context: {
    cipher: Cipher;
    tree: IncrementalQuinTree;
  } = {
    cipher: {} as Cipher,
    tree: {} as IncrementalQuinTree,
  };

  before(async function () {
    await asyncPoseidonHash;
  });

  beforeEach(async function () {
    cipherVerifierFactory = (await ethers.getContractFactory(
      "CipherVerifier"
    )) as CipherVerifier__factory;
    cipherVerifier = await cipherVerifierFactory.deploy();

    const PoseidonT3 = await ethers.getContractFactory("PoseidonT3");
    const poseidonT3 = await PoseidonT3.deploy();
    await poseidonT3.deployed();

    const IncrementalBinaryTreeFactory = await ethers.getContractFactory(
      "IncrementalBinaryTree",
      {
        libraries: {
          PoseidonT3: poseidonT3.address,
        },
      }
    );
    incrementalBinaryTree =
      (await IncrementalBinaryTreeFactory.deploy()) as IncrementalBinaryTree;
    await incrementalBinaryTree.deployed();
    cipherFactory = (await ethers.getContractFactory("Cipher", {
      libraries: {
        IncrementalBinaryTree: incrementalBinaryTree.address,
      },
    })) as Cipher__factory;
    cipher = (await cipherFactory.deploy(cipherVerifier.address)) as Cipher;
    await cipher.deployed();

    /** init tree */
    tree = initTree(SPEC.treeHeight, SPEC.defaultLeafHash);

    context.cipher = cipher;
    context.tree = tree;
  });

  describe("Create Tx", function () {
    doubleTxsCases.forEach((testCase, i) => {
      it(
        `doubleTxsCases: ${testCase.txs.map((t) => t.name).join(" -> ")}`,
        generateTest(testCase, context)
      );
    });
  });
});
