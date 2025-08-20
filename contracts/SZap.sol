// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ICToken} from "./interfaces/ICToken.sol";
import {IWrappedToken} from "./interfaces/IWrappedToken.sol";

contract SZap {
    IWrappedToken public immutable wS;
    ICToken public immutable underlyingCToken;

    uint256 constant expScale = 1e18;

    event ZapIn(address user, uint256 amount);
    event ZapOut(address user, uint256 amount);

    event Mint(address minter, uint mintAmount, uint mintTokens);
    event RepayBorrow(address payer, address borrower, uint repayAmount, uint accountBorrows, uint totalBorrows);

    constructor(address _wS, address _underlyingCToken) {
        wS = IWrappedToken(_wS);
        underlyingCToken = ICToken(_underlyingCToken);
    }

    /**
     @notice This function is used to zap S token to wS cToken.
     @param _amount The amount of fromToken.
     */
    function mint(uint256 _amount) external payable returns (uint256) {
        require(msg.value > 0 && msg.value == _amount, "Invalid amount");

        _performZapIn(_amount);

        wS.approve(address(underlyingCToken), _amount);

        uint256 cTokenBalanceBefore = underlyingCToken.balanceOf(address(this));

        uint256 success = underlyingCToken.mint(_amount);

        require(success == 0, "Failed to mint cTokens");

        uint256 receivedCToken = underlyingCToken.balanceOf(address(this)) -
            cTokenBalanceBefore;

        underlyingCToken.transfer(msg.sender, receivedCToken);

        emit Mint(msg.sender, _amount, receivedCToken);

        return uint(ICToken.Error.NO_ERROR);
    }

    function repayBorrow(uint repayAmount) external payable returns (uint) {
        uint256 surplusTokens;
        uint256 zapAmount;
        if(repayAmount == type(uint256).max) {
            uint256 accountBorrows = borrowBalanceStored(msg.sender);
            require(msg.value > 0 && msg.value >= accountBorrows, "Invalid amount");
            surplusTokens = msg.value - accountBorrows;
            zapAmount = accountBorrows;
        } else {
            require(msg.value > 0 && msg.value == repayAmount, "Invalid amount");
            zapAmount = repayAmount;
        }

        _performZapIn(zapAmount);

        wS.approve(address(underlyingCToken), zapAmount);

        uint256 success = underlyingCToken.repayBorrowBehalf(msg.sender, repayAmount);

        require(success == 0, "Failed to reapy borrow");

        uint256 totalBorrows = underlyingCToken.totalBorrows();

        uint256 accountBorrowsNew = borrowBalanceStored(msg.sender);

        if(surplusTokens > 0) {
            payable(msg.sender).transfer(surplusTokens);
        }

        emit RepayBorrow(msg.sender, msg.sender, msg.value, accountBorrowsNew, totalBorrows);

        return uint(ICToken.Error.NO_ERROR);
    }

    /**
     * @notice Return the borrow balance of account based on stored data
     * @param account The address whose balance should be calculated
     * @return The calculated balance
     */
    function borrowBalanceStored(address account) public view returns (uint) {
        return underlyingCToken.borrowBalanceStored(account);
    }

    function _performZapIn(uint256 _amount) internal {
        uint256 initialBalance = wS.balanceOf(address(this));

        (bool success, ) = address(wS).call{value: msg.value}(
            abi.encodeWithSignature("deposit()")
        );

        require(success, "swapping failed");

        uint256 receivedAmount = wS.balanceOf(address(this)) - initialBalance;

        require(receivedAmount == _amount, "Invalid received wrapped token");

        emit ZapIn(msg.sender, _amount);
    }

    function _performZapOut(uint256 _amount) internal {
        uint256 initialBalance = address(this).balance;

        (bool success, ) = address(wS).call(
            abi.encodeWithSignature("withdraw(uint value)", _amount)
        );

        require(success, "swapping failed");

        uint256 receivedAmount = address(this).balance - initialBalance;

        require(receivedAmount == _amount, "Invalid received S token");

        emit ZapOut(msg.sender, _amount);
    }
}
