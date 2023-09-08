import { expect } from "chai";
import { BigNumber, ContractFactory } from "ethers";
import { ethers } from "hardhat";
import {
  Utxo,
  Utxo__factory,
  Verifier,
  Verifier__factory,
} from "../../typechain-types";
import proofJSON from "../../build/circuits/h5n0m2/proof.json";
import publicJSON from "../../build/circuits/h5n0m2/public.json";
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
      const proof: Utxo.ProofStruct = {
        a: [proofJSON.pi_a[0], proofJSON.pi_a[1]],
        b: [
          [proofJSON.pi_b[0][0], proofJSON.pi_b[0][1]],
          [proofJSON.pi_b[1][0], proofJSON.pi_b[1][1]],
        ],
        c: [proofJSON.pi_c[0], proofJSON.pi_c[1]],
        publicSignals: publicJSON,
      };
      console.log(proof);
      await utxo.verify(verifier.address, proof);
    });
  });
});
