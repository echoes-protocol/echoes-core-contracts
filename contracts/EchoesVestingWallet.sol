// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/finance/VestingWallet.sol";

contract EchoesVestingWallet is VestingWallet {
    constructor(
        address _beneficiary,
        uint64 _startTimestamp,
        uint64 _durationSeconds
    ) VestingWallet(_beneficiary, _startTimestamp, _durationSeconds) {}
}
