// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ICipherVerifier} from "./ICipherVerifier.sol";
import {Proof, PublicInfo, RelayerInfo} from "../utils/DataType.sol";

interface ICipher {
    function initTokenTree(IERC20 token) external;

    function cipherTransact(Proof calldata proof, PublicInfo calldata publicInfo) external payable;

    function cipherTransactWithRelayer(
        Proof calldata proof,
        PublicInfo calldata publicInfo,
        RelayerInfo calldata relayerInfo
    ) external payable;

    function registerAsRelayer(string memory relayerMetadataUri) external;

    function updateRelayerMetadataUri(string memory newRelayerMetadataUri) external;

    // function getTreeDepth(IERC20 token) external view returns (uint256);

    function getTreeRoot(IERC20 token) external view returns (uint256);

    function getTreeLeafNum(IERC20 token) external view returns (uint256);

    // function getTreeZeroes(IERC20 token, uint256 level) external view returns (uint256);

    function getTreeLastSubtrees(IERC20 token, uint256 level) external view returns (uint256[2] memory);

    function getRelayerMetadataUri(address relayerAddr) external view returns (string memory);

    function getVerifier() external view returns (ICipherVerifier);

    function isNullified(IERC20 token, uint256 nullifier) external view returns (bool);

    function isValidRoot(IERC20 token, uint256 root) external view returns (bool);
}
