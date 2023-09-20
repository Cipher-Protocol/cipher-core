import { DEFAULT_ZERO_LEAF_VALUE } from "../config";
import { calcPoseidonHash } from "./calcPoseidonHash";

// calculate zero value for merkle tree
export const calcZeroValue = (
  defaultZeroLeafValue: string,
  treeLevel: number
) => {
  const zeroValueArr: string[] = [defaultZeroLeafValue];
  let zeroValue = defaultZeroLeafValue;
  for (let i = 0; i < treeLevel - 1; i++) {
    zeroValue = calcPoseidonHash([zeroValue, zeroValue]);
    zeroValueArr.push(zeroValue);
    // console.log(`LEVEL${i}_NODE_ZERO_VALUE = "${zeroValueArr[i]}"`);
  }
  return zeroValueArr;
};
// calcZeroValue(DEFAULT_ZERO_LEAF_VALUE, 5);

export const calcInitRoot = (
  defaultZeroLeafValue: string,
  treeLevel: number
) => {
  let zeroValue = defaultZeroLeafValue;
  for (let i = 0; i < treeLevel; i++) {
    zeroValue = calcPoseidonHash([zeroValue, zeroValue]);
    // console.log(`INIT_ROOT_VALUE = "${zeroValue[i]}"`);
  }
  return zeroValue;
};
