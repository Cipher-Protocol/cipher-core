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
import { DEFAULT_ETH_ADDRESS, SNARK_FIELD_SIZE } from "../../config";
import { keccak256 } from "ethers/lib/utils";
import { BigNumber, utils } from "ethers";
import { calcInitRoot, calcZeroValue } from "../../utils/calcZeroVal";

const ethers = hre.ethers;
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
  });

  describe("Deploy", function () {
    it("Success to deploy, ETH token tree is init", async function () {
      UtxoFactory = (await ethers.getContractFactory("Utxo", {
        libraries: {
          IncrementalBinaryTree: incrementalBinaryTree.address,
        },
      })) as Utxo__factory;
      utxo = (await UtxoFactory.deploy(verifier.address)) as Utxo;
      await utxo.deployed();

      expect(await utxo.getTreeDepth(DEFAULT_ETH_ADDRESS)).to.equal(20);
      const zeroVal = BigNumber.from(
        keccak256(
          utils.defaultAbiCoder.encode(["address"], [DEFAULT_ETH_ADDRESS])
        )
      ).mod(SNARK_FIELD_SIZE);
      const zeroVals = calcZeroValue(zeroVal.toString(), 20);
      for (let i = 0; i < zeroVals.length; i++) {
        expect(await utxo.getTreeZeroes(DEFAULT_ETH_ADDRESS, i)).to.equal(
          zeroVals[i]
        );
      }
      const calcTreeRoot = calcInitRoot(zeroVal.toString(), 20);
      expect(await utxo.getTreeRoot(DEFAULT_ETH_ADDRESS)).to.equal(
        calcTreeRoot
      );
      expect(await utxo.getTreeLeafNum(DEFAULT_ETH_ADDRESS)).to.equal(0);
    });
  });
});
