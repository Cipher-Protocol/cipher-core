import { DEFAULT_TREE_HEIGHT, DEFAULT_ZERO_VALUE } from "@/config";
import {
  multipleTxsCases,
  tripleTxsCases,
  doubleTxsCases,
} from "@test/testcase/createTx-all-spec.testcase";
import {
  depositTxCases,
  withdrawTxCases,
} from "@test/testcase/createTx.testcase";
import { exportTestData } from "@test/helper/ts.helper";
import { initTree } from "@utils/lib/cipher/CipherCore";

import { resolve } from "path";
import { rmSync, mkdirSync, writeFileSync, existsSync } from "fs";
import { asyncPoseidonHash } from "@/utils/lib/poseidonHash";

const SPEC = {
  treeHeight: DEFAULT_TREE_HEIGHT,
  defaultLeafHash: DEFAULT_ZERO_VALUE,
};

const outputBaseDir = resolve(__dirname, "../tests/testData");
async function main() {
  await asyncPoseidonHash;
  const srcCases = [
    { name: "deposit", cases: depositTxCases },
    { name: "withdraw", cases: withdrawTxCases },
    { name: "doubleTxs", cases: doubleTxsCases },
    { name: "tripleTxs", cases: tripleTxsCases },
    { name: "multipleTxs", cases: multipleTxsCases },
  ];

  for (let i = 0; i < srcCases.length; i++) {
    const item = srcCases[i];
    const { name, cases } = item;
    const outputDir = resolve(outputBaseDir, name);
    if (existsSync(outputDir)) {
      rmSync(outputDir, { recursive: true });
    }
    mkdirSync(outputDir, { recursive: true });
    console.log(`${name}: start`);
    for (let i = 0; i < cases.length; i++) {
      const c = cases[i];
      const tree = initTree(SPEC.treeHeight, SPEC.defaultLeafHash);
      const { testName, calldataList } = await exportTestData(c, { tree });
      const outputFilePath = resolve(outputDir, `${i}_${testName}.json`);
      writeFileSync(outputFilePath, JSON.stringify(calldataList, null, 2));
      console.log(`${name}: write to ${outputFilePath}`);
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
