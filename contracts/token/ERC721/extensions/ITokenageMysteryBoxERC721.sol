// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

interface ITokenageMysteryBoxERC721 is IERC721Upgradeable {
    function mintTo(
        address to,
        uint8 boxType,
        uint32 quantity
    ) external;

    function burn(uint256 tokenId) external;

    function getBoxType(uint256 tokenId) external view returns (uint8);
}
