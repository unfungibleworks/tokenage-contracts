// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

interface ITokenageMysteryBoxTicketERC721 is IERC721Upgradeable {
    function mintTo(
        address to,
        uint256 tokenId,
        uint8 boxType,
        uint8 ticketType
    ) external;

    function burn(uint256 tokenId) external;

    function getTicketType(uint256 tokenId) external view returns (uint8);
}
