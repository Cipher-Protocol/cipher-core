// eslint-disable-next-line @typescript-eslint/no-var-requires
const snarkjs = require("snarkjs");
const groth16 = snarkjs.groth16;
import { resolve } from "path";
import { readFileSync, writeFileSync } from "fs";

export async function prove(
  circuitName: string,
  circomBaseDir: string,
  zkeyPath: string,
  inputPath: string
) {
  const inputContent = JSON.parse(readFileSync(inputPath, "utf8"));
  const wasmPath = resolve(
    circomBaseDir,
    `./${circuitName}_js/${circuitName}.wasm`
  );

  const { proof, publicSignals } = await groth16.fullProve(
    inputContent,
    wasmPath,
    zkeyPath,
    console
  );

  // const witnessPath = resolve(circomBaseDir, `${circuitName}_witness.wtns`);
  // await generateWitness(circuitName, circomBaseDir, inputPath, witnessPath);

  // const { proof, publicSignals } = await generateProof(zkeyPath, witnessPath);

  const calldataPath = resolve(circomBaseDir, `${circuitName}_calldata.json`);
  const { calldata } = await generateSolidityCalldata(
    proof,
    publicSignals,
    calldataPath
  );

  return {
    // witnessPath,
    calldataPath,
    calldata,
  };
}

async function generateSolidityCalldata(
  proof: any,
  publicSignals: any,
  calldataPath: string
) {
  const stdout = await groth16.exportSolidityCallData(proof, publicSignals);
  const raw = `[${stdout}]`;
  const calldata = JSON.parse(raw);
  writeFileSync(calldataPath, raw);
  return {
    calldata,
    calldataPath,
  };
}
