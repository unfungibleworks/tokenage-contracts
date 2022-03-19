// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

/**
 * @dev Abstract contract of the ERC20 with some extensions to support signature base operations.
 *
 * Extend this abstract contract if you are creating a specific tokenURI for each ERC20 token and want to
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
abstract contract TokenageERC20FullUpgradeable is
    PausableUpgradeable,
    AccessControlUpgradeable,
    ERC20BurnableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using ECDSAUpgradeable for bytes32;

    event TokenMinted(address owner, uint256 amount);

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    bytes32 private constant _MINT_HASH =
        keccak256("Mint(address >Owner,uint256 >Amount,uint256 >Nonce)");

    bytes32 private constant _VERSION_HASH = keccak256(bytes("1"));
    bytes32 private constant _EIP712DOMAIN_HASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

    mapping(address => CountersUpgradeable.Counter) private _nonces;

    /**
     * @dev When extending this smart contract, call this {__TokenageERC20FullUpgradeable_init} method on {initialize}
     * method.
     *
     * Example:
     * function initialize() public initializer {
     *    __TokenageERC20FullUpgradeable_init('YourTokenName', 'YOURSYMBOL');
     * }
     */
    // solhint-disable-next-line func-name-mixedcase
    function __TokenageERC20FullUpgradeable_init(
        string memory name,
        string memory symbol
    ) internal onlyInitializing {
        __ERC20_init(name, symbol);
        __Pausable_init();
        __AccessControl_init();
        __ERC20Burnable_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    /**
     * @dev Disallow contract operations from users.
     * Use this to prevent users from minting, transferring etc.
     */
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /**
     * @dev Allow contract operations from users.
     * See {pause} method.
     */
    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
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
     * - `amount` claimed amount to mint (wei)
     */
    function mint(address owner, uint256 amount)
        external
        whenNotPaused
        nonReentrant
    {
        require(hasRole(MINTER_ROLE, msg.sender), "User is not a minter");
        _mint(owner, amount);
        emit TokenMinted(owner, amount);
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
     * - `amount` claimed amount to mint (wei)
     */

    function mintTokenWithSignature(
        address owner,
        uint256 amount,
        bytes memory signature
    ) public whenNotPaused nonReentrant {
        bytes32 eip712DomainHash = keccak256(
            abi.encode(
                _EIP712DOMAIN_HASH,
                _contractNameHash(),
                _VERSION_HASH,
                block.chainid,
                address(this)
            )
        );
        bytes32 hashStruct = keccak256(
            abi.encode(_MINT_HASH, owner, amount, _useNonce(owner))
        );
        bytes32 hash = keccak256(
            abi.encodePacked("\x19\x01", eip712DomainHash, hashStruct)
        );
        address signer = hash.recover(signature);

        require(hasRole(MINTER_ROLE, signer), "Bad sign");
        require(signer != address(0), "Signer null");

        _mint(owner, amount);

        emit TokenMinted(owner, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    function nonces(address owner) public view returns (uint256) {
        return _nonces[owner].current();
    }

    function _useNonce(address owner) internal returns (uint256) {
        CountersUpgradeable.Counter storage nonceCounter = _nonces[owner];
        uint256 nonce = nonceCounter.current();
        nonceCounter.increment();
        return nonce;
    }

    function _contractNameHash() internal pure virtual returns (bytes32);

    // The following functions are overrides required by Solidity.

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
