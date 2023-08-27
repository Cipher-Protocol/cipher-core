const poseidon = require("poseidon-encryption");

export const calcNullifier = (
  commitment: string,
  merklePath: string,
  signature: string
) => {
  const input = [commitment, merklePath, signature];
  const nullifier = poseidon.poseidon(input).toString();
  console.log("nullifier", nullifier);
  return nullifier;
};
calcNullifier(
  "15997751684126047741117699664175740081703119285231532664403667222083395872102",
  "1",
  "2026908663526582489170064820140623779510553043227824974465556360567616821760"
);
