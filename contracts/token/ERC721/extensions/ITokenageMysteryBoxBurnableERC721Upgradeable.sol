// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import '@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol';

interface ITokenageMysteryBoxBurnableERC721Upgradeable is IERC721Upgradeable {
    event MysteryBoxUserSeedSet(address indexed owner, uint256 tokenId, uint256 userSeed);

    function burn(uint256 tokenId) external;

    function getType(uint256 tokenId) external view returns (uint16);

    function getUserSeed(uint256 tokenId) external view returns (uint256);
}
