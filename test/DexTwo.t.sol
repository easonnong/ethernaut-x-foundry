// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/DexTwo/DexTwo.sol";
import "../src/DexTwo/DexTwoFactory.sol";
import "../src/Ethernaut.sol";

contract DexTwoTest is Test {
    Ethernaut private _ethernaut;
    DexTwoFactory private _dexTwoFactory;
    DexTwo private _dexTwo;

    address private _hacker = address(0xA);

    modifier testWrapper() {
        vm.deal(_hacker, 1 ether);
        _ethernaut.registerLevel(_dexTwoFactory);
        vm.startPrank(_hacker);
        address instance = _ethernaut.createLevelInstance(_dexTwoFactory);
        _dexTwo = DexTwo(instance);
        _;
        bool success = _ethernaut.submitLevelInstance(
            payable(address(_dexTwo))
        );
        assertTrue(success);
        vm.stopPrank();
    }

    function setUp() public {
        _ethernaut = new Ethernaut();
        _dexTwoFactory = new DexTwoFactory();
    }

    function testDexTwoHack() public testWrapper {
        _dexTwo.approve(address(_dexTwo), type(uint256).max);
        // After Dex one:
        // (hacker token1)  (dex token1)  (dex token2)  (hacker token2)
        //      110              0             90             20
    }
}
