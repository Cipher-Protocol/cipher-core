// build circuit from the circuit template file ../circuits/utxo.circom
import fs from "fs";
import path from "path";
import UTXO_CONFIG_JASON from ".././utxo_config.json";
import { DEFAULT_ZERO_LEAF_VALUE, TREE_HEIGHT } from "../config";

export const buildCircuit = () => {
  UTXO_CONFIG_JASON.map((item) => {
    const circuitContent = `
include "../../../circuits/utxo.circom";

/// utxo circuit for input n, output m 
component main {public [root, publicInAmt, publicOutAmt, extDataHash, inputNullifier, outputCommitment]} = Utxo(${TREE_HEIGHT}, ${item.nIns}, ${item.mOuts}, ${DEFAULT_ZERO_LEAF_VALUE});
`;

    const fileName = path.join(
      __dirname,
      `../build/circuits/n${item.nIns}m${item.mOuts}/n${item.nIns}m${item.mOuts}.circom`
    );
    fs.mkdirSync(path.dirname(fileName), { recursive: true });

    fs.writeFile(fileName, circuitContent, (err) => {
      if (err) {
        console.error("Error writing the file:", err);
      } else {
        console.log(`File '${fileName}' has been created.`);
      }
    });
  });
};

buildCircuit();
