// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @notice Minimal wrapped token interface. 
interface IWrappedToken {
    function deposit() external payable;

    function withdraw(uint value) external;

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);
}