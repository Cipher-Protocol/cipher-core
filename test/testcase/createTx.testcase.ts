import { CreateTxTestCase } from "@test/helper/ts.helper";
import { ethTokenAddress } from "@utils/lib/cipher/CipherCore";

export const depositTxCases: CreateTxTestCase[] = [
  {
    tokenAddress: ethTokenAddress,
    txs: [
      {
        name: "n0m1",
        publicIn: "1",
        publicOut: "0",
        privateIns: [],
        privateOuts: ["1"],
      },
    ],
  },
  {
    tokenAddress: ethTokenAddress,
    txs: [
      {
        name: "n0m2",
        publicIn: "1",
        publicOut: "0",
        privateIns: [],
        privateOuts: ["0.5", "0.5"],
      },
    ],
  },
  {
    tokenAddress: ethTokenAddress,
    txs: [
      {
        name: "n0m4",
        publicIn: "2",
        publicOut: "0",
        privateIns: [],
        privateOuts: ["0.5", "0.5", "0.5", "0.5"],
      },
    ],
  },
];

export const withdrawTxCases: CreateTxTestCase[] = [
  {
    tokenAddress: ethTokenAddress,
    txs: [
      {
        name: "n0m1",
        publicIn: "1",
        publicOut: "0",
        privateIns: [],
        privateOuts: ["1"],
      },
      {
        name: "n1m0",
        publicIn: "0",
        publicOut: "1",
        privateIns: ["1"],
        privateOuts: [],
      },
    ],
  },
  {
    tokenAddress: ethTokenAddress,
    txs: [
      {
        name: "n0m1",
        publicIn: "1",
        publicOut: "0",
        privateIns: [],
        privateOuts: ["1"],
      },
      {
        name: "n1m1",
        publicIn: "0",
        publicOut: "0.1",
        privateIns: ["1"],
        privateOuts: ["0.9"],
      },
    ],
  },
  {
    tokenAddress: ethTokenAddress,
    txs: [
      {
        name: "n0m2",
        publicIn: "1",
        publicOut: "0",
        privateIns: [],
        privateOuts: ["0.4", "0.6"],
      },
      {
        name: "n2m0",
        publicIn: "0",
        publicOut: "1",
        privateIns: ["0.4", "0.6"],
        privateOuts: [],
      },
    ],
  },
  {
    tokenAddress: ethTokenAddress,
    txs: [
      {
        name: "n0m2",
        publicIn: "1",
        publicOut: "0",
        privateIns: [],
        privateOuts: ["0.4", "0.6"],
      },
      {
        name: "n2m1",
        publicIn: "0",
        publicOut: "0.9",
        privateIns: ["0.4", "0.6"],
        privateOuts: ["0.1"],
      },
    ],
  },
  {
    tokenAddress: ethTokenAddress,
    txs: [
      {
        name: "n0m4",
        publicIn: "1",
        publicOut: "0",
        privateIns: [],
        privateOuts: ["0.1", "0.2", "0.3", "0.4"],
      },
      {
        name: "n4m0",
        publicIn: "0",
        publicOut: "1",
        privateIns: ["0.1", "0.2", "0.3", "0.4"],
        privateOuts: [],
      },
    ],
  },
  {
    tokenAddress: ethTokenAddress,
    txs: [
      {
        name: "n0m4",
        publicIn: "1",
        publicOut: "0",
        privateIns: [],
        privateOuts: ["0.1", "0.2", "0.3", "0.4"],
      },
      {
        name: "n4m1",
        publicIn: "0",
        publicOut: "0.9",
        privateIns: ["0.1", "0.2", "0.3", "0.4"],
        privateOuts: ["0.1"],
      },
    ],
  },
];
