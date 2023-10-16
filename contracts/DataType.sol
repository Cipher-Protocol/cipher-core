// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        Storage
***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */

/// @notice The increamental merkle tree data struct
/// @dev The tree is a binary tree
struct TreeData {
    /// @notice The depth of the tree
    uint256 depth;
    /// @notice The root of the tree
    uint256 root;
    /// @notice The number of leaves in the tree
    uint256 numberOfLeaves;
    /// @notice The index of the latest history root in history roots array
    uint8 historyRootsIdx;
    /// @notice The history roots array (The 32 valid roots before the latest root)
    ///         to avoid others updating the root when user calculating the proof in client side
    uint256[32] historyRoots;
    /// @notice The last subtrees of the tree
    ///         i.e. depth => [left, right]
    mapping(uint256 => uint256[2]) lastSubtrees;
    /// @notice The nullifiers mapping to avoid double spend
    mapping(uint256 => bool) nullifiers;
}

/** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        Functions input data struct
***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */

/// @notice The SNARK proof data struct
/// @param a The proof data (a)
/// @param b The proof data (b)
/// @param c The proof data (c)
/// @param publicSignals The public signals struct
struct Proof {
    uint256[2] a;
    uint256[2][2] b;
    uint256[2] c;
    PublicSignals publicSignals;
}

/// @notice The public signals data struct
/// @dev Dynamic arrays inputNullifiers and outputCommitments
///      to support multiple UTXO type transactions
/// @param root The tree root
/// @param publicInAmt The public input amount
/// @param publicOutAmt The public output amount
/// @param publicInfoHash The hash of the public info struct
/// @param inputNullifiers The input nullifiers array
/// @param outputCommitments The output commitments array
struct PublicSignals {
    uint256 root;
    uint256 publicInAmt;
    uint256 publicOutAmt;
    uint256 publicInfoHash;
    uint256[] inputNullifiers;
    uint256[] outputCommitments;
}

/// @notice The public info data struct
/// @dev Intent-based relayer mechanism, the withdrawer can set the max allowable fee rate
///      and the relayer can charge <= max allowable fee rate or the transaction will be reverted
/// @param maxAllowableFeeRate The max allowable fee rate to relayer
/// @param recipient The recipient address
/// @param token The token of the token tree
/// @param deadline The deadline of the transaction
struct PublicInfo {
    uint16 maxAllowableFeeRate;
    address payable recipient;
    IERC20 token;
    uint32 deadline;
}

/// @notice The relayer info data struct
/// @dev The relayer can use any wallet address to send the transaction,
///      but need to assign the original registered address in `registeredAddr`
///      to get relayer reputation.
/// @param registeredAddr The registered address of the relayer
/// @param feeReceiver The fee receiver address of the relayer
/// @param feeRate The fee rate charged by the relayer
///                transfered amount * feeRate / FEE_BASE = fee amount
///                i.e. 1000 * 300 / 10000 = 30 (3% fee)
struct RelayerInfo {
    address payable registeredAddr;
    address payable feeReceiver;
    uint16 feeRate;
}
