pragma solidity ^0.4.16;

import "./base/ownership/Ownable.sol";
import "./crowdsaleInterface.sol";

/**
 * 
 */
contract Cryptosale is Ownable {
	CrowdsaleInterface public crowdsale;

	function Cryptosale (address _crowdsale) {
		require(_crowdsale != 0x0);

		crowdsale = CrowdsaleInterface(_crowdsale);
	}

	/**
	 * Тут по ходу нам надо  затариться токенами со скидкой у контракта crowdsale
	 */
	function() payable {
		// buyTokens(msg.sender, msg.value);
	}

	function setCrowdsale(address _crowdsale) onlyOwner returns(bool) {
		require(_crowdsale != 0x0);

		crowdsale = CrowdsaleInterface(_crowdsale);

		return true;
	}

	function buyTokens(address beneficiary, uint amountWei) returns(uint) {
		return crowdsale.test(12);

		
	}
}