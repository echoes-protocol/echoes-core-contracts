// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IComptroller {
    function repayBorrowAllowed(
        address cToken,
        address payer,
        address borrower,
        uint repayAmount
    ) external returns (uint);
}
