pragma solidity ^0.4.16;

import "./base/ownership/Ownable.sol";
import "./base/math/SafeMath.sol";
import "./base/crowdsale/RefundVault.sol";
import './base/token/MintableToken.sol';

import "./crowdsaleInterface.sol";
import "./refundVaultCommon.sol";

contract TokenHolder is Ownable, RefundVaultCommon {
	using SafeMath for uint256;

	// Linked crowdsale contract
	CrowdsaleInterface public crowdsale;
	// Will remember all dudes who ask help of cryptosale
	// mapping (address => uint256) public deposited;

	function setCrowdsale(address _crowdsale) onlyOwner public {
		crowdsale = CrowdsaleInterface(_crowdsale);
	}

	// Основной метод покупки у crowdsale, вся магия тут
	function buyTokens(address _beneficiary) onlyOwner payable public {
		uint amountWei = msg.value;
		require(crowdsale.call.value(amountWei)());

		deposited[_beneficiary] = deposited[_beneficiary].add(amountWei);
	}

	// Возвращаем бабосики, если soft cup не пройден
	function claimRefund(address _investor) onlyOwner public {
		require(state == State.Refunding);
		uint depositedValue = deposited[_investor];
		require(depositedValue > 0);

		RefundVault vault = RefundVault(crowdsale.vault());
		if (vault.deposited(this) > 0) {
			crowdsale.claimRefund(); // refund TokenHolder
		}

		deposited[_investor] = 0;
        _investor.transfer(depositedValue); // refund investor
        Refunded(_investor, depositedValue);
	}

	// Без этого чет не работает
	function() payable {
	}

	// [optional]
	function getDepositedAmount() public returns(uint) {
		RefundVault vault = RefundVault(crowdsale.vault());
		return vault.deposited(this);
	}

	function crowdsaleHasEnded() public returns(bool) {
		return crowdsale.hasEnded();
	}

	function crowdsaleGoalReached() public returns(bool) {
		return crowdsale.goalReached();
	}

	// Раздаем токены инвесторам
	function withdraw(address _investor) onlyOwner public returns(bool) {
		require(state == State.Withdraw);
		uint depositedValue = deposited[_investor];
        require(depositedValue > 0);

        deposited[_investor] = 0;
        MintableToken token = MintableToken(crowdsale.token());
        return token.transfer(_investor, depositedValue);
	}
}