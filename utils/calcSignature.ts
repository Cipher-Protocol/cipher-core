const poseidon = require("poseidon-encryption");

export const calcSignature = (
  privateKey: string,
  commitment: string,
  merklePath: string
) => {
  const input = [privateKey, commitment, merklePath];
  const signature = poseidon.poseidon(input).toString();
  // console.log("signature", signature);
  return signature;
};
// calcSignature(
//   "0x00",
//   "15997751684126047741117699664175740081703119285231532664403667222083395872102",
//   "1"
// );
