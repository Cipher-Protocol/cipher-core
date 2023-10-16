// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {console} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, stdJson} from "forge-std/Test.sol";
import {Proof, PublicInfo, PublicSignals} from "../../contracts/DataType.sol";

abstract contract TestDataFile is Test {
    using stdJson for string;

    function loadTestdata(string memory file, string memory txid) internal view returns (Proof memory proof, PublicInfo memory info, PublicSignals memory signal) {
        // load json
        string memory root = vm.projectRoot();
        // example file name: `deposit/0_n0m1.json`
        string memory path = string.concat(root, "/tests/testData/", file);
        string memory json = vm.readFile(path);

        // PublicSignals
        { // avoid stack too deep
            string memory txId = string.concat(".[", txid, "]");
            uint256 signalRoot = json.readUint(string.concat(txId, ".utxoData.publicSignals.root"));
            uint256 signalPublicInAmt = json.readUint(string.concat(txId, ".utxoData.publicSignals.publicInAmt"));
            uint256 signalPublicOutAmt = json.readUint(string.concat(txId, ".utxoData.publicSignals.publicOutAmt"));
            uint256 signalPublicInfoHash = json.readUint(string.concat(txId, ".utxoData.publicSignals.publicInfoHash"));
            uint256[] memory signalInputNullifiers = json.readUintArray(string.concat(txId, ".utxoData.publicSignals.inputNullifiers"));
            uint256[] memory signalOutputCommitments = json.readUintArray(string.concat(txId, ".utxoData.publicSignals.outputCommitments"));
            signal = PublicSignals({
                root: signalRoot,
                publicInAmt: signalPublicInAmt,
                publicOutAmt: signalPublicOutAmt,
                publicInfoHash: signalPublicInfoHash,
                inputNullifiers: signalInputNullifiers,
                outputCommitments: signalOutputCommitments
            });
        }

        // Proof
        { // avoid stack too deep
            string memory txId = string.concat(".[", txid, "]");
            uint256[] memory proof_a = json.readUintArray(string.concat(txId, ".utxoData.a"));
            uint256[][] memory proof_b = abi.decode(json.parseRaw(string.concat(txId, ".utxoData.b")), (uint256[][]));
            uint256[] memory proof_c = json.readUintArray(string.concat(txId, ".utxoData.c"));
            proof = Proof({
                a: [proof_a[0], proof_a[1]],
                b: [[proof_b[0][0], proof_b[0][1]], [proof_b[1][0], proof_b[1][1]]],
                c: [proof_c[0], proof_c[1]],
                publicSignals: signal
            });
        }

        // PublicInfo
        { // avoid stack too deep
            string memory txId = string.concat(".[", txid, "]");
            uint256 infoMaxAllowableFeeRate = json.readUint(string.concat(txId, ".publicInfo.maxAllowableFeeRate"));
            address infoRecipient = json.readAddress(string.concat(txId, ".publicInfo.recipient"));
            address infoToken = json.readAddress(string.concat(txId, ".publicInfo.token"));
            uint256 infoDeadline = json.readUint(string.concat(txId, ".publicInfo.deadline"));
            info = PublicInfo({
                maxAllowableFeeRate: uint16(infoMaxAllowableFeeRate & uint256(type(uint16).max)),
                recipient: payable(infoRecipient),
                token: IERC20(infoToken),
                deadline: uint32(infoDeadline)
            });
        }
    }
}
