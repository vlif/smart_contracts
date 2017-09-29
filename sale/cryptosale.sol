pragma solidity ^0.4.16;

import "./base/ownership/Ownable.sol";
import './base/math/SafeMath.sol';

import "./crowdsaleInterface.sol";

/**
 * 
 */
contract Cryptosale is Ownable {
	using SafeMath for uint256;

	// Тут будем затариваться
	CrowdsaleInterface public crowdsale;
	// Запоминаем всех чуваков, которые обратились за помощью к cryptosale
	mapping (address => uint256) public deposited;

	// function Cryptosale () {
	// }

	/**
	 * Тут по ходу нам надо затариться токенами со скидкой у контракта crowdsale
	 */
	function() payable {
		buyTokens(msg.sender, msg.value);
	}

	// Можно затариваться в другом месте
	function setCrowdsale(address _crowdsale) onlyOwner returns(bool) {
		require(_crowdsale != 0x0);

		crowdsale = CrowdsaleInterface(_crowdsale);

		return true;
	}

	// Основной метод покупки у crowdsale, вся магия тут
	function buyTokens(address _beneficiary, uint _amountWei) internal {
		require(crowdsale != CrowdsaleInterface(0x0));
		require(crowdsale.call.value(_amountWei)());

		deposited[_beneficiary] = deposited[_beneficiary].add(_amountWei);
	}

	function claimRefund() public returns(bool) {
		address investor = msg.sender;
		uint256 depositedValue = deposited[investor];
		require(depositedValue > 0);
		require(crowdsale.call.claimRefund()); // refund cryptosale

		deposited[investor] = 0;
        investor.transfer(depositedValue); // refund investor

		return true;
	}
}