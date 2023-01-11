// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ERC721VestedWithdrawals is Ownable, ReentrancyGuard, ERC721 {
    uint256 public constant VEST_CADENCE = 90 days;
    uint256 public constant VEST_PERIODS = 4;

    uint256 public mintCompletionTime;
    uint256 public totalMintFunds;
    uint256 public amountWithdrawn;

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) {}

    /// @dev this hook should be called when the last NFT has been
    /// minted or a sale is deened as completed.
    function _onMintCompetion() private {
        mintCompletionTime = block.timestamp;
        totalMintFunds = address(this).balance;
    }

    function vestedWithdraw() external onlyOwner ReentrancyGuard {
        require(
            mintCompletionTime != 0 && totalMintFunds != 0,
            "Sale not over"
        );

        uint256 withdrawableAmount;
        uint256 vestedPeriods = (block.timestamp - mintCompletionTime) /
            VEST_CADENCE;
        if (vestedPeriods >= VEST_PERIODS) {
            withdrawableAmount = address(this).balance;
        } else {
            uint256 vestedAmount = (totalMintFunds * vestedPeriods) /
                VEST_PERIODS;
            withdrawableAmount = vestedAmount - amountWithdrawn;
        }

        if (withdrawableAmount > 0) {
            amountWithdrawn = vestedAmount;
            (bool success, ) = msg.sender.call{value: withdrawableAmount}("");
            require(success, "Withdrawal failed.");
        }
    }
}
