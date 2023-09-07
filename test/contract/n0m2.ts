import { expect } from "chai";
import { BigNumber } from "ethers";
import { ethers } from "hardhat";
import {
  Utxo,
  Utxo__factory,
  Verifier,
  Verifier__factory,
} from "../../typechain-types";
import proofJSON from "../../build/circuits/h5n0m2/proof.json";
import publicJSON from "../../build/circuits/h5n0m2/public.json";

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
    UtxoFactory = (await ethers.getContractFactory("Utxo")) as Utxo__factory;
    utxo = await UtxoFactory.deploy();
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
        publicInputs: publicJSON,
      };
      utxo.verify(verifier.address, proof);
    });
  });
});
