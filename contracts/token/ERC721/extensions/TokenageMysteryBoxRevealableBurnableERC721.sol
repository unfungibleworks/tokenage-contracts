// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import 'hardhat/console.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

import './ITokenageMysteryBoxRevealable.sol';
import './TokenageMysteryBoxBurnableERC721.sol';

abstract contract TokenageMysteryBoxRevealableBurnableERC721 is
    TokenageMysteryBoxBurnableERC721,
    ITokenageMysteryBoxRevealable
{
    bytes32 public constant MINTER_ROLE = keccak256('MINTER_ROLE');

    constructor(
        address adminAddress,
        address minterAddress,
        address burnerAddress,
        string memory name,
        string memory symbol
    ) TokenageMysteryBoxBurnableERC721(adminAddress, burnerAddress, name, symbol) {
        require(minterAddress != address(0), 'minterAddress null');
        _grantRole(MINTER_ROLE, minterAddress);
    }

    function mintTo(
        address to,
        uint256 tokenId,
        uint16 boxType,
        uint16 ticketType
    ) external override whenNotPaused onlyRole(MINTER_ROLE) {
        require(to != address(0x0), 'Address null');
        require(boxType > 0, 'Invalid ticket');
        require(ticketType > 0, 'Invalid ticket');
        _validateTokenMint(to, tokenId, boxType, ticketType);
        _mintToken(to, tokenId, boxType, ticketType);
        emit MysteryBoxRevealableTokenMinted(to, tokenId, ticketType);
    }

    function _validateTokenMint(
        address to,
        uint256 tokenId,
        uint16 boxType,
        uint16 ticketType
    ) internal virtual {}

    function _mintToken(
        address to,
        uint256 tokenId,
        uint16 boxType,
        uint16 ticketType
    ) internal virtual {
        _safeMint(to, tokenId);
        _setType(tokenId, ticketType);
    }

    function _setType(uint256 tokenId, uint16 ticketType) internal override {
        super._setType(tokenId, ticketType);
    }
}
