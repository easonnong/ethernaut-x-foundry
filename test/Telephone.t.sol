// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/Telephone/Telephone.sol";
import "../src/Telephone/TelephoneFactory.sol";
import "../src/Ethernaut.sol";

contract TelephoneTest is Test {
    Ethernaut private _ethernaut;
    TelephoneFactory private _telephoneFactory;
    Telephone private _telephone;

    address private _hacker = address(0xA);

    modifier testWrapper() {
        vm.deal(_hacker, 1 ether);
        _ethernaut.registerLevel(_telephoneFactory);
        vm.prank(_hacker);
        address instance = _ethernaut.createLevelInstance(_telephoneFactory);
        _telephone = Telephone(instance);
        vm.startPrank(address(this));
        _;
        vm.stopPrank();
        vm.prank(_hacker);
        bool success = _ethernaut.submitLevelInstance(
            payable(address(_telephone))
        );
        assertTrue(success);
    }

    function setUp() public {
        _ethernaut = new Ethernaut();
        _telephoneFactory = new TelephoneFactory();
    }

    function testTelephoneHack() public testWrapper {
        // console2.log("_telephone owner before:", _telephone.owner());
        _telephone.changeOwner(_hacker);
        // console2.log("_telephone owner after:", _telephone.owner());
    }
}
