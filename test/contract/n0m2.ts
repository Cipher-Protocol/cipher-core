import { expect } from "chai";
import { BigNumber, ContractFactory } from "ethers";
import { ethers } from "hardhat";
import {
  Utxo,
  Utxo__factory,
  Verifier,
  Verifier__factory,
} from "../../typechain-types";
import calldataJSON from "../../build/circuits/h5n0m2/h5n0m2_calldata.json";
import { DEFAULT_ZERO_LEAF_VALUE } from "../../config";

describe("n0m2", function () {
  let UtxoFactory: Utxo__factory;
  let utxo: Utxo;
  let VerifierFactory: Verifier__factory;
  let verifier: Verifier;
  beforeEach(async function () {
    VerifierFactory = (await ethers.getContractFactory(
      "Verifier_h5n0m2"
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
    const incrementalBinaryTree = await IncrementalBinaryTreeFactory.deploy();
    await incrementalBinaryTree.deployed();

    UtxoFactory = (await ethers.getContractFactory("Utxo", {
      libraries: {
        IncrementalBinaryTree: incrementalBinaryTree.address,
      },
    })) as Utxo__factory;

    utxo = (await UtxoFactory.deploy(
      5,
      DEFAULT_ZERO_LEAF_VALUE,
      verifier.address
    )) as Utxo;
    await utxo.deployed();
  });

  describe("verify", function () {
    it("verify", async function () {
      const proof = {
        a: calldataJSON[0],
        b: calldataJSON[1],
        c: calldataJSON[2],
        publicSignals: calldataJSON[3],
      };
      const result = await verifier.verifyProof(
        proof.a,
        proof.b,
        proof.c,
        proof.publicSignals
      );
      console.log({
        result,
      });
      // await utxo.verify(verifier.address, proof);
    });
  });
});
