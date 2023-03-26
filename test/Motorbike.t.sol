// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/Motorbike/Motorbike.sol";
import "../src/Motorbike/MotorbikeFactory.sol";
import "../src/Ethernaut.sol";

contract MotorbikeTest is Test {
    Ethernaut private _ethernaut;
    MotorbikeFactory private _motorbikeFactory;
    Motorbike private _motorbike;

    address private _hacker = address(0xA);

    modifier testWrapper() {
        vm.deal(_hacker, 1 ether);
        _ethernaut.registerLevel(_motorbikeFactory);
        vm.startPrank(_hacker);
        address instance = _ethernaut.createLevelInstance(_motorbikeFactory);
        _motorbike = Motorbike(instance);
        _;
        bool success = _ethernaut.submitLevelInstance(
            payable(address(_motorbike))
        );
        assertTrue(success);
        vm.stopPrank();
    }

    function setUp() public {
        _ethernaut = new Ethernaut();
        _motorbikeFactory = new MotorbikeFactory();
    }

    function testMotorbikeHack() public testWrapper {}
}
