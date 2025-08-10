// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

/// @notice Minimal cToken interface.
interface ICToken {
    enum Error {
        NO_ERROR
    }

    function mint(uint mintAmount) external returns (uint);

    function redeem(uint redeemTokens) external returns (uint);

    function transfer(address dst, uint256 amount) external returns (bool);

    function balanceOf(address owner) external view returns (uint256);
}
