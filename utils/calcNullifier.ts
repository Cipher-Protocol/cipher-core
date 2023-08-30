import { NullifierInputArgs } from "../type";
import { calcPoseidonHash } from "./calcPoseidonHash";

export const calcNullifier = (args: NullifierInputArgs) => {
  const inputArgs = [args.commitment, args.merklePath, args.signature];
  const nullifier = calcPoseidonHash(inputArgs);
  // console.log("nullifier", nullifier);
  return nullifier;
};
