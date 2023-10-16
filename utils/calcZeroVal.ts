import { BigNumber } from "ethers";
import { calcPoseidonHash } from "./calcPoseidonHash";
import { SNARK_FIELD_SIZE } from "../config";

// calculate zero value for merkle tree
export const calcZeroValue = (
  defaultZeroLeafValue: string,
  treeLevel: number
) => {
  defaultZeroLeafValue = BigNumber.from(defaultZeroLeafValue)
    .mod(SNARK_FIELD_SIZE)
    .toString();
  const zeroValueArr: string[] = [defaultZeroLeafValue];
  let zeroValue = defaultZeroLeafValue;
  for (let i = 0; i < treeLevel; i++) {
    zeroValue = calcPoseidonHash([zeroValue, zeroValue]);
    zeroValueArr.push(zeroValue);
    console.log(`LEVEL${i}_NODE_ZERO_VALUE = "${zeroValueArr[i]}"`);
  }
  return zeroValueArr;
};

export const calcInitRoot = (
  defaultZeroLeafValue: string,
  treeLevel: number
) => {
  let zeroValue = defaultZeroLeafValue;
  for (let i = 0; i < treeLevel; i++) {
    zeroValue = calcPoseidonHash([zeroValue, zeroValue]);
  }
  // console.log(`INIT_ROOT_VALUE = "${zeroValue}"`);
  return zeroValue;
};
