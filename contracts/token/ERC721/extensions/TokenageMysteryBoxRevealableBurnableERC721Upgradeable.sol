// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import 'hardhat/console.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol';

import './TokenageMysteryBoxRevealableERC721Upgradeable.sol';
import './TokenageMysteryBoxBurnableERC721Upgradeable.sol';

abstract contract TokenageMysteryBoxRevealableBurnableERC721Upgradeable is
    TokenageMysteryBoxRevealableERC721Upgradeable,
    TokenageMysteryBoxBurnableERC721Upgradeable
{
    // solhint-disable-next-line func-name-mixedcase, private-vars-leading-underscore
    function __TokenageMysteryBoxRevealableBurnableERC721_init(
        address adminAddress,
        address minterAddress,
        address burnerAddress,
        string memory name,
        string memory symbol
    ) public onlyInitializing {
        require(minterAddress != address(0), 'minterAddress null');
        __TokenageMysteryBoxRevealableERC721_init(adminAddress, minterAddress, name, symbol);
        _grantRole(BURNER_ROLE, burnerAddress);
    }

    // The following functions are overrides required by Solidity.

    function _setType(uint256 tokenId, uint16 ticketType)
        internal
        override(TokenageMysteryBoxBurnableERC721Upgradeable, TokenageMysteryBoxRevealableERC721Upgradeable)
    {
        super._setType(tokenId, ticketType);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    )
        internal
        override(TokenageMysteryBoxBurnableERC721Upgradeable, TokenageMysteryBoxRevealableERC721Upgradeable)
        whenNotPaused
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(TokenageMysteryBoxBurnableERC721Upgradeable, TokenageMysteryBoxRevealableERC721Upgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override(TokenageMysteryBoxBurnableERC721Upgradeable, ERC721Upgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}
