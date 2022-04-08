// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

interface ITokenageMysteryBoxBurnableERC721 is IERC721Upgradeable {
    function burn(uint256 tokenId) external;

    function getType(uint256 tokenId) external view returns (uint16);
}
