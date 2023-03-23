// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Example {
    address public addr=0x660d2AB91a50Db333aFd7ff14784C75d57FF527f;
    uint160 public u160=uint160(addr);
    uint16 public u16=uint16(u160);
}
The output of u160 is the same as the address stored in the variable addr,
which is 0x660d2AB91a50Db333aFd7ff14784C75d57FF527f.
The output of u16 is 527f.
