// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface ITokenageWhitelist {
    function addToWhitelist(address[] calldata addresses) external;

    function removeFromWhitelist(address[] calldata addresses) external;

    function isOnWhitelist(address addressToCheck) external view returns (bool);
}
