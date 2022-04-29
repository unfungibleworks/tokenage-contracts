// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import './ITokenageWhitelist.sol';
import '../DefaultPausable.sol';

abstract contract TokenageWhitelist is ITokenageWhitelist, DefaultPausable {
    bytes32 public constant UPDATER_ROLE = keccak256('UPDATER_ROLE');

    mapping(address => bool) private _whitelistMapping;

    constructor(address adminAddress, address updaterAddress) DefaultPausable(adminAddress) {
        require(updaterAddress != address(0), 'updaterAddress null');
        _grantRole(UPDATER_ROLE, updaterAddress);
    }

    /**
     * @dev Add list of addresses to whitelist.
     */
    function addToWhitelist(address[] calldata addresses)
        external
        virtual
        override
        whenNotPaused
        nonReentrant
        onlyRole(UPDATER_ROLE)
    {
        require(addresses.length > 0, 'Addresses empty');
        for (uint256 i = 0; i < addresses.length; i++) {
            address addr = addresses[i];
            _whitelistMapping[addr] = true;
        }
        emit AccountsAdded(addresses.length);
    }

    /**
     * @dev Remove list of addresses to whitelist.
     */
    function removeFromWhitelist(address[] calldata addresses)
        external
        virtual
        override
        whenNotPaused
        nonReentrant
        onlyRole(UPDATER_ROLE)
    {
        require(addresses.length > 0, 'Addresses empty');
        for (uint256 i = 0; i < addresses.length; i++) {
            address addr = addresses[i];
            delete _whitelistMapping[addr];
        }
        emit AccountsRemoved(addresses.length);
    }

    function isOnWhitelist(address addressToCheck) external view override returns (bool) {
        return _whitelistMapping[addressToCheck] == true;
    }
}
