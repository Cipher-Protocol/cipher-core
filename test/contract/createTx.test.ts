import { expect } from "chai";
import { resolve } from "path";
import hre from "hardhat";
import "@nomiclabs/hardhat-ethers";
import {
  IncrementalBinaryTree,
  Cipher,
  Cipher__factory,
  Verifier,
  Verifier__factory,
} from "../../typechain-types";
import { DEFAULT_FEE, DEFAULT_TREE_HEIGHT } from "../../config";
import { BigNumber, utils } from "ethers";

import { genTxForZeroIn, initTree } from "../../scripts/gen_testcase";
import { asyncPoseidonHash } from "../../scripts/lib/poseidonHash";
import { getDefaultLeaf } from "../../scripts/lib/utxo.helper";
import { IncrementalQuinTree } from "../../scripts/lib/IncrementalQuinTree";

const ethers = hre.ethers;
const ethTokenAddress = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE";
const SPEC = {
  treeHeight: DEFAULT_TREE_HEIGHT,
  defaultLeafHash: getDefaultLeaf(ethTokenAddress).toString(),
};

interface Transaction {
  privateIn?: number;
  publicIn: number;

  privateOut?: number;
  publicOut: number;
}

describe("deploy", function () {
  let cipherFactory: Cipher__factory;
  let cipher: Cipher;
  let incrementalBinaryTree: IncrementalBinaryTree;
  let VerifierFactory: Verifier__factory;
  let verifier: Verifier;
  let tree!: IncrementalQuinTree;

  before(async function () {
    await asyncPoseidonHash;
  });

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

    /** init tree */
    tree = initTree(SPEC.treeHeight, SPEC.defaultLeafHash);
  });

  /** simple test case
   * n0m1
   * n0m2
   * ....
   * n0mX
   * n0m1 -> n1m1
   * n0m2 -> n2m0
   * n0m2 -> n2m1
   * etc .......
   */

  describe("Create Tx", function () {
    it("Success to create h5n0m1 Tx, publicIn 0.1 ETH, 1 privateOut (0.1), publicOut 0", async function () {
      console.log({
        SPEC,
        initialRoot: tree.root,
      });
      const decimals = BigNumber.from(10).pow(18);
      const { contractCalldata } = await genTxForZeroIn(tree, [
        BigInt(BigNumber.from("1").mul(decimals).mod(10).toString()), // 0.1 ETH
        // BigInt(BigNumber.from('2').mul(decimals).mod(10).toString()), // 0.2 ETH
      ]);
      console.log({
        contractCalldata,
        nextRoot: tree.root,
      });
      const beforeEthBalance = await ethers.provider.getBalance(cipher.address);
      console.log("beforeEthBalance", beforeEthBalance.toString());
      const result = await cipher.createTx(
        contractCalldata.utxoData,
        contractCalldata.publicInfo,
        { value: utils.parseEther("0.1") }
      );
      await result.wait();
      const afterEthBalance = await ethers.provider.getBalance(cipher.address);
      console.log("afterEthBalance", afterEthBalance.toString());
      expect(afterEthBalance).to.equal(
        beforeEthBalance.add(utils.parseEther("0.1"))
      );
    });

    // it("Success to create h5n0m1 Tx, publicIn 0.3 ETH, 2 privateOut(0.1, 0.2), publicOut 0", async function () {
    //   const decimals = BigNumber.from(10).pow(18);
    //   const { contractCalldata } = await genTxForZeroIn(tree, [
    //     BigInt(BigNumber.from("1").mul(decimals).mod(10).toString()), // 0.1 ETH
    //     BigInt(BigNumber.from("2").mul(decimals).mod(10).toString()), // 0.2 ETH
    //   ]);
    //   const result = await cipher.createTx(
    //     contractCalldata.utxoData,
    //     contractCalldata.publicInfo
    //   );
    //   await result.wait();
    // });
  });
});
