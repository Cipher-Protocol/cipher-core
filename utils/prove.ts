// eslint-disable-next-line @typescript-eslint/no-var-requires
const snarkjs = require("snarkjs");
const groth16 = snarkjs.groth16;
import { resolve } from "path";
import { readFileSync, writeFileSync } from "fs";
const DEBUG = false;

export async function proveByName(circuitName: string, inputPath?: string) {
  const heightName = circuitName.slice(0, 3)
  const specName = circuitName.slice(3, 7);
  const circomBaseDir = resolve(__dirname, `../build/circuits/${heightName}/${specName}`);
  const zkeyPath = resolve(circomBaseDir, `${circuitName}_final.zkey`);
  return await prove(
    circuitName,
    circomBaseDir,
    zkeyPath,
    inputPath || resolve(circomBaseDir, "input.json")
  );
}

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
    DEBUG ? console : undefined
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
