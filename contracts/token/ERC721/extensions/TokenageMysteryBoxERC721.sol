// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/utils/Counters.sol';

import '../../../DefaultPausable.sol';
import './ITokenageMysteryBox.sol';
import './TokenageMysteryBoxBurnableERC721.sol';

abstract contract TokenageMysteryBoxERC721 is TokenageMysteryBoxBurnableERC721, ITokenageMysteryBox {
    using Counters for Counters.Counter;

    bytes32 public constant MINTER_ROLE = keccak256('MINTER_ROLE');

    Counters.Counter private _tokenIdCounter;

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
        uint16 boxType,
        uint64 quantity
    ) external override onlyRole(MINTER_ROLE) {
        require(to != address(0x0), 'Address null');
        require(boxType > 0, 'Invalid box type');
        require(quantity > 0, 'Invalid quantity');
        _validateTokenMint(to, boxType, quantity);
        for (uint256 i = 0; i < quantity; i++) {
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();
            _safeMint(to, tokenId);
            tokenIdToType[tokenId] = boxType;
            emit MysteryBoxTokenMinted(to, tokenId);
        }
    }

    function _validateTokenMint(
        address to,
        uint16 boxType,
        uint64 quantity
    ) internal virtual {}
}
