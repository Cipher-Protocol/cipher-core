import {
  Cipher,
  CipherVerifier__factory,
  Cipher__factory,
} from "@/typechain-types";
import { getString } from "@/utils/helper";
import { Wallet } from "ethers";
import { ethers } from "hardhat";
const circomlibjs = require("circomlibjs");
const { createCode, generateABI } = circomlibjs.poseidonContract;

export const main = async () => {
  const provider = new ethers.providers.JsonRpcProvider(
    getString(process.env.GOERLI_RPC_URL)
  );

  const deployerPrivKey = getString(process.env.GOERLI_DEPLOYER_PRIVATE_KEY);
  const deployer = new Wallet(deployerPrivKey, provider);

  console.log(
    "Deploying contracts with deployer:",
    await deployer.getAddress()
  );

  // Deploy Cipher verifier
  console.log("Deploying CipherVerifier contract...");
  const cipherVerifierFactory = (await ethers.getContractFactory(
    "CipherVerifier"
  )) as CipherVerifier__factory;
  const cipherVerifier = await cipherVerifierFactory.deploy();
  await cipherVerifier.deployed();
  console.log("CipherVerifier deployed to:", cipherVerifier.address);

  // Deploy PoseidonT3 contract
  console.log("Deploying PoseidonT3 contract...");
  const poseidonT3Factory = new ethers.ContractFactory(
    generateABI(2),
    createCode(2),
    deployer
  );
  const poseidonT3 = await poseidonT3Factory.deploy();
  await poseidonT3.deployed();
  console.log("PoseidonT3 deployed to:", poseidonT3.address);

  // Deploy Cipher contract
  console.log("Deploying Cipher contract...");
  const cipherFactory = (await ethers.getContractFactory(
    "Cipher"
  )) as Cipher__factory;
  const cipher = (await cipherFactory.deploy(
    cipherVerifier.address,
    poseidonT3.address
  )) as Cipher;
  await cipher.deployed();
  console.log("Cipher deployed to:", cipher.address);
};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
