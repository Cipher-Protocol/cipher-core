import { Note } from "../type";
import { calcPoseidonHash } from "./calcPoseidonHash";

export const calcCommitment = (note: Note) => {
  const inputArgs = [note.amount, note.pubkey, note.salt];
  const commitment = calcPoseidonHash(inputArgs);
  // console.log("poseidonHash", poseidonHash);
  return commitment;
};
