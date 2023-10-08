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
  "../contracts/CipherVKeyConst.sol"
);
const outputVerifierPath = resolve(
  __dirname,
  "../contracts/CipherVerifier.sol"
);
const verifierBaseDir = resolve(__dirname, "../build/verifiers");
const templateConfigPath = resolve(
  __dirname,
  "./template/CipherVKeyConst.sol.ejs"
);
const templateMainPath = resolve(
  __dirname,
  "./template/CipherVerifier.sol.ejs"
);
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

  const firstFile = files[0];
  const test = resolve(verifierBaseDir, firstFile);
  console.log({ test });
  const vkeyLines = await readVkeyFromVerifier(
    resolve(verifierBaseDir, firstFile)
  );
  let VkeyData = "";
  for (const line of vkeyLines) {
    VkeyData += line.replace(
      "// Verification Key data",
      "/* ============ Shared Verification Key Data ============ */"
    );
    VkeyData += "\n";
  }

  const ejsData = {
    DeltaCases: [] as any[],
    IcCases: [] as any[],
    MulAccCases: [] as any[],
  };

  const ContDataList: string[] = [];
  for (const file of files) {
    console.log(`file: ${file}`);
    // VerifierHaNbMc.sol
    const name = file
      .replace(".sol", "")
      .replace("Verifier", "")
      .toLowerCase()
      .slice(3, 7);
    ContDataList.push(`    /* ============ ${name} ============ */\n`);
    const { lines, delta, ic } = await readIcFromVerifier(
      resolve(verifierBaseDir, file)
    );
    for (const line of lines) {
      ContDataList.push(line.replace("constant ", `constant ${name}_`));
      ContDataList.push("\n");
    }
    const configResult = await parseVerifierConfig({
      VkeyData,
      ContDataList,
    });
    writeFileSync(outputVerifierConfigPath, configResult, "utf-8");

    console.log({
      name,
      delta,
      ic,
    });
    const hexCode = name2HexCode(name);
    const deltaCase = parseDeltaCases(name, hexCode, delta);
    const icCase = parseIcCases(name, hexCode, 5);
    const spec = name2Spec(name);
    const mulAccCase = parseMulAccCases(
      name,
      spec.nNum,
      spec.mNum,
      hexCode,
      ic
    );
    ejsData.DeltaCases.push(deltaCase);
    ejsData.IcCases.push(icCase);
    ejsData.MulAccCases.push(mulAccCase);
  }

  console.log({
    length: ejsData.DeltaCases.length,
  });
  const main = await parseVerifierMain(ejsData);
  writeFileSync(outputVerifierPath, main, "utf-8");

  // appendFileSync(outputVerifierConfigPath, `}\n`);
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
      const startRegex = /\/\/ Verification Key data/;
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
          lines.push(
            line.replace("uint256 constant", "uint256 internal constant")
          );
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
      const icRegex = /uint256 constant IC(\d+)x/;
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
          lines.push(
            line.replace("uint256 constant", "uint256 internal constant")
          );
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

function name2Spec(name: string) {
  const regex = /n(\d+)m(\d+)/;
  const specs = regex.exec(name) || [];
  const nNum = Number(specs[1]);
  const mNum = Number(specs[2]);
  return {
    nNum,
    mNum,
  };
}

function name2HexCode(name: string): string {
  const regex = /n(\d+)m(\d+)/;
  const specs = regex.exec(name) || [];
  const nNum = Number(specs[1]);
  const mNum = Number(specs[2]);

  if (isNaN(nNum) || isNaN(mNum)) {
    throw new Error(`Invalid name: ${name}, nNum=${nNum}, mNum=${mNum}`);
  }

  const hexCode = `${nNum.toString().padStart(2, "0")}${mNum
    .toString()
    .padStart(2, "0")}`;
  return hexCode;
}

function parseDeltaCases(name: string, hexCode: string, delta: number): string {
  let str = `case hex"${hexCode}" {\n`;
  str += `deltax1 := ${name}_deltax1\n`;
  str += `deltax2 := ${name}_deltax2\n`;
  str += `deltay1 := ${name}_deltay1\n`;
  str += `deltay2 := ${name}_deltay2\n`;
  str += "}";
  return prettier(str, 16);
}
function parseIcCases(name: string, hexCode: string, ic: number): string {
  let str = `case hex"${hexCode}" {\n`;
  for (let index = 0; index < ic; index++) {
    str += `IC${index}x := ${name}_IC${index}x\n`;
    str += `IC${index}y := ${name}_IC${index}y\n`;
  }
  str += `}`;
  return prettier(str, 16);
}
function parseMulAccCases(
  name: string,
  inNum: number,
  outNumber: number,
  hexCode: string,
  ic: number
): string {
  let str = `case hex"${hexCode}" {\n`;
  const inIcLen = 5 + inNum;
  const outIcLen = ic;
  for (let index = 5; index < inIcLen; index++) {
    const offset = (index - 4) * 32;
    str += `ecMulAcc(_pVk, ${name}_IC${index}x, ${name}_IC${index}y, calldataload(add(inputNullifiersPos, ${offset})))\n`;
  }
  for (let index = inIcLen; index < outIcLen; index++) {
    const offset = (index - inIcLen + 1) * 32;
    str += `ecMulAcc(_pVk, ${name}_IC${index}x, ${name}_IC${index}y, calldataload(add(outputCommitmentsPos, ${offset})))\n`;
  }
  str += `}`;
  return prettier(str, 16);
}

function prettier(str: string, padNum: number): string {
  const lines = str.split("\n");
  let result = "";
  const pad1 = new Array(padNum).fill(" ").join("");
  const pad2 = new Array(padNum + 4).fill(" ").join("");
  for (let index = 0; index < lines.length; index++) {
    const s = lines[index];
    if (index === 0) {
      result += `${pad1}${s}\n`;
    } else if (index === lines.length - 1) {
      result += `${pad1}${s}\n`;
    } else {
      result += `${pad2}${s}\n`;
    }
  }
  return result;
}

async function parseVerifierConfig(ejsData: {
  VkeyData: string;
  ContDataList: string[];
}) {
  // eslint-disable-next-line no-async-promise-executor
  return new Promise<string>(async (resolve, reject) => {
    try {
      const templateStr = readFileSync(templateConfigPath, "utf-8");
      const result = await ejs.render(templateStr, ejsData, { async: true });
      resolve(result);
    } catch (error) {
      console.error(error);
      reject(error);
    }
  });
}

async function parseVerifierMain(ejsData: {
  DeltaCases: any[];
  IcCases: any[];
  MulAccCases: any[];
}) {
  // eslint-disable-next-line no-async-promise-executor
  return new Promise<string>(async (resolve, reject) => {
    try {
      const templateStr = readFileSync(templateMainPath, "utf-8");
      const result = await ejs.render(templateStr, ejsData, { async: true });
      resolve(result);
    } catch (error) {
      console.error(error);
      reject(error);
    }
  });
}
