// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../Base_Test.sol";

contract TestTransact is BaseTest {
    function testTransact() external {
        (
            Proof memory proof,
            /* PublicSignals memory publicSignals */ ,
            PublicInfo memory publicInfo
        ) = _prepareTestData();
        main.cipherTransact{value: 1 ether}(proof, publicInfo);
    }

    function testTransact_ExpiredDeadline() external {
        // future timestamp
        vm.warp((2524579200 + 10000));
        (
            Proof memory proof,
            /* PublicSignals memory publicSignals */ ,
            PublicInfo memory publicInfo
        ) = _prepareTestData();

        vm.expectRevert(
            abi.encodeWithSelector(Errors.ExpiredDeadline.selector, publicInfo.deadline)
        );
        main.cipherTransact{value: 1 ether}(proof, publicInfo);
    }

    function testTransact_InvalidPublicInfo() external {
        (
            Proof memory proof,
            PublicSignals memory publicSignals,
            PublicInfo memory publicInfo
        ) = _prepareTestData();

        publicInfo.maxAllowableFeeRate = 1000;
        uint256 errorHash = Helper.calcPublicInfoHash(publicInfo);

        vm.expectRevert(
            abi.encodeWithSelector(Errors.InvalidPublicInfo.selector, publicSignals.publicInfoHash, errorHash)
        );
        main.cipherTransact{value: 1 ether}(proof, publicInfo);
    }

    function testTransact_TokenTreeNotExists() external {
        IERC20 unInitedToken = IERC20(address(0x123));

        (
            Proof memory proof,
            PublicSignals memory publicSignals,
            PublicInfo memory publicInfo
        ) = _prepareTestData();

        publicInfo.token = unInitedToken;
        publicSignals.publicInfoHash = Helper.calcPublicInfoHash(publicInfo);
        vm.expectRevert(
            abi.encodeWithSelector(Errors.TokenTreeNotExists.selector, publicInfo.token)
        );
        main.cipherTransact{value: 1 ether}(proof, publicInfo);
    }

    function testTransact_InvalidRoot() external {
        (
            Proof memory proof,
            PublicSignals memory publicSignals,
            PublicInfo memory publicInfo
        ) = _prepareTestData();

        publicSignals.root = uint256(0x12345678);
        vm.expectRevert(
            abi.encodeWithSelector(Errors.InvalidRoot.selector, publicSignals.root)
        );
        main.cipherTransact{value: 1 ether}(proof, publicInfo);
    }

    function testTransact_InvalidMsgValue() external {
        (
            Proof memory proof,
            /* PublicSignals memory publicSignals */,
            PublicInfo memory publicInfo
        ) = _prepareTestData();

        vm.expectRevert(
            abi.encodeWithSelector(Errors.InvalidMsgValue.selector, 0.5 ether)
        );
        main.cipherTransact{value: 0.5 ether}(proof, publicInfo);
    }

    function testTransact_InvalidProof() external {
        (
            Proof memory proof,
            /* PublicSignals memory publicSignals */,
            PublicInfo memory publicInfo
        ) = _prepareTestData();

        proof.a[0] = uint256(0x87654321);
        vm.expectRevert(
            abi.encodeWithSelector(Errors.InvalidProof.selector, proof)
        );
        main.cipherTransact{value: 1 ether}(proof, publicInfo);
    }

    function _prepareTestData() private pure returns (
        Proof memory proof,
        PublicSignals memory publicSignals,
        PublicInfo memory publicInfo
    ) {
        // testdata n0m1
        uint256[] memory commitments = new uint256[](1);
        commitments[0] = 0x2ccf8ad229038231f04b9b61a854f69235c02cdb989201b7bad03b743743839b;

        publicSignals = PublicSignals({
            root: 0x1835c52bee935f545b17f880f8811ba62f1d157671fb8e5ffa2de24b7e2d2145,
            publicInAmt: 1000000000000000000,
            publicOutAmt: 0,
            publicInfoHash: 0x23038d61a43bdcd91800dd93823c1fb3f81648bf2d70e8102959647a47e3e0e9,
            inputNullifiers: new uint256[](0),
            outputCommitments: commitments
        });
        proof = Proof({
            a: [
                0x0ff604c5a7f6d7184211624ca97ec02afc1246cc5605246de8101b8782580c4a,
                0x2120b1eb467bbcc625ad9b61d7ca0c992c34eb2f097ea56b14312900d7c1b76b
            ],
            b: [
                [
                    0x248c8b41bae0757fc79f583d7d9a2159a6c47f8e180795230268e99e11623b3b,
                    0x1e172157f8fe703d6632d017189a1878fb2267aaf7202749ad1181c225b62bd6
                ],
                [
                    0x1e17f5a3bf0291d9e44c543517198e850c4176e1f9f57b367644ad38c8aeb81b,
                    0x2f1016391a0c614a6cb55feab723a44a7af7c25693c6f48b38453e28efd3de36
                ]
            ],
            c: [
                0x05f9eb7759338b4abae71586bd0db79927def258b6bb3b00537c36629b89c96f,
                0x10604e273cad794a13deb7575d4fd350f47055bcc3e1ce0c602116f933f59672
            ],
            publicSignals: publicSignals
        });
        publicInfo = PublicInfo({
            maxAllowableFeeRate: 0,
            recipient: payable(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF),
            token: IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE),
            deadline: 2524579200
        });
    }
}
