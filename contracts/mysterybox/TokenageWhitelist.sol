// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "@tokenage/tokenage-contracts/contracts/mysterybox/ITokenageWhitelist.sol";

abstract contract TokenageWhitelist is
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable,
    ITokenageWhitelist
{
    event AccountsAdded(uint256 totalAddedAccounts);
    event AccountsRemoved(uint256 totalRemovedAccounts);

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPDATER_ROLE = keccak256("UPDATER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    mapping(address => bool) private _whitelistMapping;

    // solhint-disable-next-line func-name-mixedcase, private-vars-leading-underscore
    function __TokenageWhitelist_init() public onlyInitializing {
        __AccessControl_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        __Pausable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _grantRole(UPDATER_ROLE, msg.sender);
    }

    /**
     * @dev Disallow contract operations from users.
     * Use this to prevent users from adding and removing accounts from whitelist mapping.
     */
    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /**
     * @dev Allow contract operations from users.
     * See {pause} method.
     */
    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
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
        require(addresses.length > 0, "Addresses empty");
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
        require(addresses.length > 0, "Addresses empty");
        for (uint256 i = 0; i < addresses.length; i++) {
            address addr = addresses[i];
            delete _whitelistMapping[addr];
        }
        emit AccountsRemoved(addresses.length);
    }

    function isOnWhitelist(address addressToCheck)
        external
        view
        override
        returns (bool)
    {
        return _whitelistMapping[addressToCheck] == true;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}
}
