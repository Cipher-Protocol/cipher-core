// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "../Base_Test.sol";

contract TestTreeLib is BaseTest {
    using TreeLib for TreeData;

    TreeData private _tree;

    function testInit() external {
        _tree.init(10);
        assertEq(_tree.depth, 10);
        assertEq(_tree.root, TreeLib.defaultZeroVal(10));
    }

    function testInitErrorInvalidTreeDepth() external {
        vm.expectRevert(
            abi.encodeWithSelector(Errors.InvalidTreeDepth.selector, 25)
        );
        _tree.init(25);
    }

    function testUpdateHistoryRoot(uint256 root) external {
        uint8 oldIdx = _tree.historyRootsIdx;
        uint8 newIdx = uint8(addmod(_tree.historyRootsIdx, 1, Constants.VALID_HISTORY_ROOTS_SIZE));

        _tree.updateHistoryRoot(root);
        assertEq(_tree.historyRootsIdx, newIdx);
        assertEq(_tree.historyRoots[oldIdx], root);
    }

    function testUpdateNullifiers(address token, uint256[] calldata nullifiers) external {
        uint256 nullifierLen = nullifiers.length;

        // invariant: all nullifiers are not the same
        vm.assume(nullifierLen != 0);
        for (uint256 i; i < nullifierLen;) {
            for (uint256 j = i + 1; j < nullifierLen;) {
                vm.assume(nullifiers[i] != nullifiers[j]);
                unchecked {
                    ++j;
                }
            }
            unchecked {
                ++i;
            }
        }

        vm.expectEmit();
        for (uint256 i; i < nullifierLen;) {
            uint256 nullifier = nullifiers[i];
            emit Events.NewNullifier(IERC20(token), nullifier);
            unchecked {
                ++i;
            }
        }
        _tree.updateNullifiers(IERC20(token), nullifiers, nullifierLen);
    }

    function testDefaultZeroValue() external {
        assertEq(Constants.Z_0, TreeLib.defaultZeroVal(0));
        assertEq(Constants.Z_1, TreeLib.defaultZeroVal(1));
        assertEq(Constants.Z_2, TreeLib.defaultZeroVal(2));
        assertEq(Constants.Z_3, TreeLib.defaultZeroVal(3));
        assertEq(Constants.Z_4, TreeLib.defaultZeroVal(4));
        assertEq(Constants.Z_5, TreeLib.defaultZeroVal(5));
        assertEq(Constants.Z_6, TreeLib.defaultZeroVal(6));
        assertEq(Constants.Z_7, TreeLib.defaultZeroVal(7));
        assertEq(Constants.Z_8, TreeLib.defaultZeroVal(8));
        assertEq(Constants.Z_9, TreeLib.defaultZeroVal(9));
        assertEq(Constants.Z_10, TreeLib.defaultZeroVal(10));
        assertEq(Constants.Z_11, TreeLib.defaultZeroVal(11));
        assertEq(Constants.Z_12, TreeLib.defaultZeroVal(12));
        assertEq(Constants.Z_13, TreeLib.defaultZeroVal(13));
        assertEq(Constants.Z_14, TreeLib.defaultZeroVal(14));
        assertEq(Constants.Z_15, TreeLib.defaultZeroVal(15));
        assertEq(Constants.Z_16, TreeLib.defaultZeroVal(16));
        assertEq(Constants.Z_17, TreeLib.defaultZeroVal(17));
        assertEq(Constants.Z_18, TreeLib.defaultZeroVal(18));
        assertEq(Constants.Z_19, TreeLib.defaultZeroVal(19));
        assertEq(Constants.Z_20, TreeLib.defaultZeroVal(20));
        assertEq(Constants.Z_21, TreeLib.defaultZeroVal(21));
        assertEq(Constants.Z_22, TreeLib.defaultZeroVal(22));
        assertEq(Constants.Z_23, TreeLib.defaultZeroVal(23));
        assertEq(Constants.Z_24, TreeLib.defaultZeroVal(24));
    }
}
