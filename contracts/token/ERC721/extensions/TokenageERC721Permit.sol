// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import 'hardhat/console.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol';
import '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';
import '@openzeppelin/contracts/utils/Counters.sol';

import './ITokenageERC721Permit.sol';

/**
 * @dev Implementation of the ERC721 Permit extension allowing approvals to be made via signatures.
 *
 * Adds the {permit} method, which can be used to change an account's ERC721 allowance by
 * presenting a message signed by the account. By not relying on `{IERC721-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * This implementation was inspired by openzeppelin's ERC20Permit.
 * This implementation will likely be deprecated after the official implementation is released by openzeppelin.
 * Make sure to implement your smart contracts accordingly to be able to upgrade it properly.
 */
abstract contract TokenageERC721Permit is ERC721, ITokenageERC721Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    // solhint-disable-next-line var-name-mixedcase
    bytes32 private immutable _PERMIT_TYPEHASH;

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `'1'`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC721 token name.
     */
    // solhint-disable-next-line func-name-mixedcase
    constructor(string memory name) EIP712(name, '1') {
        _PERMIT_TYPEHASH = keccak256(
            'TokenagePermitERC721(address from,address to,uint256 tokenId,uint256 nonce,uint256 deadline)'
        );
    }

    /**
     * @dev See {IERC721Permit-permit}.
     */
    function permit(
        address owner,
        address spender,
        uint256 tokenId,
        uint256 deadline,
        bytes memory signature
    ) public virtual override {
        require(block.timestamp <= deadline, 'TokenageERC721Permit: expired deadline');

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, tokenId, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, signature);
        require(signer == owner, 'TokenageERC721Permit: invalid signature');

        _approve(spender, tokenId);
    }

    /**
     * @dev See {IERC721Permit-nonces}.
     */
    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }

    /**
     * @dev See {IERC721Permit-DOMAIN_SEPARATOR}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev 'Consume a nonce': return the current value and increment.
     *
     * _Available since v4.1._
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
}
