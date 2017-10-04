pragma solidity ^0.4.16;

import "./base/ownership/Ownable.sol";
import './base/math/SafeMath.sol';

import "./crowdsaleInterface.sol";

contract TokenHolder is Ownable {
	using SafeMath for uint256;

	// Тут будем затариваться
	CrowdsaleInterface public crowdsale;
	// Запоминаем всех чуваков, которые обратились за помощью к cryptosale
	mapping (address => uint256) public deposited;

	function setCrowdsale(address _crowdsaleAddr) onlyOwner returns(bool) {
		crowdsale = CrowdsaleInterface(_crowdsaleAddr);

		return true;
	}

	// Основной метод покупки у crowdsale, вся магия тут
	function buyTokens(address _beneficiary, uint _amountWei) onlyOwner public {
		require(address(crowdsale) != 0x0); //crowdsale != CrowdsaleInterface(0x0)
		require(crowdsale.call.value(_amountWei)());

		deposited[_beneficiary] = deposited[_beneficiary].add(_amountWei);

		
	}

	// Возвращаем бабосики, если soft cup не пройден
	function claimRefund(address _investor) onlyOwner public returns(bool) {
		uint depositedValue = deposited[_investor];
		require(depositedValue > 0);

		crowdsale.claimRefund(); // refund TokenHolder

		deposited[_investor] = 0;
        _investor.transfer(depositedValue); // refund investor

		return true;
	}
}