import hre from "hardhat";
import "@nomiclabs/hardhat-ethers";
import {
  Cipher,
  Cipher__factory,
  CipherVerifier__factory,
  CipherVerifier,
} from "@typechain-types";
import { DEFAULT_TREE_HEIGHT, DEFAULT_ZERO_VALUE } from "../config";

import { initTree } from "../utils/lib/cipher/CipherCore";
import { asyncPoseidonHash } from "../utils/lib/poseidonHash";
import { IncrementalQuinTree } from "../utils/lib/IncrementalQuinTree";
import { generateTest } from "./helper/ts.helper";
import {
  doubleTxsCases,
  multipleTxsCases,
  tripleTxsCases,
} from "@/test/testcase/createTx-all-spec.testcase";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
const circomlibjs = require("circomlibjs");
const { createCode, generateABI } = circomlibjs.poseidonContract;

const ethers = hre.ethers;
const SPEC = {
  treeHeight: DEFAULT_TREE_HEIGHT,
  defaultLeafHash: DEFAULT_ZERO_VALUE,
};

describe("deploy", function () {
  let cipherFactory: Cipher__factory;
  let cipher: Cipher;
  let cipherVerifierFactory: CipherVerifier__factory;
  let cipherVerifier: CipherVerifier;
  let tree!: IncrementalQuinTree;
  let deployer: SignerWithAddress;

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
    [deployer] = await ethers.getSigners();
    cipherVerifierFactory = (await ethers.getContractFactory(
      "CipherVerifier"
    )) as CipherVerifier__factory;
    cipherVerifier = await cipherVerifierFactory.deploy();

    const poseidonT3Factory = new ethers.ContractFactory(
      generateABI(2),
      createCode(2),
      deployer
    );
    const poseidonT3 = await poseidonT3Factory.deploy();
    await poseidonT3.deployed();

    cipherFactory = (await ethers.getContractFactory(
      "Cipher"
    )) as Cipher__factory;
    cipher = (await cipherFactory.deploy(
      cipherVerifier.address,
      poseidonT3.address
    )) as Cipher;
    await cipher.deployed();

    /** init tree */
    tree = initTree(SPEC.treeHeight, SPEC.defaultLeafHash);

    context.cipher = cipher;
    context.tree = tree;
  });

  describe("Create Tx for all spec", function () {
    doubleTxsCases.forEach((testCase, i) => {
      it(
        `doubleTxsCases: ${testCase.txs.map((t) => t.name).join(" -> ")}`,
        generateTest(testCase, context)
      );
    });

    tripleTxsCases.forEach((testCase, i) => {
      it(
        `tripleTxsCases: ${testCase.txs.map((t) => t.name).join(" -> ")}`,
        generateTest(testCase, context)
      );
    });

    multipleTxsCases.forEach((testCase, i) => {
      it(
        `multipleTxsCases: ${testCase.txs.map((t) => t.name).join(" -> ")}`,
        generateTest(testCase, context)
      );
    });
  });
});
