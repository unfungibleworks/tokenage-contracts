// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import 'hardhat/console.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol';

import './ITokenageMysteryBoxRevealable.sol';
import '../../../DefaultPausableUpgradeable.sol';

abstract contract TokenageMysteryBoxRevealableERC721Upgradeable is
    DefaultPausableUpgradeable,
    ERC721Upgradeable,
    ITokenageMysteryBoxRevealable
{
    bytes32 public constant MINTER_ROLE = keccak256('MINTER_ROLE');

    // solhint-disable-next-line func-name-mixedcase, private-vars-leading-underscore
    function __TokenageMysteryBoxRevealableERC721_init(
        address adminAddress,
        address minterAddress,
        string memory name,
        string memory symbol
    ) public onlyInitializing {
        require(minterAddress != address(0), 'minterAddress null');
        __ERC721_init(name, symbol);
        __DefaultPausable_init(adminAddress);
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

    function _setType(uint256 tokenId, uint16 ticketType) internal virtual {}

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IERC165, ERC721Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return interfaceId == type(ITokenageMysteryBoxRevealable).interfaceId || super.supportsInterface(interfaceId);
    }
}
