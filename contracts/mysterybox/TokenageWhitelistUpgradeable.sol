// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import './ITokenageWhitelist.sol';
import '../DefaultPausableUpgradeable.sol';

abstract contract TokenageWhitelistUpgradeable is ITokenageWhitelist, DefaultPausableUpgradeable {
    bytes32 public constant UPDATER_ROLE = keccak256('UPDATER_ROLE');

    mapping(address => bool) private _whitelistMapping;

    // solhint-disable-next-line func-name-mixedcase, private-vars-leading-underscore
    function __TokenageWhitelist_init(address adminAddress, address updaterAddress) public onlyInitializing {
        require(updaterAddress != address(0), 'updaterAddress null');
        __DefaultPausable_init(adminAddress);
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

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IERC165, AccessControlUpgradeable)
        returns (bool)
    {
        return interfaceId == type(ITokenageWhitelist).interfaceId || super.supportsInterface(interfaceId);
    }
}
