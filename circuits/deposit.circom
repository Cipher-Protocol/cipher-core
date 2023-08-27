pragma circom 2.1.6;

include "./utxo.circom";

/// deposit input 0, output 2 circuit
component main {public [root, publicAmount, extDataHash, inputNullifier, outputCommitment]} = Utxo(5, 0, 2, 6366925358513780640586497246669654262631579502674952490807991049566930320);

