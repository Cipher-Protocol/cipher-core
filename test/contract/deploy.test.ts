import { expect } from "chai";
import { ethers } from "hardhat";
import "@nomiclabs/hardhat-ethers";
import {
  IncrementalBinaryTree,
  Cipher,
  Cipher__factory,
  Verifier,
  Verifier__factory,
} from "../../typechain-types";
import {
  DEFAULT_ETH_ADDRESS,
  DEFAULT_FEE,
  SNARK_FIELD_SIZE,
} from "../../config";
import { keccak256 } from "ethers/lib/utils";
import { BigNumber, utils } from "ethers";
import { calcInitRoot, calcZeroValue } from "../../utils/calcZeroVal";

describe("deploy", function () {
  let cipherFactory: Cipher__factory;
  let cipher: Cipher;
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
      cipherFactory = (await ethers.getContractFactory("Cipher", {
        libraries: {
          IncrementalBinaryTree: incrementalBinaryTree.address,
        },
      })) as Cipher__factory;
      cipher = (await cipherFactory.deploy(
        verifier.address,
        DEFAULT_FEE
      )) as Cipher;
      await cipher.deployed();

      expect(await cipher.getTreeDepth(DEFAULT_ETH_ADDRESS)).to.equal(20);
      const zeroVal = BigNumber.from(
        keccak256(
          utils.defaultAbiCoder.encode(["address"], [DEFAULT_ETH_ADDRESS])
        )
      ).mod(SNARK_FIELD_SIZE);
      const zeroVals = calcZeroValue(zeroVal.toString(), 20);
      for (let i = 0; i < zeroVals.length; i++) {
        expect(await cipher.getTreeZeroes(DEFAULT_ETH_ADDRESS, i)).to.equal(
          zeroVals[i]
        );
      }
      const calcTreeRoot = calcInitRoot(zeroVal.toString(), 20);
      expect(await cipher.getTreeRoot(DEFAULT_ETH_ADDRESS)).to.equal(
        calcTreeRoot
      );
      expect(await cipher.getTreeLeafNum(DEFAULT_ETH_ADDRESS)).to.equal(0);
    });
  });
});
