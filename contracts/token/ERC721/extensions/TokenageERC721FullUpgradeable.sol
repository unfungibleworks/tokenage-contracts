// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import 'hardhat/console.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol';

import './TokenageERC721PermitUpgradeable.sol';
import '../../../DefaultPausableUpgradeable.sol';

/**
 * @dev Abstract contract of the ERC721 with some extensions to support signature base operations.
 *
 * Extend this abstract contract if you are creating a specific tokenURI for each ERC721 token and want to
 * use signature base minting and transferring in order to save gas.
 * Before minting there's the possibility of an address with {MINTER_ROLE} role to sign a transaction in order for
 * other user without {MINTER_ROLE} to mint his/her token, thus not obligating the address with minter role to mint
 * every token and spending lots of gas in a single account.
 *
 * For transferring purpose a user with ownership of a token could sign a transfer permission for others so he/she
 * doesn't need to spend gas. This is specially good in case of selling in a marketplace like Tokenage where a
 * marketplace might require to escrow a token and transfer it afterwards to a buyer without a manual intervention
 * of the user in these operations.
 */
abstract contract TokenageERC721FullUpgradeable is
    DefaultPausableUpgradeable,
    ERC721EnumerableUpgradeable,
    ERC721URIStorageUpgradeable,
    ERC721BurnableUpgradeable,
    TokenageERC721PermitUpgradeable
{
    using ECDSAUpgradeable for bytes32;

    event TokenMinted(address owner, string tokenURI, uint256 tokenId);

    bytes32 public constant MINTER_ROLE = keccak256('MINTER_ROLE');

    bytes32 private constant _EIP712DOMAIN_HASH =
        keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)');
    bytes32 private constant _VERSION_HASH = keccak256(bytes('1'));
    bytes32 private constant _MINT_HASH = keccak256('Mint(address >Owner,uint256 >Token ID,bytes32 >Token URI Hash)');
    bytes32 private _eip712DomainHash;

    /**
     * @dev When extending this smart contract, call this {__TokenageERC721FullUpgradeable_init} method on {initialize}
     * method.
     *
     * Example:
     * function initialize() public initializer {
     *    __TokenageERC721FullUpgradeable_init('YourTokenName', 'YOURSYMBOL');
     * }
     */
    // solhint-disable-next-line func-name-mixedcase
    function __TokenageERC721Full_init(
        address adminAddress,
        address minterAddress,
        string memory name,
        string memory symbol
    ) internal onlyInitializing {
        require(minterAddress != address(0), 'minterAddress null');
        __DefaultPausable_init(adminAddress);
        __ERC721_init(name, symbol);
        __ERC721Enumerable_init();
        __ERC721URIStorage_init();
        __ERC721Burnable_init();
        __TokenageERC721Permit_init(name);

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        _eip712DomainHash = keccak256(
            abi.encode(_EIP712DOMAIN_HASH, _contractNameHash(), _VERSION_HASH, chainId, address(this))
        );

        _grantRole(MINTER_ROLE, minterAddress);
    }

    /**
     * @dev Mint token to a user.
     *
     * IMPORTANT: only a user with {MINTER_ROLE} role is allowed to execute this operation.
     *
     * Emits an {TokenMinted} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `tokenId` must be a unique number that was not minted yet.
     * - `metadataURI` must be a valid URI with a proper JSON to represent this token.
     */
    function mintToken(
        address owner,
        uint256 tokenId,
        string memory metadataURI
    ) external virtual whenNotPaused nonReentrant {
        require(hasRole(MINTER_ROLE, msg.sender), 'Not minter');
        _safeMint(owner, tokenId);
        _setTokenURI(tokenId, metadataURI);
        emit TokenMinted(owner, metadataURI, tokenId);
    }

    /**
     * @dev Mint token to a user with a signature of a user with {MINTER_ROLE} role.
     *
     * IMPORTANT: only a user with {MINTER_ROLE} is allowed to execute this operation.
     *
     * Emits an {TokenMinted} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `tokenId` must be a unique number that was not minted yet.
     * - `metadataURI` must be a valid URI with a proper JSON to represent this token.
     * - `deadline` must be a timestamp in the future.
     */
    function mintTokenWithSignature(
        address owner,
        uint256 tokenId,
        string memory metadataURI,
        bytes memory signature
    ) external virtual whenNotPaused nonReentrant {
        bytes32 tokenHash = keccak256(abi.encode(metadataURI));
        bytes32 hashStruct = keccak256(abi.encode(_MINT_HASH, owner, tokenId, tokenHash));
        bytes32 hash = keccak256(abi.encodePacked('\x19\x01', _eip712DomainHash, hashStruct));
        address signer = hash.recover(signature);
        require(hasRole(MINTER_ROLE, signer), 'Bad sign');
        require(signer != address(0), 'Signer null');

        _safeMint(owner, tokenId);
        _setTokenURI(tokenId, metadataURI);
        emit TokenMinted(owner, metadataURI, tokenId);
    }

    function _contractNameHash() internal pure virtual returns (bytes32);

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721Upgradeable, ERC721EnumerableUpgradeable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721Upgradeable, ERC721URIStorageUpgradeable) whenNotPaused {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
