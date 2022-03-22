// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

import "./ITokenageMysteryBoxERC721.sol";

abstract contract TokenageMysteryBoxERC721 is
    ITokenageMysteryBoxERC721,
    ERC721Upgradeable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;

    event MysteryBoxTokenMinted(address owner, uint256 tokenId);

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    CountersUpgradeable.Counter private _tokenIdCounter;
    mapping(uint256 => uint8) public tokenIdToType;

    function __MysteryBoxERC721_init(string memory name, string memory symbol)
        public
        onlyInitializing
    {
        __ERC721_init(name, symbol);
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mintTo(
        address to,
        uint8 boxType,
        uint32 quantity
    ) external override onlyRole(MINTER_ROLE) {
        require(to != address(0x0), "Address null");
        require(boxType > 0, "Invalid box type");
        require(quantity > 0, "Invalid quantity");
        _validateTokenMint(to, boxType, quantity);
        for (uint256 i = 0; i < quantity; i++) {
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();
            _safeMint(to, tokenId);
            tokenIdToType[tokenId] = boxType;
            emit MysteryBoxTokenMinted(to, tokenId);
        }
    }

    function burn(uint256 tokenId) external override onlyRole(BURNER_ROLE) {
        _burn(tokenId);
    }

    function getBoxType(uint256 tokenId)
        external
        view
        override
        returns (uint8)
    {
        require(_exists(tokenId), "Token not exists");
        return tokenIdToType[tokenId];
    }

    function isOwnerOfTokens(address owner, uint256[] calldata tokenIds)
    external
    view
    returns (bool)
    {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (ownerOf(tokenIds[i]) != owner) {
                return false;
            }
        }
        return true;
    }

    function _validateTokenMint(
        address to,
        uint8 boxType,
        uint32 quantity
    ) internal virtual {}

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(
            ERC721Upgradeable,
            AccessControlUpgradeable,
            IERC165Upgradeable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
