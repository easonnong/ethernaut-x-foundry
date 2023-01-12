// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

abstract contract ERC721TrustlessFilter is Ownable, ERC721 {
    using BitMaps for BitMaps.BitMap;

    struct VoteInfo {
        BitMaps.BitMap allowVotes;
        BitMaps.BitMap blockVotes;
        uint256 allowTotal;
        uint256 blockTotal;
    }

    mapping(address => VoteInfo) internal _voteInfo;

    uint256 public minBlockVotesNeeded;

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256
    ) internal virtual override(ERC721) {
        if (
            from != address(0) && to != address(0) && !mayTransfer(msg.sender)
        ) {
            revert("ERC721TrustlessFilter: illegal operator");
        }
        super._beforeTokenTransfer(from, to, tokenId, 1);
    }

    function mayTransfer(address operator) public view returns (bool) {
        if (minBlockVotesNeeded == 0) return true;

        VoteInfo storage operatorVote = _voteInfo[operator];
        uint256 allowTotal = operatorVote.allowTotal;
        uint256 blockTotal = operatorVote.blockTotal;

        return blockTotal < minBlockVotesNeeded || blockTotal <= allowTotal;
    }
}
