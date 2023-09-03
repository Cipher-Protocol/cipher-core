pragma circom 2.1.6;

include "../utxo.circom";

/// withdraw input 2, output 2 circuit
component main {public [root, publicInAmt, publicOutAmt, extDataHash, inputNullifier, outputCommitment]} = Utxo(5, 2, 2, 6366925358513780640586497246669654262631579502674952490807991049566930320);
