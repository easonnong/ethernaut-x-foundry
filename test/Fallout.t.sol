// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/Ethernaut.sol";
import "../src/Fallout/Fallout.sol";
import "../src/Fallout/FalloutFactory.sol";

contract FalloutTest is Test {
    Ethernaut private _ethernaut;
    FalloutFactory private _falloutFactory;
    Fallout private _fallout;

    address private _hacker = address(0xA);

    modifier testWrapper() {
        vm.deal(_hacker, 1 ether);
        _ethernaut.registerLevel(_falloutFactory);
        vm.startPrank(_hacker);
        address instance = _ethernaut.createLevelInstance(_falloutFactory);
        _fallout = Fallout(instance);
        _;
        bool success = _ethernaut.submitLevelInstance(
            payable(address(_fallout))
        );
        assertTrue(success);
    }

    function setUp() public {
        _ethernaut = new Ethernaut();
        _falloutFactory = new FalloutFactory();
    }

    function testFalloutHack() public testWrapper {
        // console2.log("_fallout owner before:", _fallout.owner());
        // console2.log("hacker balance before:", address(_hacker).balance);

        _fallout.Fal1out();
        // _fallout.collectAllocations();

        // console2.log("_fallout owner after:", _fallout.owner());
        // console2.log("hacker balance after:", address(_hacker).balance);
    }
}
