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

    event Mint(address minter, uint mintAmount);
    event Redeem(address redeemer, uint redeemAmount);
    event RepayBorrow(address payer, address borrower, uint repayAmount);

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

        emit Mint(msg.sender, _amount);

        return uint(ICToken.Error.NO_ERROR);
    }

    function redeemUnderlying(uint redeemAmount) external returns (uint) {
        uint256 initialBalance = wS.balanceOf(address(this));

        uint256 exchangeRate = underlyingCToken.exchangeRateStored();

        uint256 redeemTokens = redeemAmount  * expScale / exchangeRate;

        underlyingCToken.transferFrom(msg.sender, address(this), redeemTokens);

        uint256 success = underlyingCToken.redeemUnderlying(redeemAmount);

        uint256 receivedCToken = wS.balanceOf(address(this)) - initialBalance;

        if (success != 0 || receivedCToken != redeemAmount) {
            revert("Failed to receive cTokens");
        }

        _performZapOut(redeemAmount);

        payable(msg.sender).transfer(redeemAmount);

        emit Redeem(msg.sender, redeemAmount);

        return uint(ICToken.Error.NO_ERROR);
    }

    function repayBorrow(uint repayAmount) external payable returns (uint) {
        if(repayAmount == type(uint256).max) {
            uint256 accountBorrows = underlyingCToken.borrowBalanceStored(msg.sender);
            require(msg.value > 0 && msg.value == accountBorrows, "Invalid amount");
        } else {
            require(msg.value > 0 && msg.value == repayAmount, "Invalid amount");
        }

        _performZapIn(msg.value);

        wS.approve(address(underlyingCToken), msg.value);

        uint256 success = underlyingCToken.repayBorrowBehalf(msg.sender, repayAmount);

        require(success == 0, "Failed to reapy borrow");

        emit RepayBorrow(msg.sender, msg.sender, msg.value);

        return uint(ICToken.Error.NO_ERROR);
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
