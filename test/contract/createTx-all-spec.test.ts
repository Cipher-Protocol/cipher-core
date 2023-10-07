import hre from "hardhat";
import "@nomiclabs/hardhat-ethers";
import {
  IncrementalBinaryTree,
  Cipher,
  Cipher__factory,
  CipherVerifier__factory,
  CipherVerifier,
} from "@typechain-types";
import { DEFAULT_FEE, DEFAULT_TREE_HEIGHT } from "@/config";

import { ethTokenAddress, initTree } from "@/scripts/lib/cipher/CipherCore";
import { asyncPoseidonHash } from "@scripts/lib/poseidonHash";
import { getDefaultLeaf } from "@scripts/lib/utxo.helper";
import { IncrementalQuinTree } from "@scripts/lib/IncrementalQuinTree";
import { CreateTxTestCase, generateTest } from "./helper/ts.helper";

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
    const doubleTxsCases: CreateTxTestCase[] = [
      {
        tokenAddress: ethTokenAddress,
        txs: [
          {
            name: "n0m1",
            publicIn: "1",
            publicOut: "0",
            privateIns: [],
            privateOuts: ["1"],
          },
          {
            name: "n1m0",
            publicIn: "0",
            publicOut: "1",
            privateIns: ["1"],
            privateOuts: [],
          },
        ],
      },
      {
        tokenAddress: ethTokenAddress,
        txs: [
          {
            name: "n0m1",
            publicIn: "1",
            publicOut: "0",
            privateIns: [],
            privateOuts: ["1"],
          },
          {
            name: "n1m1",
            publicIn: "0",
            publicOut: "0.1",
            privateIns: ["1"],
            privateOuts: ["0.9"],
          },
        ],
      },
      {
        tokenAddress: ethTokenAddress,
        txs: [
          {
            name: "n0m1",
            publicIn: "1",
            publicOut: "0",
            privateIns: [],
            privateOuts: ["1"],
          },
          {
            name: "n1m2",
            publicIn: "0",
            publicOut: "0.1",
            privateIns: ["1"],
            privateOuts: ["0.4", "0.5"],
          },
        ],
      },
      {
        tokenAddress: ethTokenAddress,
        txs: [
          {
            name: "n0m1",
            publicIn: "1",
            publicOut: "0",
            privateIns: [],
            privateOuts: ["1"],
          },
          {
            name: "n1m4",
            publicIn: "0",
            publicOut: "0",
            privateIns: ["1"],
            privateOuts: ["0.3", "0.3", "0.3", "0.1"],
          },
        ],
      },
      {
        tokenAddress: ethTokenAddress,
        txs: [
          {
            name: "n0m2",
            publicIn: "1",
            publicOut: "0",
            privateIns: [],
            privateOuts: ["0.5", "0.5"],
          },
          {
            name: "n2m0",
            publicIn: "0",
            publicOut: "1",
            privateIns: ["0.5", "0.5"],
            privateOuts: [],
          },
        ],
      },
      {
        tokenAddress: ethTokenAddress,
        txs: [
          {
            name: "n0m2",
            publicIn: "1",
            publicOut: "0",
            privateIns: [],
            privateOuts: ["0.5", "0.5"],
          },
          {
            name: "n2m1",
            publicIn: "0",
            publicOut: "0",
            privateIns: ["0.5", "0.5"],
            privateOuts: ["1"],
          },
        ],
      },
      {
        tokenAddress: ethTokenAddress,
        txs: [
          {
            name: "n0m2",
            publicIn: "1",
            publicOut: "0",
            privateIns: [],
            privateOuts: ["0.5", "0.5"],
          },
          {
            name: "n2m2",
            publicIn: "0",
            publicOut: "0",
            privateIns: ["0.5", "0.5"],
            privateOuts: ["0.6", "0.4"],
          },
        ],
      },
      {
        tokenAddress: ethTokenAddress,
        txs: [
          {
            name: "n0m2",
            publicIn: "1",
            publicOut: "0",
            privateIns: [],
            privateOuts: ["0.5", "0.5"],
          },
          {
            name: "n2m4",
            publicIn: "0",
            publicOut: "0",
            privateIns: ["0.5", "0.5"],
            privateOuts: ["0.25", "0.25", "0.25", "0.25"],
          },
        ],
      },
      {
        tokenAddress: ethTokenAddress,
        txs: [
          {
            name: "n0m4",
            publicIn: "1",
            publicOut: "0",
            privateIns: [],
            privateOuts: ["0.25", "0.25", "0.25", "0.25"],
          },
          {
            name: "n4m0",
            publicIn: "0",
            publicOut: "1",
            privateIns: ["0.25", "0.25", "0.25", "0.25"],
            privateOuts: [],
          },
        ],
      },
      {
        tokenAddress: ethTokenAddress,
        txs: [
          {
            name: "n0m4",
            publicIn: "1",
            publicOut: "0",
            privateIns: [],
            privateOuts: ["0.25", "0.25", "0.25", "0.25"],
          },
          {
            name: "n4m1",
            publicIn: "0",
            publicOut: "0",
            privateIns: ["0.25", "0.25", "0.25", "0.25"],
            privateOuts: ["1"],
          },
        ],
      },
      {
        tokenAddress: ethTokenAddress,
        txs: [
          {
            name: "n0m4",
            publicIn: "1",
            publicOut: "0",
            privateIns: [],
            privateOuts: ["0.25", "0.25", "0.25", "0.25"],
          },
          {
            name: "n4m2",
            publicIn: "0",
            publicOut: "0",
            privateIns: ["0.25", "0.25", "0.25", "0.25"],
            privateOuts: ["0.5", "0.5"],
          },
        ],
      },
      {
        tokenAddress: ethTokenAddress,
        txs: [
          {
            name: "n0m4",
            publicIn: "1",
            publicOut: "0",
            privateIns: [],
            privateOuts: ["0.25", "0.25", "0.25", "0.25"],
          },
          {
            name: "n4m4",
            publicIn: "0",
            publicOut: "0.2",
            privateIns: ["0.25", "0.25", "0.25", "0.25"],
            privateOuts: ["0.2", "0.2", "0.2", "0.2"],
          },
        ],
      },
    ];
    doubleTxsCases.forEach((testCase, i) => {
      it(
        `doubleTxsCases: ${testCase.txs.map((t) => t.name).join(" -> ")}`,
        generateTest(testCase, context)
      );
    });
  });
});
