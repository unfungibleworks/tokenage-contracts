// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import 'hardhat/console.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol';

import '../../../DefaultPausable.sol';

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
abstract contract TokenageERC20Token is DefaultPausable, ERC20Burnable {
    event TokenMinted(address owner, uint256 amount);

    uint8 private immutable _decimals;

    constructor(
        address adminAddress,
        string memory name,
        string memory symbol,
        uint8 decimals_
    ) ERC20(name, symbol) DefaultPausable(adminAddress) {
        _decimals = decimals_;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }
}
