const poseidon = require("poseidon-encryption");

export const calcPoseidonHash = (input: string[]) => {
  const poseidonHash = poseidon.poseidon(input).toString();
  console.log("poseidonHash", poseidonHash);
  return poseidonHash;
};

calcPoseidonHash([
  "4084072719053160716279855116223998323521844768566156994431933053085788015396",
  "14903451459034059445075662264596478042530623572948325878432591180345387938943",
]);
