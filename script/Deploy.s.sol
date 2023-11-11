// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {CipherVerifier} from "../contracts/CipherVerifier.sol";
import {Cipher} from "../contracts/Cipher.sol";

abstract contract DeploymentBase is Script {
    using stdJson for string;

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        variables
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    uint256 private privkey;
    uint256 poseidonSalt;
    uint256 verifierSalt;
    uint256 cipherSalt;

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        modifiers
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    modifier broadcast() {
        vm.startBroadcast(privkey);
        _;
        vm.stopBroadcast();
    }

    modifier selectFork() {
        _selectFork();
        _;
    }

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        Script external functions
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    function setUp() external {
        privkey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        poseidonSalt = vm.envUint("POSEIDON_SALT");
        verifierSalt = vm.envUint("VERIFIER_SALT");
        cipherSalt = vm.envUint("CIPHER_SALT");
        _initFork();
    }

    function run() external {
        // address poseidon = _deployPoseidon();
        CipherVerifier verifier = _deployVerifier();
        Cipher cipher = _deployCipher(address(verifier), address(0x0f4c79bF128bd3f0Cf09F658186d3928396c59Bb));
    }

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        internal virtual functions
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    function _initFork() internal virtual;

    function _selectFork() internal virtual;

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        private functions
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    function _deployPoseidon() selectFork broadcast private returns (address addr) {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/tests/utils/PoseidonT3.json");
        string memory json = vm.readFile(path);
        bytes memory creationCode = json.readBytes(".creationCode");
        bytes32 salt = bytes32(poseidonSalt);

        assembly ("memory-safe") {
            addr := create2(0, add(0x20, creationCode), mload(creationCode), salt)
        }
    }

    function _deployVerifier() selectFork broadcast private returns (CipherVerifier verifier) {
        bytes32 salt = bytes32(verifierSalt);
        verifier = new CipherVerifier{salt: salt}();
    }

    function _deployCipher(address verifier, address poseidon) selectFork broadcast private returns (Cipher cipher) {
        bytes32 salt = bytes32(cipherSalt);
        cipher = new Cipher{salt: salt}(verifier, poseidon);
    }
}
