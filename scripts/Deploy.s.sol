// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {CipherVerifier} from "../contracts/CipherVerifier.sol";
import {Cipher} from "../contracts/Cipher.sol";

contract DeploymentScript is Script {
    using stdJson for string;

    uint256 private privkey;
    uint256 poseidonSalt;
    uint256 verifierSalt;
    uint256 cipherSalt;

    modifier broadcast() {
        vm.startBroadcast(privkey);
        _;
        vm.stopBroadcast();
    }

    function setUp() external {
        privkey = vm.envUint("GOERLI_DEPLOYER_PRIVATE_KEY");
        poseidonSalt = vm.envUint("POSEIDON_SALT");
        verifierSalt = vm.envUint("VERIFIER_SALT");
        cipherSalt = vm.envUint("CIPHER_SALT");
    }

    function run() external {
        address poseidon = _deployPoseidon();
        CipherVerifier verifier = _deployVerifier();
        Cipher cipher = _deployCipher(address(verifier), poseidon);
    }

    function _deployPoseidon() broadcast private returns (address addr) {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/tests/utils/PoseidonT3.json");
        string memory json = vm.readFile(path);
        bytes memory creationCode = json.readBytes(".creationCode");
        bytes32 salt = bytes32(poseidonSalt);

        assembly ("memory-safe") {
            addr := create2(0, add(0x20, creationCode), mload(creationCode), salt)
        }
    }

    function _deployVerifier() broadcast private returns (CipherVerifier verifier) {
        bytes32 salt = bytes32(verifierSalt);
        verifier = new CipherVerifier{salt: salt}();
    }

    function _deployCipher(address verifier, address poseidon) broadcast private returns (Cipher cipher) {
        bytes32 salt = bytes32(cipherSalt);
        cipher = new Cipher{salt: salt}(verifier, poseidon);
    }
}
