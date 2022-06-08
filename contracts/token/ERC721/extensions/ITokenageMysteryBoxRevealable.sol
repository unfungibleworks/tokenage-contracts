// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import '@openzeppelin/contracts/utils/introspection/ERC165.sol';

interface ITokenageMysteryBoxRevealable is IERC165 {
    event MysteryBoxRevealableTokenMinted(address indexed owner, uint256 tokenId, uint16 ticketType);

    function mintTo(
        address to,
        uint256 tokenId,
        uint16 boxType,
        uint16 ticketType
    ) external;
}
