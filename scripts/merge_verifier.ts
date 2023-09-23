import {
  createReadStream,
  readdirSync,
  appendFileSync,
  rmSync,
  readFileSync,
  writeFileSync,
} from "fs";
import * as ejs from "ejs";
// eslint-disable-next-line @typescript-eslint/no-var-requires
const readline = require("readline");

import { resolve } from "path";

const outputVerifierConfigPath = resolve(
  __dirname,
  "../contracts/VerifierConfig.sol"
);
const outputVerifierPath = resolve(__dirname, "../contracts/Verifier.sol");
const verifierBaseDir = resolve(__dirname, "../build/verifiers");
const templatePath = resolve(__dirname, "./template/Verifier.sol.ejs");
async function main() {
  rmSync(outputVerifierConfigPath, { force: true });
  rmSync(outputVerifierPath, { force: true });
  await mergeVerifiers(verifierBaseDir);

  console.log("done");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

async function mergeVerifiers(verifierBaseDir: string) {
  const files = readdirSync(verifierBaseDir);
  console.log({
    files: files.length,
  });

  appendFileSync(
    outputVerifierConfigPath,
    `// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
  
contract VerifierConfig {\n`
  );

  const firstFile = files[0];
  const test = resolve(verifierBaseDir, firstFile);
  console.log({ test });
  const vkeyLines = await readVkeyFromVerifier(
    resolve(verifierBaseDir, firstFile)
  );
  for (const line of vkeyLines) {
    appendFileSync(
      outputVerifierConfigPath,
      line.replace(
        "// Verification Key data",
        "/* ============ Shared Verification Key Data ============ */"
      )
    );
    appendFileSync(outputVerifierConfigPath, "\n");
  }
  appendFileSync(outputVerifierConfigPath, "\n\n");

  for (const file of files) {
    console.log(`file: ${file}`);
    // VerifierHaNbMc.sol
    const name = file
      .replace(".sol", "")
      .replace("Verifier", "")
      .toLowerCase()
      .slice(2, 6);
    appendFileSync(
      outputVerifierConfigPath,
      `    /* ============ ${name} ============ */\n`
    );
    const { lines, delta, ic } = await readIcFromVerifier(
      resolve(verifierBaseDir, file)
    );
    for (const line of lines) {
      appendFileSync(
        outputVerifierConfigPath,
        line.replace("constant ", `constant ${name}_`)
      );
      appendFileSync(outputVerifierConfigPath, "\n");
    }

    // const main = await parseVerifierMain(name, delta, ic);
    // writeFileSync(outputVerifierPath, main, "utf-8");
  }

  appendFileSync(outputVerifierConfigPath, `}\n`);
}

async function readVkeyFromVerifier(file: string) {
  return new Promise<string[]>((resolve, reject) => {
    // return resolve([file]);
    try {
      const lines: string[] = [];
      const rlInterface = readline.createInterface({
        input: createReadStream(file, {
          encoding: "utf-8",
        }),
        output: process.stdout,
        terminal: false, // to indicate this is not TTY
      });
      let lineCnt = 0;
      let isReading = false;
      const startRegex = /\/\/ Scalar field size/;
      const endRegex = /uint256 constant deltax1/;
      rlInterface.on("line", (line: string) => {
        lineCnt++;
        if (startRegex.test(line)) {
          isReading = true;
        }

        if (endRegex.test(line)) {
          isReading = false;
          rlInterface.close();
          resolve(lines);
        }

        if (isReading) {
          lines.push(line);
        }
      });
      rlInterface.on("error", (err: any) => reject(err));
    } catch (error) {
      console.error(error);
      reject(error);
    }
  });
}

async function readIcFromVerifier(file: string) {
  return new Promise<{
    lines: string[];
    delta: number;
    ic: number;
    lineCnt: number;
  }>((resolve, reject) => {
    // return resolve([file]);
    try {
      const lines: string[] = [];
      const rlInterface = readline.createInterface({
        input: createReadStream(file, {
          encoding: "utf-8",
        }),
        output: process.stdout,
        terminal: false, // to indicate this is not TTY
      });
      let lineCnt = 0;
      let isReading = false;
      const startRegex = /uint256 constant deltax1/;
      const endRegex = /\/\/ Memory data/;

      const deltaRegex = /uint256 constant deltax(\d+)/;
      const icRegex = /uint256 constant ic(\d+)/;
      const countInfo = {
        delta: 0,
        ic: 0,
      };
      rlInterface.on("line", (line: string) => {
        lineCnt++;
        if (startRegex.test(line)) {
          isReading = true;
        }

        if (endRegex.test(line)) {
          isReading = false;
          rlInterface.close();
          resolve({
            lines,
            lineCnt,
            ...countInfo,
          });
        }

        if (isReading) {
          lines.push(line);
          if (deltaRegex.test(line)) {
            countInfo.delta++;
          }
          if (icRegex.test(line)) {
            countInfo.ic++;
          }
        }
      });
      rlInterface.on("error", (err: any) => reject(err));
    } catch (error) {
      console.error(error);
      reject(error);
    }
  });
}

function name2HexCode(name: string): string {
  const regex = /n(\d+)m(\d+)/;
  const specs = regex.exec(name) || [];
  const nNum = Number(specs[1]);
  const mNum = Number(specs[2]);

  if (isNaN(nNum) || isNaN(mNum)) {
    throw new Error("Invalid name: " + name);
  }

  const hexCode = `${nNum.toString().padStart(2, "0")}${mNum
    .toString()
    .padStart(2, "0")}`;
  return hexCode;
}

function parseDeltaCases(name: string, hexCode: string, delta: number): string {
  const str = `
  case hex"0002" {
    deltax1 := ${name}_deltax1
    deltax2 := ${name}_deltax2
    deltay1 := ${name}_deltay1
    deltay2 := ${name}_deltay2
  }`;
  return str;
}
function parseIcCases(name: string, hexCode: string, ic: number): string {
  let str = `case hex"${hexCode}" {\n`;
  for (let index = 0; index < ic; index++) {
    str += `IC${index}x := ${name}_IC${index}x\n`;
    str += `IC${index}y := ${name}_IC${index}y\n`;
  }
  str = `}\n`;
  return str;
}
function parseMulAccCases(name: string, hexCode: string, ic: number): string {
  let str = `case hex"${hexCode}" {\n`;
  for (let index = 1; index < ic; index++) {
    const offset = (index - 1) * 32;
    if (index === 1) {
      str += `g1_mulAccC(_pVk, ${name}_IC${index}x, ${name}_IC${index}y, calldataload(pubSignals))\n`;
    } else {
      str += `g1_mulAccC(_pVk, ${name}_IC${index}x, ${name}_IC${index}y, calldataload(add(pubSignals, ${offset})))\n`;
    }
  }
  str = `}\n`;
  return str;
}

async function parseVerifierMain(name: string, delta: number, ic: number) {
  // eslint-disable-next-line no-async-promise-executor
  return new Promise<string>(async (resolve, reject) => {
    try {
      const hexCode = name2HexCode(name);
      const templateStr = readFileSync(templatePath, "utf-8");
      const data = {
        DeltaCases: parseDeltaCases(name, hexCode, delta),
        IcCases: parseIcCases(name, hexCode, ic),
        MulAccCases: parseMulAccCases(name, hexCode, ic),
      };
      const result = await ejs.render(templateStr, data, { async: true });
      resolve(result);
    } catch (error) {
      console.error(error);
      reject(error);
    }
  });
}
