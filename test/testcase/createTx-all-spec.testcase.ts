import { CreateTxTestCase } from "@/test/helper/ts.helper";
import { ethTokenAddress } from "@/utils/lib/cipher/CipherCore";

export const doubleTxsCases: CreateTxTestCase[] = [
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
        name: "n0m1",
        publicIn: "1",
        publicOut: "0",
        privateIns: [],
        privateOuts: ["1"],
      },
      {
        name: "n1m2",
        publicIn: "0",
        publicOut: "0.1",
        privateIns: ["1"],
        privateOuts: ["0.4", "0.5"],
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
        name: "n1m4",
        publicIn: "0",
        publicOut: "0",
        privateIns: ["1"],
        privateOuts: ["0.3", "0.3", "0.3", "0.1"],
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
      {
        name: "n2m0",
        publicIn: "0",
        publicOut: "1",
        privateIns: ["0.5", "0.5"],
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
        privateOuts: ["0.5", "0.5"],
      },
      {
        name: "n2m1",
        publicIn: "0",
        publicOut: "0",
        privateIns: ["0.5", "0.5"],
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
      {
        name: "n2m2",
        publicIn: "0",
        publicOut: "0",
        privateIns: ["0.5", "0.5"],
        privateOuts: ["0.6", "0.4"],
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
      {
        name: "n2m4",
        publicIn: "0",
        publicOut: "0",
        privateIns: ["0.5", "0.5"],
        privateOuts: ["0.25", "0.25", "0.25", "0.25"],
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
        privateOuts: ["0.25", "0.25", "0.25", "0.25"],
      },
      {
        name: "n4m0",
        publicIn: "0",
        publicOut: "1",
        privateIns: ["0.25", "0.25", "0.25", "0.25"],
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
        privateOuts: ["0.25", "0.25", "0.25", "0.25"],
      },
      {
        name: "n4m1",
        publicIn: "0",
        publicOut: "0",
        privateIns: ["0.25", "0.25", "0.25", "0.25"],
        privateOuts: ["1"],
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
        privateOuts: ["0.25", "0.25", "0.25", "0.25"],
      },
      {
        name: "n4m2",
        publicIn: "0",
        publicOut: "0",
        privateIns: ["0.25", "0.25", "0.25", "0.25"],
        privateOuts: ["0.5", "0.5"],
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
        privateOuts: ["0.25", "0.25", "0.25", "0.25"],
      },
      {
        name: "n4m4",
        publicIn: "0",
        publicOut: "0.2",
        privateIns: ["0.25", "0.25", "0.25", "0.25"],
        privateOuts: ["0.2", "0.2", "0.2", "0.2"],
      },
    ],
  },
];

export const multipleTxsCases: CreateTxTestCase[] = [
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
        name: "n1m2",
        publicIn: "0",
        publicOut: "0.1",
        privateIns: ["1"],
        privateOuts: ["0.4", "0.5"],
      },
      {
        name: "n2m4",
        publicIn: "0",
        publicOut: "0.1",
        privateIns: ["0.4", "0.5"],
        privateOuts: ["0.2", "0.2", "0.2", "0.2"],
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
      {
        name: "n2m4",
        publicIn: "0",
        publicOut: "0",
        privateIns: ["0.5", "0.5"],
        privateOuts: ["0.1", "0.2", "0.3", "0.4"],
      },
      {
        name: "n4m2",
        publicIn: "0",
        publicOut: "0.2",
        privateIns: ["0.1", "0.2", "0.3", "0.4"],
        privateOuts: ["0.05", "0.15", "0.25", "0.35"],
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
        privateOuts: ["0.6", "0.4"],
      },
      {
        name: "n2m1",
        publicIn: "0",
        publicOut: "0.1",
        privateIns: ["0.6", "0.4"],
        privateOuts: ["0.9"],
      },
      {
        name: "n2m4",
        publicIn: "0",
        publicOut: "0.1",
        privateIns: ["0.4", "0.5"],
        privateOuts: ["0.", "0.15", "0.25", "0.35"],
      },
    ],
  },
];
