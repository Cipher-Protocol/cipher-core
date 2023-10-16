import { expect } from "chai";
import { ethers } from "hardhat";
import "@nomiclabs/hardhat-ethers";
import {
  Cipher,
  Cipher__factory,
  CipherVerifier__factory,
  CipherVerifier,
} from "../typechain-types";
import {
  DEFAULT_ETH_ADDRESS,
  DEFAULT_TREE_HEIGHT,
  DEFAULT_ZERO_VALUE,
} from "../config";
import { Contract, ContractFactory } from "ethers";
import { calcInitRoot } from "../utils/calcZeroVal";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
const circomlibjs = require("circomlibjs");
const { createCode, generateABI } = circomlibjs.poseidonContract;

describe("deploy", function () {
  let cipherFactory: Cipher__factory;
  let cipher: Cipher;
  let cipherVerifierFactory: CipherVerifier__factory;
  let cipherVerifier: CipherVerifier;
  let poseidonT3Factory: ContractFactory;
  let poseidonT3: Contract;
  let deployer: SignerWithAddress;

  beforeEach(async function () {
    [deployer] = await ethers.getSigners();

    cipherVerifierFactory = (await ethers.getContractFactory(
      "CipherVerifier"
    )) as CipherVerifier__factory;
    cipherVerifier = await cipherVerifierFactory.deploy();

    poseidonT3Factory = new ethers.ContractFactory(
      generateABI(2),
      createCode(2),
      deployer
    );
    poseidonT3 = await poseidonT3Factory.deploy();
    await poseidonT3.deployed();
  });

  describe("Deploy", function () {
    it("Success to deploy, ETH token tree is init", async function () {
      cipherFactory = (await ethers.getContractFactory(
        "Cipher"
      )) as Cipher__factory;
      cipher = (await cipherFactory.deploy(
        cipherVerifier.address,
        poseidonT3.address
      )) as Cipher;
      await cipher.deployed();
      const calcTreeRoot = calcInitRoot(
        DEFAULT_ZERO_VALUE,
        DEFAULT_TREE_HEIGHT
      );
      expect(await cipher.getTreeRoot(DEFAULT_ETH_ADDRESS)).to.equal(
        calcTreeRoot
      );
      expect(await cipher.getTreeLeafNum(DEFAULT_ETH_ADDRESS)).to.equal(0);
    });
  });
});
