// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import 'hardhat/console.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

import './ITokenageMysteryBoxBurnable.sol';
import '../../../DefaultPausable.sol';

abstract contract TokenageMysteryBoxBurnableERC721 is DefaultPausable, ERC721, ITokenageMysteryBoxBurnable {
    bytes32 public constant BURNER_ROLE = keccak256('BURNER_ROLE');

    mapping(uint256 => uint16) public tokenIdToType;
    mapping(uint256 => uint256) public tokenIdToUserSeed;

    constructor(
        address adminAddress,
        address burnerAddress,
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) DefaultPausable(adminAddress) {
        _grantRole(BURNER_ROLE, burnerAddress);
    }

    function getType(uint256 tokenId) external view override returns (uint16) {
        require(_exists(tokenId), 'Token not exists');
        return tokenIdToType[tokenId];
    }

    function burn(uint256 tokenId) external override onlyRole(BURNER_ROLE) {
        _burn(tokenId);
    }

    function setUserSeed(uint256[] calldata tokenIds, uint256 userSeed) external whenNotPaused nonReentrant {
        require(tokenIds.length > 0, 'TokenIds empty');
        require(userSeed > 0, 'userSeed zero');
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(ownerOf(tokenId) == msg.sender, 'Not owner');
            require(tokenIdToUserSeed[tokenId] == 0, 'Seed already set');
        }
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            tokenIdToUserSeed[tokenId] = userSeed;
            emit MysteryBoxUserSeedSet(msg.sender, tokenId, userSeed);
        }
    }

    function getUserSeed(uint256 tokenId) external view override returns (uint256) {
        return tokenIdToUserSeed[tokenId];
    }

    function isOwnerOfTokensAndUserSeedSet(address owner, uint256[] calldata tokenIds) external view returns (bool) {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            if (ownerOf(tokenId) != owner) {
                return false;
            }
            if (tokenIdToUserSeed[tokenId] == 0) {
                return false;
            }
        }
        return true;
    }

    function _setType(uint256 tokenId, uint16 ticketType) internal virtual {
        require(tokenIdToType[tokenId] == 0, 'Type already set');
        tokenIdToType[tokenId] = ticketType;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override whenNotPaused {
        // validate only on transfer, burning is still allowed for BURNER_ROLE only
        if (to != address(0)) {
            require(tokenIdToUserSeed[tokenId] == 0, 'Transfer forbidden');
        }
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
