import { expect } from "chai";
import { utils } from "ethers";
import { Cipher } from "@typechain-types";
import {
  createCoin,
  generateCipherTx,
} from "../../utils/lib/cipher/CipherCore";
import { IncrementalQuinTree } from "../../utils/lib/IncrementalQuinTree";
import { CipherTransferableCoin } from "../../utils/lib/cipher/CipherCoin";
import hre from "hardhat";
import { PublicInfoStruct } from "@/typechain-types/contracts/Cipher";
const ethers = hre.ethers;

export interface CreateTxTestCase {
  tokenAddress: string;
  txs: Array<Transaction>;
}

export interface Transaction {
  name: string;
  maxAllowableFeeRate?: string;
  recipient?: string;

  publicIn: string;
  publicOut: string;
  privateIns: string[];
  privateOuts: string[];
}

export function generateTest(
  testCase: CreateTxTestCase,
  context: {
    tree: IncrementalQuinTree;
    cipher: Cipher;
  }
) {
  return async () => {
    const { txs, tokenAddress } = testCase;
    const { tree, cipher } = context;
    let previousOutCoins: CipherTransferableCoin[] = [];

    for (let i = 0; i < txs.length; i++) {
      const tx = txs[i];
      const privateInputLength = txs[i].privateIns.length;
      const privateOutputLength = txs[i].privateOuts.length;
      const publicInfo: PublicInfoStruct = {
        maxAllowableFeeRate: tx.maxAllowableFeeRate || "0",
        recipient: tx.recipient || "0xffffffffffffffffffffffffffffffffffffffff", // TODO: get from user address
        token: tokenAddress,
      };
      const privateOutCoins = tx.privateOuts.map((v) =>
        createCoin(tree, {
          amount: utils.parseEther(v).toBigInt(),
          inRandom: BigInt(1),
          inSaltOrSeed: BigInt(2),
        })
      );

      const { transferableCoins, contractCalldata } = await generateCipherTx(
        tree,
        {
          publicInAmt: utils.parseEther(tx.publicIn).toBigInt(),
          publicOutAmt: utils.parseEther(tx.publicOut).toBigInt(),
          privateInCoins: previousOutCoins,
          privateOutCoins,
        },
        publicInfo
      );
      previousOutCoins = transferableCoins;

      const circuitName = `n${privateInputLength}m${privateOutputLength}`;
      expect(circuitName).to.equal(txs[i].name);
      const testName = `createTx with n${privateInputLength}m${privateOutputLength}`;
      console.log(testName);

      const beforeEthBalance = await ethers.provider.getBalance(cipher.address);
      // console.log(
      //   `${testName}: txIndex=${i}, beforeEthBalance`,
      //   beforeEthBalance.toString()
      // );
      const result = await cipher.createTx(
        contractCalldata.utxoData,
        contractCalldata.publicInfo,
        { value: utils.parseEther(tx.publicIn) }
      );
      await result.wait();
      // TODO: check event log
      // TODO: check balance change
      const afterEthBalance = await ethers.provider.getBalance(cipher.address);
      // console.log(
      //   `${testName}: txIndex=${i}, afterEthBalance`,
      //   afterEthBalance.toString()
      // );
    }
  };
}
