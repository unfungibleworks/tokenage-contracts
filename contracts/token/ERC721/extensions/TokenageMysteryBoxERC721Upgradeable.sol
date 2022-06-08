// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import '@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol';

import '../../../DefaultPausableUpgradeable.sol';
import './ITokenageMysteryBox.sol';
import './TokenageMysteryBoxBurnableERC721Upgradeable.sol';

abstract contract TokenageMysteryBoxERC721Upgradeable is TokenageMysteryBoxBurnableERC721Upgradeable, ITokenageMysteryBox {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    bytes32 public constant MINTER_ROLE = keccak256('MINTER_ROLE');

    CountersUpgradeable.Counter private _tokenIdCounter;

    // solhint-disable-next-line func-name-mixedcase, private-vars-leading-underscore
    function __TokenageMysteryBoxERC721_init(
        address adminAddress,
        address minterAddress,
        address burnerAddress,
        string memory name,
        string memory symbol
    ) public onlyInitializing {
        require(minterAddress != address(0), 'minterAddress null');
        __TokenageMysteryBoxBurnableERC721_init(adminAddress, burnerAddress, name, symbol);
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

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, TokenageMysteryBoxBurnableERC721Upgradeable) returns (bool) {
        return interfaceId == type(ITokenageMysteryBox).interfaceId || super.supportsInterface(interfaceId);
    }
}
