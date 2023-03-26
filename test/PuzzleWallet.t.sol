// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/PuzzleWallet/PuzzleWallet.sol";
import "../src/PuzzleWallet/PuzzleWalletFactory.sol";
import "../src/Ethernaut.sol";

contract PuzzleWalletTest is Test {
    Ethernaut private _ethernaut;
    PuzzleWalletFactory private _puzzleWalletFactory;
    PuzzleWallet private _puzzleWallet;

    address private _hacker = address(0xA);

    modifier testWrapper() {
        vm.deal(_hacker, 1 ether);
        _ethernaut.registerLevel(_puzzleWalletFactory);
        vm.startPrank(_hacker);
        address instance = _ethernaut.createLevelInstance(_puzzleWalletFactory);
        _puzzleWallet = PuzzleWallet(instance);
        _;
        bool success = _ethernaut.submitLevelInstance(
            payable(address(_puzzleWallet))
        );
        assertTrue(success);
        vm.stopPrank();
    }

    function setUp() public {
        _ethernaut = new Ethernaut();
        _puzzleWalletFactory = new PuzzleWalletFactory();
    }

    function testPuzzleWalletHack() public testWrapper {}
}
