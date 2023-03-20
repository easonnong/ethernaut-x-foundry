// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../src/Ethernaut.sol";
import "forge-std/Test.sol";

contract BaseTest is Test {
    Ethernaut ethernaut;
    address eoa = address(99);
    address instance;

    function setUp(Level _level) internal {
        ethernaut = new Ethernaut();
        ethernaut.registerLevel(_level);
        vm.deal(eoa, 100 ether);
    }

    modifier testWrapper(Level _level, uint256 value) {
        vm.startPrank(eoa);
        instance = ethernaut.createLevelInstance{value: value}(_level);
        _;
        assertTrue(ethernaut.submitLevelInstance(payable(instance)));
        vm.stopPrank();
    }
}
