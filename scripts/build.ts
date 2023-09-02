/* eslint-disable @typescript-eslint/no-var-requires */
const snarkjs = require("snarkjs");
import { resolve } from "path";
import { writeFileSync, mkdirSync, rmSync } from "fs";
import util from "util";
import * as dotenv from "dotenv";
const _exec = util.promisify(require("child_process").exec);

const PTAU_PATH = resolve(__dirname, "../ptau/pot14_final.ptau");
const IS_CLEAR_BUILD_DIR = true;
dotenv.config();

const groth16 = snarkjs.groth16;

async function main() {
  await generateZkey("deposit");
  await generateZkey("withdraw");
}

async function generateZkey(circomName: string) {
  console.log("generate ${circomName} start...");

  const mainCircomPath = resolve(__dirname, `../circuits/${circomName}.circom`);
  const outputDir = resolve(__dirname, `../build/${circomName}`);
  if (IS_CLEAR_BUILD_DIR) {
    rmSync(outputDir, { recursive: true, force: true });
  }
  const ptauPath = PTAU_PATH;

  const { r1csPath } = await buildCircom(mainCircomPath, circomName, outputDir);

  console.time(`generate ${circomName}`);
  const zkey0Path = resolve(outputDir, `${circomName}_zkey_0.zkey`);
  await setup(r1csPath, ptauPath, zkey0Path);

  const zkey1Path = resolve(outputDir, `${circomName}_zkey_1.zkey`);
  await contributeZkey(zkey0Path, zkey1Path, "zkey 1 random string");

  const finalZkeyPath = resolve(outputDir, `${circomName}_zkey_final.zkey`);
  await finalizeZkey(r1csPath, ptauPath, zkey1Path, finalZkeyPath);

  const vkeyPath = resolve(outputDir, `${circomName}_vkey.json`);
  await exportVkey(finalZkeyPath, vkeyPath);

  console.timeEnd(`generate ${circomName}`);

  console.log("generate ${circomName} done.");

  return {
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

  await exec(`circom ${mainCircomPath} --r1cs --wasm --output ${outputDir}`);

  console.timeEnd(`build ${mainCircomPath}`);

  return {
    r1csPath,
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

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
