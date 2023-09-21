import { expect } from "chai";
import { resolve } from "path";
import hre from "hardhat";
import "@nomiclabs/hardhat-ethers";
import {
  IncrementalBinaryTree,
  Utxo,
  Utxo__factory,
  Verifier,
  Verifier__factory,
} from "../../typechain-types";
import { DEFAULT_FEE } from "../../config";

const ethers = hre.ethers;

interface Transaction {
  privateIn?: number;
  publicIn: number;

  privateOut?: number;
  publicOut: number;
}

describe("deploy", function () {
  let UtxoFactory: Utxo__factory;
  let utxo: Utxo;
  let incrementalBinaryTree: IncrementalBinaryTree;
  let VerifierFactory: Verifier__factory;
  let verifier: Verifier;
  beforeEach(async function () {
    VerifierFactory = (await ethers.getContractFactory(
      "Verifier"
    )) as Verifier__factory;
    verifier = await VerifierFactory.deploy();

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
    UtxoFactory = (await ethers.getContractFactory("Utxo", {
      libraries: {
        IncrementalBinaryTree: incrementalBinaryTree.address,
      },
    })) as Utxo__factory;
    utxo = (await UtxoFactory.deploy(verifier.address, DEFAULT_FEE)) as Utxo;
    await utxo.deployed();
  });

  describe("Create Tx", function () {
    it("Success to create n0m1 Tx, publicIn 300, privateOut 300, publicOut 0", async function () {});
    it("Success to create n1m1 Tx, privateIn 300, privateOut 250, publicOut 50", async function () {});
  });
});
