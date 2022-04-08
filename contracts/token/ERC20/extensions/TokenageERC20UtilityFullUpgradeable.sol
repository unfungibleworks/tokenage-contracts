// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./TokenageERC20FullUpgradeable.sol";

/**
 * @dev Abstract contract of the ERC20 with some extensions to support signature base operations.
 *
 * Extend this abstract contract if you are creating a ERC20 token and want to
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
abstract contract TokenageERC20UtilityFullUpgradeable is
    TokenageERC20FullUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using ECDSAUpgradeable for bytes32;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    bytes32 private constant _MINT_HASH =
        keccak256("Mint(address >Owner,uint256 >Amount,uint256 >Nonce)");

    bytes32 private constant _VERSION_HASH = keccak256(bytes("1"));
    bytes32 private constant _EIP712DOMAIN_HASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
    bytes32 private _eip712DomainHash;

    mapping(address => CountersUpgradeable.Counter) private _nonces;

    /**
     * @dev When extending this smart contract, call this {__TokenageERC20UtilityFullUpgradeable_init} method on {initialize}
     * method.
     *
     * Example:
     * function initialize() public initializer {
     *    __TokenageERC20UtilityFullUpgradeable_init('YourTokenName', 'YOURSYMBOL');
     * }
     */
    // solhint-disable-next-line func-name-mixedcase
    function __TokenageERC20UtilityFullUpgradeable_init(
        string memory name,
        string memory symbol
    ) internal onlyInitializing {
        __TokenageERC20FullUpgradeable_init(name, symbol);

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        _eip712DomainHash = keccak256(
            abi.encode(
                _EIP712DOMAIN_HASH,
                _contractNameHash(),
                _VERSION_HASH,
                chainId,
                address(this)
            )
        );

        _grantRole(MINTER_ROLE, msg.sender);
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
        require(hasRole(MINTER_ROLE, msg.sender), "Not minter");
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
        bytes32 hashStruct = keccak256(
            abi.encode(_MINT_HASH, owner, amount, _useNonce(owner))
        );
        bytes32 hash = keccak256(
            abi.encodePacked("\x19\x01", _eip712DomainHash, hashStruct)
        );
        address signer = hash.recover(signature);

        require(hasRole(MINTER_ROLE, signer), "Bad sign");
        require(signer != address(0), "Signer null");

        _mint(owner, amount);

        emit TokenMinted(owner, amount);
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[48] private __gap;
}
