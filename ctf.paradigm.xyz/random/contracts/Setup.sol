// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import "./Random.sol";

// ********************
// I'm thinking of a number between 4 and 4
// ********************
contract Setup {
    Random public random;

    constructor() {
        random = new Random();
        // **********
        random.solve(4);
        // **********
    }

    function isSolved() public view returns (bool) {
        return random.solved();
    }
}
