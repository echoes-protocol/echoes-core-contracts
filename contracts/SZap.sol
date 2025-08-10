// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import {ICToken} from "./interfaces/ICToken.sol";
import {IWrappedToken} from "./interfaces/IWrappedToken.sol";

contract SZap {
    IWrappedToken public immutable wS;
    ICToken public immutable underlyingCToken;

    event ZapIn(address user, uint256 amount);

    constructor(address _wS, address _underlyingCToken) {
        wS = IWrappedToken(_wS);
        underlyingCToken = ICToken(_underlyingCToken);
    }

    /**
     @notice This function is used to zap S token to wS cToken.
     @param _amount The amount of fromToken.
     */
    function mint(uint _amount) external payable returns (uint256) {
        require(msg.value > 0 && msg.value == _amount, "Invalid amount");

        uint256 initialBalance = wS.balanceOf(address(this));

        (bool success, ) = address(wS).call{value: msg.value}(
            abi.encodeWithSignature("deposit()")
        );

        require(success, 'swapping failed');

        uint256 receivedAmount = wS.balanceOf(address(this)) - initialBalance;

        require(receivedAmount == _amount, "Invalid received wrapped token");

        wS.approve(address(underlyingCToken), _amount);

        uint256 cTokenBalanceBefore = underlyingCToken.balanceOf(address(this));

        underlyingCToken.mint(_amount);

        uint256 receivedCToken = underlyingCToken.balanceOf(address(this)) -
            cTokenBalanceBefore;

        underlyingCToken.transfer(msg.sender, receivedCToken);

        emit ZapIn(msg.sender, _amount);

        return uint(ICToken.Error.NO_ERROR);
    }
}
