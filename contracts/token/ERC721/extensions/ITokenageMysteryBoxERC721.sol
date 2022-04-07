// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./ITokenageMysteryBoxBurnableERC721.sol";

interface ITokenageMysteryBoxERC721 is ITokenageMysteryBoxBurnableERC721 {
    event MysteryBoxTokenMinted(address indexed owner, uint256 tokenId);

    function mintTo(
        address to,
        uint16 boxType,
        uint64 quantity
    ) external;
}
