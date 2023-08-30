import { SignatureInputArgs } from "../type";
import { calcPoseidonHash } from "./calcPoseidonHash";

export const calcSignature = (args: SignatureInputArgs) => {
  const inputArgs = [args.privateKey, args.commitment, args.merklePath];
  const signature = calcPoseidonHash(inputArgs);
  // console.log("signature", signature);
  return signature;
};
