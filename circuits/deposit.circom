pragma circom 2.1.6;

include "./utxo.circom";

/// utxo circuit for input n, output m 
component main {public [root, publicInAmt, publicOutAmt, extDataHash, inputNullifier, outputCommitment]} = Utxo(5, 0, 2, 6366925358513780640586497246669654262631579502674952490807991049566930320);

