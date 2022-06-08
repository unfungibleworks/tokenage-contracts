// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import '@openzeppelin/contracts/utils/introspection/ERC165.sol';

interface ITokenageWhitelist is IERC165 {
    event AccountsAdded(uint256 totalAddedAccounts);
    event AccountsRemoved(uint256 totalRemovedAccounts);

    function addToWhitelist(address[] calldata addresses) external;

    function removeFromWhitelist(address[] calldata addresses) external;

    function isOnWhitelist(address addressToCheck) external view returns (bool);
}
