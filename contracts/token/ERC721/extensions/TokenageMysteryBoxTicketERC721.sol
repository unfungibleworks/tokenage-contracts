// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

import "./ITokenageMysteryBoxTicketERC721.sol";

abstract contract TokenageMysteryBoxTicketERC721 is
    ITokenageMysteryBoxTicketERC721,
    ERC721Upgradeable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    event MysteryBoxTicketMinted(address owner, uint256 tokenId);

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    mapping(uint256 => uint8) public tokenIdToTicketType;

    function __MysteryBoxTicketERC721_init(
        string memory name,
        string memory symbol
    ) public onlyInitializing {
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
        uint256 tokenId,
        uint8 boxType,
        uint8 ticketType
    ) external override whenNotPaused onlyRole(MINTER_ROLE) {
        require(to != address(0x0), "Address null");
        require(boxType > 0, "Invalid ticket");
        require(ticketType > 0, "Invalid ticket");
        _validateTokenMint(to, tokenId, boxType, ticketType);
        _safeMint(to, tokenId);
        tokenIdToTicketType[tokenId] = ticketType;
        emit MysteryBoxTicketMinted(to, tokenId);
    }

    function burn(uint256 tokenId) external override onlyRole(BURNER_ROLE) {
        _burn(tokenId);
    }

    function getTicketType(uint256 tokenId)
        external
        view
        override
        returns (uint8)
    {
        require(_exists(tokenId), "Token not exists");
        return tokenIdToTicketType[tokenId];
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
        uint256 tokenId,
        uint8 boxType,
        uint8 ticketType
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
