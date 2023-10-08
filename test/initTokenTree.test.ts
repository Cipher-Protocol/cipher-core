import { ethers } from "hardhat";
import {
  ERC20,
  ERC20Mock__factory,
  IncrementalBinaryTree,
  Cipher,
  Cipher__factory,
  CipherVerifier__factory,
  CipherVerifier,
} from "../typechain-types";
import { DEFAULT_TREE_HEIGHT, SNARK_FIELD_SIZE } from "../config";
import { keccak256 } from "ethers/lib/utils";
import { BigNumber, utils } from "ethers";
import { calcInitRoot, calcZeroValue } from "../utils/calcZeroVal";
import { expect } from "chai";

describe("deploy", function () {
  let cipherFactory: Cipher__factory;
  let cipher: Cipher;
  let incrementalBinaryTree: IncrementalBinaryTree;
  let cipherVerifierFactory: CipherVerifier__factory;
  let cipherVerifier: CipherVerifier;
  let Erc20Factory: ERC20Mock__factory;
  let erc20: ERC20;
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
    Erc20Factory = (await ethers.getContractFactory(
      "ERC20Mock"
    )) as ERC20Mock__factory;
    erc20 = (await Erc20Factory.deploy("Test", "T", 18)) as ERC20;
  });

  describe("Initialize new token tree", function () {
    it("Success to initTokenTree", async function () {
      const initTokenTreeTx = await cipher.initTokenTree(erc20.address);
      await initTokenTreeTx.wait();

      const zeroVal = BigNumber.from(
        keccak256(utils.defaultAbiCoder.encode(["address"], [erc20.address]))
      ).mod(SNARK_FIELD_SIZE);

      await expect(initTokenTreeTx)
        .to.emit(cipher, "NewTokenTree")
        .withArgs(erc20.address, DEFAULT_TREE_HEIGHT, zeroVal.toString());

      expect(await cipher.getTreeDepth(erc20.address)).to.equal(
        DEFAULT_TREE_HEIGHT
      );

      const zeroVals = calcZeroValue(zeroVal.toString(), DEFAULT_TREE_HEIGHT);
      for (let i = 0; i < zeroVals.length; i++) {
        expect(await cipher.getTreeZeroes(erc20.address, i)).to.equal(
          zeroVals[i]
        );
      }
      const calcTreeRoot = calcInitRoot(
        zeroVal.toString(),
        DEFAULT_TREE_HEIGHT
      );
      expect(await cipher.getTreeRoot(erc20.address)).to.equal(calcTreeRoot);
      expect(await cipher.getTreeLeafNum(erc20.address)).to.equal(0);
    });
    it("Fail to initTokenTree, the token tree is initialized", async function () {
      const initTokenTreeTx = await cipher.initTokenTree(erc20.address);
      await initTokenTreeTx.wait();

      await expect(
        cipher.initTokenTree(erc20.address)
      ).to.be.revertedWithCustomError(cipher, "TokenTreeAlreadyInitialized");
    });
  });
});
