// import { expect } from "chai";
// import { resolve } from "path";
// import hre from "hardhat";
// import "@nomiclabs/hardhat-ethers";
// import {
//   Utxo,
//   Utxo__factory,
//   Verifier,
//   Verifier__factory,
// } from "../../typechain-types";
// import { DEFAULT_ZERO_LEAF_VALUE } from "../../config";
// import { prove } from "../prove";

// const ethers = hre.ethers;
// describe("n0m2", function () {
//   let UtxoFactory: Utxo__factory;
//   let utxo: Utxo;
//   let VerifierFactory: Verifier__factory;
//   let verifier: Verifier;
//   beforeEach(async function () {
//     VerifierFactory = (await ethers.getContractFactory(
//       "Verifier"
//     )) as Verifier__factory;
//     verifier = await VerifierFactory.deploy();

//     const PoseidonT3 = await ethers.getContractFactory("PoseidonT3");
//     const poseidonT3 = await PoseidonT3.deploy();
//     await poseidonT3.deployed();

//     const IncrementalBinaryTreeFactory = await ethers.getContractFactory(
//       "IncrementalBinaryTree",
//       {
//         libraries: {
//           PoseidonT3: poseidonT3.address,
//         },
//       }
//     );
//     const incrementalBinaryTree = await IncrementalBinaryTreeFactory.deploy();
//     await incrementalBinaryTree.deployed();

//     UtxoFactory = (await ethers.getContractFactory("Utxo", {
//       libraries: {
//         IncrementalBinaryTree: incrementalBinaryTree.address,
//       },
//     })) as Utxo__factory;

//     utxo = (await UtxoFactory.deploy(
//       5,
//       DEFAULT_ZERO_LEAF_VALUE,
//       verifier.address
//     )) as Utxo;
//     await utxo.deployed();
//   });

//   describe("verify", function () {
//     it("verify", async function () {
//       const circuitName = "h5n0m2";
//       const circomBaseDir = resolve(__dirname, `../../build/circuits/h5/n0m2`);
//       const zkeyPath = resolve(circomBaseDir, `h5n0m2_final.zkey`);
//       const inputPath = resolve(__dirname, "../circuit/h5n0m2/input.json");
//       const { calldata } = await prove(
//         circuitName,
//         circomBaseDir,
//         zkeyPath,
//         inputPath
//       );

//       const proof: Utxo.ProofStruct = {
//         a: calldata[0],
//         b: calldata[1],
//         c: calldata[2],
//         publicSignals: calldata[3],
//       };
//       const type = "0x0002";
//       await utxo.verify(verifier.address, proof, type);
//     });
//   });
// });
