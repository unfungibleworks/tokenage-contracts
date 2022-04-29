// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import '@openzeppelin/contracts/security/Pausable.sol';
import '@openzeppelin/contracts/access/AccessControl.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

abstract contract DefaultPausable is Pausable, AccessControl, ReentrancyGuard {
    bytes32 public constant PAUSER_ROLE = keccak256('PAUSER_ROLE');
    bytes32 public constant UPGRADER_ROLE = keccak256('UPGRADER_ROLE');

    constructor(address adminAddress) {
        require(adminAddress != address(0), 'adminAddress null');
        _grantRole(DEFAULT_ADMIN_ROLE, adminAddress);
        _grantRole(PAUSER_ROLE, adminAddress);
        _grantRole(UPGRADER_ROLE, adminAddress);
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }
}
