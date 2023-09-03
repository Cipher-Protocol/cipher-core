// eslint-disable-next-line @typescript-eslint/no-var-requires
const poseidon = require("poseidon-encryption");

export const calcPoseidonHash = (input: string[]) => {
  const poseidonHash = poseidon.poseidon(input).toString();
  // console.log("poseidonHash", poseidonHash);
  return poseidonHash;
};
