// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @notice Minimal cToken interface.
interface ICToken {
    enum Error {
        NO_ERROR
    }

    function mint(uint mintAmount) external returns (uint);

    function redeemUnderlying(uint redeemAmount) external returns (uint);

    function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint);

    function transfer(address dst, uint256 amount) external returns (bool);

    function transferFrom(address src, address dst, uint256 amount) external returns (bool);

    function accrueInterest() external returns (uint);

    function borrowBalanceCurrent(address account) external returns (uint);

    function balanceOf(address owner) external view returns (uint256);

    function exchangeRateStored() external view returns (uint);

    function borrowBalanceStored(address account) external view returns (uint);

    function totalBorrows() external view returns (uint);
}
