// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

abstract contract ERC721TrustlessFilter is Ownable, ERC721 {
    using BitMaps for BitMaps.BitMap;
}
