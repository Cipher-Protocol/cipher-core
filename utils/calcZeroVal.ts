import { DEFAULT_ZERO_LEAF_VALUE } from "../config";
import { calcPoseidonHash } from "./calcPoseidonHash";

// calculate zero value for merkle tree
export const calcZeroValue = (
  defaultZeroLeafValue: string,
  treeLevel: number
) => {
  const zeroValueArr: string[] = [];
  let zeroValue = defaultZeroLeafValue;
  for (let i = 0; i < treeLevel; i++) {
    zeroValue = calcPoseidonHash([zeroValue, zeroValue]);
    zeroValueArr.push(zeroValue);
    // console.log(`LEVEL${i + 1}_NODE_ZERO_VALUE = "${zeroValueArr[i]}"`);
  }
  return zeroValueArr;
};
// calcZeroValue(DEFAULT_ZERO_LEAF_VALUE, 5);
