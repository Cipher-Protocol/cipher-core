import { expect } from "chai";
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

import { generateCipherTx, initTree } from "../../scripts/gen_testcase";
import { asyncPoseidonHash } from "../../scripts/lib/poseidonHash";
import { getDefaultLeaf } from "../../scripts/lib/utxo.helper";
import { IncrementalQuinTree } from "../../scripts/lib/IncrementalQuinTree";
import { CipherPayableCoin } from "../../scripts/lib/utxo/coin";

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

  describe("Simple Create Tx", function () {
    const singleTxCases = [
      {
        name: "n0m1",
        publicIn: "1",
        publicOut: "0",
        privateIns: [],
        privateOuts: ["1"],
      },
      // { w
      //   publicIn: "1",
      //   privateOut: ["0.5", "0.5"],
      // },
      // {
      //   publicIn: "2",
      //   privateOut: ["0.5", "0.5","0.5", "0.5"],
      // },
    ];

    singleTxCases.forEach((testCase, i) => {
      it(`Success to create h5n0m1 Tx, publicIn ${
        testCase.publicIn
      } ETH, privateOut ${testCase.privateOuts.join(
        ", "
      )}, publicOut 0`, async function () {
        const { contractCalldata } = await generateCipherTx(
          tree,
          utils.parseEther(testCase.publicIn).toBigInt(),
          0n,
          [],
          testCase.privateOuts.map((v) => utils.parseEther(v).toBigInt())
        );
        const beforeEthBalance = await ethers.provider.getBalance(
          cipher.address
        );
        console.log("proof", contractCalldata.utxoData);
        const result = await cipher.createTx(
          contractCalldata.utxoData,
          contractCalldata.publicInfo,
          { value: utils.parseEther(testCase.publicIn) }
        );
        await result.wait();
        const afterEthBalance = await ethers.provider.getBalance(
          cipher.address
        );
        expect(afterEthBalance).to.equal(
          beforeEthBalance.add(utils.parseEther(testCase.publicIn))
        );
      });
    });

    // const multipleTxCases = [
    // {
    //   txs: [
    //     {
    //       name: "n0m1",
    //       publicIn: "1",
    //       publicOut: "0",
    //       privateIns: [],
    //       privateOuts: ["1"],
    //     },
    //     {
    //       name: "n1m0",
    //       publicIn: "0",
    //       publicOut: "1",
    //       privateIns: ["1"],
    //       privateOuts: [],
    //     },
    //   ],
    // },
    // {
    //   txs: [
    //     {
    //       name: "n0m1",
    //       publicIn: "1",
    //       publicOut: "0",
    //       privateIns: [],
    //       privateOuts: ["1"],
    //     },
    //     {
    //       name: "n1m1",
    //       publicIn: "0",
    //       publicOut: "0.1",
    //       privateIns: ["1"],
    //       privateOuts: ["0.9"],
    //     },
    //   ],
    // },
    // {
    //   txs: [
    //     {
    //       name: "n0m1",
    //       publicIn: "1",
    //       publicOut: "0",
    //       privateIns: [],
    //       privateOuts: ["1"],
    //     },
    //     {
    //       name: "n1m2",
    //       publicIn: "0",
    //       publicOut: "0.1",
    //       privateIns: ["1"],
    //       privateOuts: ["0.4", "0.5"],
    //     },
    //   ],
    // },
    //   ];
    //   multipleTxCases.forEach((testCase, i) => {
    //     it(`multiple Txs`, async function () {
    //       const txs = testCase.txs;
    //       let previousOutCoins: CipherPayableCoin[] = [];
    //       for (let i = 0; i < txs.length; i++) {
    //         const tx = txs[i];
    //         const {
    //           privateOutCoins,
    //           contractCalldata,
    //           privateInputLength,
    //           privateOutputLength,
    //         } = await generateCipherTx(
    //           tree,
    //           utils.parseEther(tx.publicIn).toBigInt(),
    //           utils.parseEther(tx.publicOut).toBigInt(),
    //           previousOutCoins,
    //           tx.privateOuts.map((v) => utils.parseEther(v).toBigInt())
    //         );
    //         previousOutCoins = privateOutCoins;

    //         const circuitName = `n${privateInputLength}m${privateOutputLength}`;
    //         expect(circuitName).to.equal(txs[i].name);
    //         const testName = `createTx with n${privateInputLength}m${privateOutputLength}`;
    //         console.log(testName);

    //         const beforeEthBalance = await ethers.provider.getBalance(
    //           cipher.address
    //         );
    //         console.log(
    //           `${testName}: txIndex=${i}, beforeEthBalance`,
    //           beforeEthBalance.toString()
    //         );
    //         const result = await cipher.createTx(
    //           contractCalldata.utxoData,
    //           contractCalldata.publicInfo,
    //           { value: utils.parseEther(tx.publicIn) }
    //         );
    //         await result.wait();
    //         // TODO: check event log
    //         const afterEthBalance = await ethers.provider.getBalance(
    //           cipher.address
    //         );
    //         console.log(
    //           `${testName}: txIndex=${i}, afterEthBalance`,
    //           afterEthBalance.toString()
    //         );
    //       }
    //     });
    //   });
  });
});

// All spec
// other token
