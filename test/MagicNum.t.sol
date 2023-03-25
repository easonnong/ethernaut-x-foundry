// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/MagicNum/MagicNum.sol";
import "../src/MagicNum/MagicNumFactory.sol";
import "../src/Ethernaut.sol";

contract MagicNumTest is Test {
    Ethernaut private _ethernaut;
    MagicNumFactory private _magicNumFactory;
    MagicNum private _magicNum;

    address private _hacker = address(0xA);

    modifier testWrapper() {
        vm.deal(_hacker, 1 ether);
        _ethernaut.registerLevel(_magicNumFactory);
        vm.startPrank(_hacker);
        address instance = _ethernaut.createLevelInstance(_magicNumFactory);
        _magicNum = MagicNum(instance);
        _;
        bool success = _ethernaut.submitLevelInstance(
            payable(address(_magicNum))
        );
        assertTrue(success);
        vm.stopPrank();
    }

    function setUp() public {
        _ethernaut = new Ethernaut();
        _magicNumFactory = new MagicNumFactory();
    }

    function testMagicNumHack() public testWrapper {}
}
