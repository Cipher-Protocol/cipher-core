import { createReadStream, readdirSync, appendFileSync, rmSync } from "fs";
// eslint-disable-next-line @typescript-eslint/no-var-requires
const readline = require("readline");

import { resolve } from "path";

const outputVerifier = resolve(__dirname, "../contracts/VerifierConfig.sol");
const verifierBaseDir = resolve(__dirname, "../build/verifiers");
async function main() {
  rmSync(outputVerifier, { force: true });
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
    outputVerifier,
    `// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
  
contract VerifierConfig {\n`
  );

  const firstFile = files[0];
  const vkeyLines = await readVkeyFromVerifier(
    resolve(verifierBaseDir, firstFile)
  );
  for (const line of vkeyLines) {
    appendFileSync(
      outputVerifier,
      line.replace(
        "// Verification Key data",
        "/* ============ Shared Verification Key Data ============ */"
      )
    );
    appendFileSync(outputVerifier, "\n");
  }
  appendFileSync(outputVerifier, "\n\n");

  for (const file of files) {
    console.log(`file: ${file}`);
    // VerifierHaNbMc.sol
    const name = file
      .replace(".sol", "")
      .replace("Verifier", "")
      .toLowerCase()
      .slice(2, 6);
    appendFileSync(
      outputVerifier,
      `    /* ============ ${name} ============ */\n`
    );
    const lines = await readIcFromVerifier(resolve(verifierBaseDir, file));
    for (const line of lines) {
      appendFileSync(
        outputVerifier,
        line.replace("constant ", `constant ${name}_`)
      );
      appendFileSync(outputVerifier, "\n");
    }
  }

  appendFileSync(outputVerifier, `}\n`);
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
      const startRegex = /uint256 constant deltax1/;
      const endRegex = /\/\/ Memory data/;
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
