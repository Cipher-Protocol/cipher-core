/* eslint-disable @typescript-eslint/no-var-requires */
const snarkjs = require("snarkjs");
import { resolve } from "path";
import {
  writeFileSync,
  mkdirSync,
  rmSync,
  appendFileSync,
  readFileSync,
  existsSync,
} from "fs";
import util from "util";
import * as dotenv from "dotenv";
import { DEFAULT_TREE_HEIGHT, DEFAULT_ZERO_LEAF_VALUE } from "../config";
const _exec = util.promisify(require("child_process").exec);

const PTAU_PATH = resolve(__dirname, "../ptau/pot14_final.ptau");
const IS_CLEAR_CIRCOM_BUILD_DIR = true;
const BASE_DIR = resolve(__dirname, "../build/circuits");
const UTXO_CONFIG_PATH = resolve(__dirname, "../utxo_config.json");
dotenv.config();

interface UtxoConfigInterface {
  nIns: number;
  mOuts: number;
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

async function main() {
  const levels = DEFAULT_TREE_HEIGHT;
  if (IS_CLEAR_CIRCOM_BUILD_DIR) {
    rmSync(BASE_DIR, { recursive: true, force: true });
  }
  if (!existsSync(BASE_DIR)) {
    mkdirSync(BASE_DIR, { recursive: true });
  }
  const buildInfoPath = resolve(BASE_DIR, "build-info.json");
  const utxoConfigList = JSON.parse(
    readFileSync(UTXO_CONFIG_PATH, "utf8")
  ) as unknown as UtxoConfigInterface[];
  /**
   * Make deposit circom
   */
  const circuitOutputList: any[] = [];
  for (let index = 0; index <= utxoConfigList.length; index++) {
    const config = utxoConfigList[index];
    const { name, mainCircomPath } = await makeMainCircom({
      levels,
      nIns: config.nIns,
      mOuts: config.mOuts,
      // TODO: zeroLeaf should be generated
      zeroLeaf: DEFAULT_ZERO_LEAF_VALUE,
    });
    const result = await generateZkey(name, mainCircomPath);
    circuitOutputList.push({
      ...result,
      name,
      mainCircomPath,
      createTime: new Date().toISOString(),
    });
  }

  writeFileSync(buildInfoPath, JSON.stringify(circuitOutputList, null, 2));
}

async function makeMainCircom(spec: {
  levels: number;
  nIns: number;
  mOuts: number;
  zeroLeaf: string;
}) {
  const name = `h${spec.levels}n${spec.nIns}m${spec.mOuts}`;
  const outDir = resolve(BASE_DIR, `./${name}`);
  const mainCircomPath = resolve(outDir, `${name}.circom`);
  mkdirSync(outDir, { recursive: true });

  const circomSourceCode = `
pragma circom 2.1.5;

include "../../../circuits/utxo.circom";

/// deposit input ${spec.nIns}, output ${spec.mOuts} circuit
component main {public [root, publicInAmt, publicOutAmt, extDataHash, inputNullifier, outputCommitment]}
  = Utxo(${spec.levels}, ${spec.nIns}, ${spec.mOuts}, ${spec.zeroLeaf});
`;

  writeFileSync(mainCircomPath, circomSourceCode);
  return {
    name,
    outDir,
    mainCircomPath,
  };
}

async function generateZkey(circomName: string, mainCircomPath: string) {
  console.log(`generate ${circomName} start...`);

  const outputDir = resolve(mainCircomPath, `../`);
  const ptauPath = PTAU_PATH;

  const { r1csPath, constraints } = await buildCircom(
    mainCircomPath,
    circomName,
    outputDir
  );

  console.time(`generate ${circomName}`);
  const zkey0Path = resolve(outputDir, `${circomName}_zkey_0.zkey`);
  await setup(r1csPath, ptauPath, zkey0Path);

  const zkey1Path = resolve(outputDir, `${circomName}_zkey_1.zkey`);
  await contributeZkey(zkey0Path, zkey1Path, "zkey 1 random string");

  const finalZkeyPath = resolve(outputDir, `${circomName}_zkey_final.zkey`);
  await finalizeZkey(r1csPath, ptauPath, zkey1Path, finalZkeyPath);

  const vkeyPath = resolve(outputDir, `${circomName}_vkey.json`);
  await exportVkey(finalZkeyPath, vkeyPath);

  const solidityVerifierPath = resolve(outputDir, `${circomName}_verifier.sol`);
  await exportSolidityVerifier(finalZkeyPath, solidityVerifierPath);

  console.timeEnd(`generate ${circomName}`);
  console.log(`generate ${circomName} done.`);
  return {
    constraints,
    r1csPath,
    zkey0Path,
    zkey1Path,
    finalZkeyPath,
    vkeyPath,
  };
}

async function buildCircom(
  mainCircomPath: string,
  circomName: string,
  outputDir: string
) {
  console.time(`build ${mainCircomPath}`);
  mkdirSync(outputDir, { recursive: true });
  const r1csPath = resolve(outputDir, `${circomName}.r1cs`);

  const { stdout } = await exec(
    `circom ${mainCircomPath} --r1cs --wasm --output ${outputDir}`
  );
  const regex = /non-linear constraints:\s+(\d+)/;
  const match = stdout.match(regex);

  console.timeEnd(`build ${mainCircomPath}`);

  return {
    r1csPath,
    constraints: match ? match[1] : null,
  };
}

async function setup(r1csPath: string, ptauPath: string, zkey0Path: string) {
  const result = await snarkjs.zKey.newZKey(
    r1csPath,
    ptauPath,
    zkey0Path,
    console
  );
  console.log({
    context: "setup",
    result,
  });
}

async function contributeZkey(
  previousZkeyPath: string,
  nextZkeyPath: string,
  entropy: string,
  name = ""
) {
  if (!name) {
    name = nextZkeyPath;
  }
  const result = await snarkjs.zKey.contribute(
    previousZkeyPath,
    nextZkeyPath,
    name,
    entropy
  );
  console.log({
    context: "contribute",
    result,
  });
}

async function finalizeZkey(
  r1csPath: string,
  ptauPath: string,
  sourceZkeyPath: string,
  finalZkeyPath: string,
  beaconHashStr: string = "0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20",
  numIterationsExp = 10,
  name: string = "final zkey"
) {
  await snarkjs.zKey.beacon(
    sourceZkeyPath,
    finalZkeyPath,
    name,
    beaconHashStr,
    numIterationsExp,
    console
  );

  // zkey verify r1cs
  const result = await snarkjs.zKey.verifyFromR1cs(
    r1csPath,
    ptauPath,
    finalZkeyPath
  );
  if (!result) {
    throw new Error("zkey verification failed");
  }
}

async function exportVkey(finalZkeyPath: string, vkeyPath: string) {
  const vKey = await snarkjs.zKey.exportVerificationKey(finalZkeyPath);
  writeFileSync(vkeyPath, JSON.stringify(vKey, null, 2));
}

async function exportSolidityVerifier(
  finalZkeyPath: string,
  solidityVerifierPath: string
) {
  function readTemplate(name: string) {
    return readFileSync(
      resolve(__dirname, "../node_modules/snarkjs/templates", name),
      "utf8"
    );
  }
  const templates = {
    groth16: readTemplate("verifier_groth16.sol.ejs"),
    plonk: readTemplate("verifier_plonk.sol.ejs"),
  };
  const solidity = await snarkjs.zKey.exportSolidityVerifier(
    finalZkeyPath,
    templates,
    console
  );

  writeFileSync(solidityVerifierPath, solidity);
  return solidity;
}

const cmdLogs: string[] = [];
function exec(
  cmd: string
): Promise<{ id: number; cmd: string; stdout: string }> {
  cmdLogs.push(cmd);
  const id = cmdLogs.length - 1;
  console.log(`exec command(${id}): ${cmd}`);
  return new Promise((resolve, reject) => {
    _exec(cmd)
      .then(({ stdout, stderr }: { stdout: string; stderr: string }) => {
        if (stderr) throw new Error(stderr);
        console.log(stdout);
        return resolve({ id, cmd: cmdLogs[id], stdout });
      })
      .catch((stderr: any) => {
        console.error(stderr);
        return reject(stderr);
      });
  });
}
