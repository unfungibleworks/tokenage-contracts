// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * Additional helper functions to deal with signatures.
 */
library TokenageECDSA {
    function convertSignatureToRSV(bytes memory signature)
        internal
        pure
        returns (
            bytes32,
            bytes32,
            uint8
        )
    {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return (r, s, v);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return convertSignatureToRSV(r, vs);
        } else {
            revert("Invalid signature");
        }
    }

    function convertSignatureToRSV(bytes32 r, bytes32 vs)
        internal
        pure
        returns (
            bytes32,
            bytes32,
            uint8
        )
    {
        bytes32 s = vs &
            bytes32(
                0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            );
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return (r, s, v);
    }
}
