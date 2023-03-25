// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/MagicNum/MagicNum.sol";
import "../src/MagicNum/MagicNumFactory.sol";
import "../src/Ethernaut.sol";

contract MagicNumTest is Test {
    Ethernaut private _ethernaut;
    MagicNumFactory private _magicNumFactory;
    MagicNum private _magicNum;

    address private _hacker = address(0xA);

    modifier testWrapper() {
        vm.deal(_hacker, 1 ether);
        _ethernaut.registerLevel(_magicNumFactory);
        vm.startPrank(_hacker);
        address instance = _ethernaut.createLevelInstance(_magicNumFactory);
        _magicNum = MagicNum(instance);
        _;
        bool success = _ethernaut.submitLevelInstance(
            payable(address(_magicNum))
        );
        assertTrue(success);
        vm.stopPrank();
    }

    function setUp() public {
        _ethernaut = new Ethernaut();
        _magicNumFactory = new MagicNumFactory();
    }

    function testMagicNumHack() public testWrapper {
        /**
         * Runtime code:
         *   mstore(0x00,0x2a) -> push1 0x2a push1 0x00 mstore (60 2a 60 00 52)
         *   return(0x00,0x20) -> push1 0x20 push1 0x00 return (60 20 60 00 f3)
         *
         * ------> 602a60005260206000f3
         *
         * Creation code:
         *   mstore(0x00,0x602a60005260206000f3)
         *       -> push10 0x602a60005260206000f3 push1 0x00 mstore
         *          -> (69 602a60005260206000f3 60 00 52)
         *   return(0x16,0x0a)
         *       -> push1 0x0a push1 0x16 f3
         *          -> (60 0a 60 16 f3)
         *
         * ------> 69602a60005260206000f3600052600a6016f3
         *
         * Now can deploy the contract with:
         *   web3.eth.sendTransaction({ data: '0x69602a60005260206000f3600052600a6016f3' })
         */

        bytes memory bytecode = hex"69602a60005260206000f3600052600a6016f3";
        address solverContract;
        assembly {
            // 0x20 is the length of bytecode
            solverContract := create(0, add(bytecode, 0x20), 0x13)
        }

        _magicNum.setSolver(solverContract);

        /**************************
        // Retrieve the solver from the instance.
        Solver solver = Solver(_magicNum.solver());
        Solver2 solver2 = Solver2(_magicNum.solver());

        // Query the solver for the magic number.
        bytes32 magic = solver.whatIsTheMeaningOfLife();
        bytes32 magic2 = solver2.whatIsTheMeaningOfLife2();
        console2.logBytes32(magic);
        console2.logBytes32(magic2);

        // Require the solver to have at most 10 opcodes.
        uint256 size;
        assembly {
            size := extcodesize(solver)
        }

        console2.log("size =", size);

        */
    }
}

interface Solver2 {
    function whatIsTheMeaningOfLife2() external view returns (bytes32);
}
