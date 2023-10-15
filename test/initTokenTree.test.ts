import { ethers } from "hardhat";
import {
  ERC20,
  ERC20Mock__factory,
  Cipher,
  Cipher__factory,
  CipherVerifier__factory,
  CipherVerifier,
} from "../typechain-types";
import { DEFAULT_TREE_HEIGHT, DEFAULT_ZERO_VALUE } from "../config";
import { calcInitRoot } from "../utils/calcZeroVal";
import { expect } from "chai";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
const circomlibjs = require("circomlibjs");
const { createCode, generateABI } = circomlibjs.poseidonContract;

describe("deploy", function () {
  let cipherFactory: Cipher__factory;
  let cipher: Cipher;
  let cipherVerifierFactory: CipherVerifier__factory;
  let cipherVerifier: CipherVerifier;
  let Erc20Factory: ERC20Mock__factory;
  let erc20: ERC20;
  let deployer: SignerWithAddress;

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
    Erc20Factory = (await ethers.getContractFactory(
      "ERC20Mock"
    )) as ERC20Mock__factory;
    erc20 = (await Erc20Factory.deploy("Test", "T", 18)) as ERC20;
  });

  describe("Initialize new token tree", function () {
    it("Success to initTokenTree", async function () {
      const initTokenTreeTx = await cipher.initTokenTree(erc20.address);
      await initTokenTreeTx.wait();

      await expect(initTokenTreeTx)
        .to.emit(cipher, "NewTokenTree")
        .withArgs(erc20.address);

      const calcTreeRoot = calcInitRoot(
        DEFAULT_ZERO_VALUE,
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
