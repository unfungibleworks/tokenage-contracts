// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import './TokenageERC20TokenUpgradeable.sol';

/**
 * @dev Abstract contract of the ERC20 with some extensions to support signature base operations.
 *
 * Extend this abstract contract if you are creating a specific tokenURI for each ERC20 token and want to
 * use signature base minting and transferring in order to save gas.
 * Before minting there's the possibility of an address with {MINTER_ROLE} role to sign a transaction in order for
 * other user without {MINTER_ROLE} to mint his/her token, thus not obligating the address with minter role to mint
 * every token and spending lots of gas in a single account.
 *
 * For transferring purpose a user with ownership of a token could sign a transfer permission for others so he/she
 * doesn't need to spend gas. This is specially good in case of selling in a marketplace like Tokenage where a
 * marketplace might require to escrow a token and transfer it afterwards to a buyer without a manual intervention
 * of the user in these operations.
 */
abstract contract TokenageERC20GovernanceTokenUpgradeable is TokenageERC20TokenUpgradeable {
    /**
     * @dev When extending this smart contract, call this {__TokenageERC20GovernanceTokenUpgradeable_init} method on {initialize}
     * method.
     *
     * Example:
     * function initialize() public initializer {
     *    __TokenageERC20GovernanceTokenUpgradeable_init('YourTokenName', 'YOURSYMBOL', 100000000 * 10**decimals());
     * }
     */
    // solhint-disable-next-line func-name-mixedcase
    function __TokenageERC20GovernanceToken_init(
        address adminAddress,
        string memory name,
        string memory symbol,
        uint256 totalSupply,
        uint8 decimals
    ) internal onlyInitializing {
        __TokenageERC20Token_init(adminAddress, name, symbol, decimals);
        _mint(msg.sender, totalSupply * 10**decimals);
        emit TokenMinted(msg.sender, totalSupply);
    }
}
