// SPDX-Ln2m2_icense-Identifier: GPL-3.0
/*
    Copyright 2021 0KIMS association.

    This file is generated with [snarkJS](https://github.com/iden3/snarkjs).

    snarkJS is a free software: you can redistribute it and/or modify it
    under the terms of the GNU General Publn2m2_ic Ln2m2_icense as published by
    the Free Software Foundation, either version 3 of the Ln2m2_icense, or
    (at your option) any later version.

    snarkJS is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    or FITNESS FOR A PARTn2m2_ICULAR PURPOSE. See the GNU General Publn2m2_ic
    Ln2m2_icense for more details.

    You should have received a copy of the GNU General Publn2m2_ic Ln2m2_icense
    along with snarkJS. If not, see <https://www.gnu.org/ln2m2_icenses/>.
*/

pragma solidity ^0.8.20;

contract Verifier {
    // Scalar field size
    uint256 constant r = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    // Base field size
    uint256 constant q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // Verifn2m2_ication Key data
    uint256 constant alphax = 20491192805390485299153009773594534940189261866228447918068658471970481763042;
    uint256 constant alphay = 9383485363053290200918347156157836566562967994039712273449902621266178545958;
    uint256 constant betax1 = 4252822878758300859123897981450591353533073413197771768651442665752259397132;
    uint256 constant betax2 = 6375614351688725206403948262868962793625744043794305715222011528459656738731;
    uint256 constant betay1 = 21847035105528745403288232691147584728191162732299865338377159692350059136679;
    uint256 constant betay2 = 10505242626370262277552901082094356697409835680220590971873171140371331206856;
    uint256 constant gammax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gammax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gammay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gammay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;

    uint256 constant n0m2_deltax1 = 10312084935420306118493951408858135770274806872429074098548866166156743814581;
    uint256 constant n0m2_deltax2 = 13712723239010203701073745954940948386110791086078359549541893826498664544901;
    uint256 constant n0m2_deltay1 = 18388983229099628454228556564207474433217208151076518274188985575473797505233;
    uint256 constant n0m2_deltay2 = 19355013798258394963176144212241382476679150152107705273330778173502923179357;

    uint256 constant n2m2_deltax1 = 1495666440070517632381693090329370631115709484943077879808625281458781511075;
    uint256 constant n2m2_deltax2 = 12679634382016783664938391766795521942052664417254982102300236648391297078545;
    uint256 constant n2m2_deltay1 = 21479175775577985188498508817273978351420792669790810389082167220835320176887;
    uint256 constant n2m2_deltay2 = 9973860130894473852803746487832076926166077611749036529225170534131101091596;

    uint256 constant n0m2_IC0x = 12466742574078549877971214918762367823685653873335401956018626454827704904470;
    uint256 constant n0m2_IC0y = 17823578495850245131767821457196957083202700699047556500616832847195059753286;

    uint256 constant n0m2_IC1x = 17767228369678678986510405959864285201928031409453932224948812792379001846905;
    uint256 constant n0m2_IC1y = 8090761568885606965243811914014104188755488630199964716869264512913906190973;

    uint256 constant n0m2_IC2x = 3165583894325698097427502395669371611525656664228336622971317959146402956928;
    uint256 constant n0m2_IC2y = 663365605866000540750259515150549223714940395488902327058695645881094606714;

    uint256 constant n0m2_IC3x = 11349331400659645479811817736843379067322993923725124133617632146745886573680;
    uint256 constant n0m2_IC3y = 11613012883480685857728964396834770812066719536164148256977663732920791766613;

    uint256 constant n0m2_IC4x = 11559698361789839923060285138172330018922552768390988102320463603381675491193;
    uint256 constant n0m2_IC4y = 17081476467412544264459610128945361143489933190253013744169797857128695602050;

    uint256 constant n0m2_IC5x = 6310614939086716015975450599156067405048591457680328139012805854658969927037;
    uint256 constant n0m2_IC5y = 2961284851324860765426919320066960784222538827471782708358999972881227622944;

    uint256 constant n0m2_IC6x = 9283706357002262625888012612684848008705580412009480278167713941499952900428;
    uint256 constant n0m2_IC6y = 6528111701193417745338208236495868964705294577232765555725531899195709384913;

    uint256 constant n2m2_IC0x = 17036468245523965909351940867072824385092054012801352194456004998483115160541;
    uint256 constant n2m2_IC0y = 12297451063608512401144758578222137987886517831140538174448425735433107124742;

    uint256 constant n2m2_IC1x = 10441609520085591362147077747123014813222622508842259338091416334591447570742;
    uint256 constant n2m2_IC1y = 14669755489529943652056009474145287325809716833481916133554793051209222216106;

    uint256 constant n2m2_IC2x = 2240208811703855020160488233872160638169841824148807700465464026762349125472;
    uint256 constant n2m2_IC2y = 16960941393908728964056134039258177156689285717942853637202757055940240139242;

    uint256 constant n2m2_IC3x = 4550721895546750396623350610548508565444632501153095137512164377218331739422;
    uint256 constant n2m2_IC3y = 13885155059274685450518481238519159405978616555945888277721399326874228820434;

    uint256 constant n2m2_IC4x = 3873982522259504047372176704125240673211746259816401817144478884361387886536;
    uint256 constant n2m2_IC4y = 10475818452067576650340192131342170063676553696390916027018240856491926372947;

    uint256 constant n2m2_IC5x = 9882980573537339866753782154010155911791871636953565191663512808842817329042;
    uint256 constant n2m2_IC5y = 1582063106117123781333483248186163439832547370700298338665449865743326356409;

    uint256 constant n2m2_IC6x = 1340577637077404923860369170311987550149323656715102807324459126308604202323;
    uint256 constant n2m2_IC6y = 14138924432976951149254422934488766412274059733981386642147882683396721266868;

    uint256 constant n2m2_IC7x = 19287920081660638725586401360355717971508040882073838052461149134135778832554;
    uint256 constant n2m2_IC7y = 19805674603245309661849943385623631471765992674836806651108992014148379144699;

    uint256 constant n2m2_IC8x = 15794524538053917867414092662992496467219748743030636312431594248498172876502;
    uint256 constant n2m2_IC8y = 9021818981430521232422179200768722584087325228208652881938553047543417014187;

    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        uint[] calldata _pubSignals, // remove fix size
        bytes1 _type
    ) public view returns (bool) {
        assembly {
            function checkField(v) {
                if iszero(lt(v, q)) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            // G1 function to multiply a G1 value(x,y) to value in an address
            function g1_mulAccC(pR, x, y, s) {
                let success
                let mIn := mload(0x40)
                mstore(mIn, x)
                mstore(add(mIn, 32), y)
                mstore(add(mIn, 64), s)

                success := staticcall(sub(gas(), 2000), 7, mIn, 96, mIn, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }

                mstore(add(mIn, 64), mload(pR))
                mstore(add(mIn, 96), mload(add(pR, 32)))

                success := staticcall(sub(gas(), 2000), 6, mIn, 128, pR, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            function getDelta(utxoType) -> deltax1, deltax2, deltay1, deltay2 {
                switch utxoType
                case 0x02 {
                    deltax1 := n0m2_deltax1
                    deltax2 := n0m2_deltax2
                    deltay1 := n0m2_deltay1
                    deltay2 := n0m2_deltay2
                }
                case 0x22 {
                    deltax1 := n2m2_deltax1
                    deltax2 := n2m2_deltax2
                    deltay1 := n2m2_deltay1
                    deltay2 := n2m2_deltay2
                }
                default {
                    // this is not allowed
                }
            }

            function getIC0(utxoType) -> IC0x, IC0y {
                switch utxoType
                case 0x02 {
                    IC0x := n0m2_IC0x
                    IC0y := n0m2_IC0y
                }
                case 0x22 {
                    IC0x := n2m2_IC0x
                    IC0y := n2m2_IC0y
                }
                default {
                    // this is not allowed
                }
            }

            function g1_mulAccC_dispatcher(_pVk, utxoType, pubSignals) {
                switch utxoType
                case 0x02 {
                    g1_mulAccC(_pVk, n0m2_IC1x, n0m2_IC1y, calldataload(add(pubSignals, 0)))
                    g1_mulAccC(_pVk, n0m2_IC2x, n0m2_IC2y, calldataload(add(pubSignals, 32)))
                    g1_mulAccC(_pVk, n0m2_IC3x, n0m2_IC3y, calldataload(add(pubSignals, 64)))
                    g1_mulAccC(_pVk, n0m2_IC4x, n0m2_IC4y, calldataload(add(pubSignals, 96)))
                    g1_mulAccC(_pVk, n0m2_IC5x, n0m2_IC5y, calldataload(add(pubSignals, 128)))
                    g1_mulAccC(_pVk, n0m2_IC6x, n0m2_IC6y, calldataload(add(pubSignals, 160)))
                }
                case 0x22 {
                    g1_mulAccC(_pVk, n2m2_IC1x, n2m2_IC1y, calldataload(add(pubSignals, 0)))
                    g1_mulAccC(_pVk, n2m2_IC2x, n2m2_IC2y, calldataload(add(pubSignals, 32)))
                    g1_mulAccC(_pVk, n2m2_IC3x, n2m2_IC3y, calldataload(add(pubSignals, 64)))
                    g1_mulAccC(_pVk, n2m2_IC4x, n2m2_IC4y, calldataload(add(pubSignals, 96)))
                    g1_mulAccC(_pVk, n2m2_IC5x, n2m2_IC5y, calldataload(add(pubSignals, 128)))
                    g1_mulAccC(_pVk, n2m2_IC6x, n2m2_IC6y, calldataload(add(pubSignals, 160)))
                    g1_mulAccC(_pVk, n2m2_IC7x, n2m2_IC7y, calldataload(add(pubSignals, 192)))
                    g1_mulAccC(_pVk, n2m2_IC8x, n2m2_IC8y, calldataload(add(pubSignals, 224)))
                }
                default {
                    // this is not allowed
                }
            }

            function checkPairing(pA, pB, pC, pubSignals, pMem, utxoType) -> isOk {
                let _pPairing := add(pMem, pPairing)
                let _pVk := add(pMem, pVk)

                let IC0x, IC0y := getIC0(utxoType)
                mstore(_pVk, IC0x)
                mstore(add(_pVk, 32), IC0y)

                // Compute the linear combination vk_x

                // g1_mulAccC(_pVk, IC1x, IC1y, calldataload(add(pubSignals, 0)))

                // g1_mulAccC(_pVk, IC2x, IC2y, calldataload(add(pubSignals, 32)))

                // g1_mulAccC(_pVk, IC3x, IC3y, calldataload(add(pubSignals, 64)))

                // g1_mulAccC(_pVk, IC4x, IC4y, calldataload(add(pubSignals, 96)))

                // g1_mulAccC(_pVk, IC5x, IC5y, calldataload(add(pubSignals, 128)))

                // g1_mulAccC(_pVk, IC6x, IC6y, calldataload(add(pubSignals, 160)))

                // g1_mulAccC(_pVk, IC7x, IC7y, calldataload(add(pubSignals, 192)))

                // g1_mulAccC(_pVk, IC8x, IC8y, calldataload(add(pubSignals, 224)))

                g1_mulAccC_dispatcher(_pVk, utxoType, pubSignals)

                // -A
                mstore(_pPairing, calldataload(pA))
                mstore(add(_pPairing, 32), mod(sub(q, calldataload(add(pA, 32))), q))

                // B
                mstore(add(_pPairing, 64), calldataload(pB))
                mstore(add(_pPairing, 96), calldataload(add(pB, 32)))
                mstore(add(_pPairing, 128), calldataload(add(pB, 64)))
                mstore(add(_pPairing, 160), calldataload(add(pB, 96)))

                // alpha1
                mstore(add(_pPairing, 192), alphax)
                mstore(add(_pPairing, 224), alphay)

                // beta2
                mstore(add(_pPairing, 256), betax1)
                mstore(add(_pPairing, 288), betax2)
                mstore(add(_pPairing, 320), betay1)
                mstore(add(_pPairing, 352), betay2)

                // vk_x
                mstore(add(_pPairing, 384), mload(add(pMem, pVk)))
                mstore(add(_pPairing, 416), mload(add(pMem, add(pVk, 32))))

                // gamma2
                mstore(add(_pPairing, 448), gammax1)
                mstore(add(_pPairing, 480), gammax2)
                mstore(add(_pPairing, 512), gammay1)
                mstore(add(_pPairing, 544), gammay2)

                // C
                mstore(add(_pPairing, 576), calldataload(pC))
                mstore(add(_pPairing, 608), calldataload(add(pC, 32)))

                // delta2
                // get delta by utxoType
                let deltax1, deltax2, deltay1, deltay2 := getDelta(utxoType)
                mstore(add(_pPairing, 640), deltax1)
                mstore(add(_pPairing, 672), deltax2)
                mstore(add(_pPairing, 704), deltay1)
                mstore(add(_pPairing, 736), deltay2)

                let success := staticcall(sub(gas(), 2000), 8, _pPairing, 768, _pPairing, 0x20)

                isOk := and(success, mload(_pPairing))
            }

            let pMem := mload(0x40)
            mstore(0x40, add(pMem, pLastMem))

            // Validate that all evaluations ∈ F

            // checkField(calldataload(add(_pubSignals, 0)))

            // checkField(calldataload(add(_pubSignals, 32)))

            // checkField(calldataload(add(_pubSignals, 64)))

            // checkField(calldataload(add(_pubSignals, 96)))

            // checkField(calldataload(add(_pubSignals, 128)))

            // checkField(calldataload(add(_pubSignals, 160)))

            // checkField(calldataload(add(_pubSignals, 192)))

            // checkField(calldataload(add(_pubSignals, 224)))

            // checkField(calldataload(add(_pubSignals, 256)))

            let end := mul(_pubSignals.length, 0x20)
            for {
                let i := 0
            } lt(i, end) {
                i := add(i, 0x20)
            } {
                checkField(calldataload(add(_pubSignals.offset, i)))
            }

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals.offset, pMem, _type)

            mstore(0, isValid)
            return(0, 0x20)
        }
    }
}
