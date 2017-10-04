pragma solidity ^0.4.16;

import "./base/ownership/Ownable.sol";

import "./tokenHolder.sol";

/**
 * Чудо контракт с фишечкой, фасад для TokenHolder
 */
contract Cryptosale is Ownable {
	// Этот контракт знает, кто и сколько купил и на его счету висят все токены
	TokenHolder public tokenHolder;

	function Cryptosale() {
		tokenHolder = new TokenHolder();
	}

	/**
	 * Тут по ходу нам надо затариться токенами со скидкой у контракта crowdsale через TokenHolder
	 */
	function() payable {
		tokenHolder.buyTokens.value(msg.value)(msg.sender); //,msg.value
	}

	// Можно затариваться в другом месте, фасадный метод
	function setCrowdsale(address _crowdsaleAddr) onlyOwner returns(bool) {
		require(_crowdsaleAddr != 0x0);

		return tokenHolder.setCrowdsale(_crowdsaleAddr);
	}

	// Возвращаем бабосики, если soft cup не пройден, фасадный метод
	function claimRefund() public returns(bool) {
		return tokenHolder.claimRefund(msg.sender);
	}
}