// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface ITokenageMysteryBoxRevealable {
    event MysteryBoxRevealableTokenMinted(address indexed owner, uint256 tokenId, uint16 ticketType);

    function mintTo(
        address to,
        uint256 tokenId,
        uint16 boxType,
        uint16 ticketType
    ) external;
}
