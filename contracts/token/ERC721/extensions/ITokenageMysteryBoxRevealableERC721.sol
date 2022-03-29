// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./ITokenageMysteryBoxBurnableERC721.sol";

interface ITokenageMysteryBoxRevealableERC721 is
    ITokenageMysteryBoxBurnableERC721
{
    function mintTo(
        address to,
        uint256 tokenId,
        uint16 boxType,
        uint16 ticketType
    ) external;
}
