import { DEFAULT_ZERO_LEAF_VALUE } from "../config";
const poseidon = require("poseidon-encryption");

// calculate zero value for merkle tree
export const calcZeroValue = (
  defaultZeroLeafValue: string,
  treeLevel: number
) => {
  const zeroValueArr: String[] = [];
  let zeroValue = defaultZeroLeafValue;
  for (let i = 0; i < treeLevel; i++) {
    zeroValue = poseidon.poseidon([zeroValue, zeroValue]).toString();
    zeroValueArr.push(zeroValue);
    // console.log(`LEVEL${i + 1}_NODE_ZERO_VALUE = "${zeroValueArr[i]}"`);
  }
  return zeroValueArr;
};
// calcZeroValue(DEFAULT_ZERO_LEAF_VALUE, 5);
