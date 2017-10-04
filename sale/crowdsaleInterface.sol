pragma solidity ^0.4.16;

import './base/crowdsale/RefundVault.sol';

contract CrowdsaleInterface {
	RefundVault public vault;
	
	// У crowdsale должна быть паебал фоллбэк функция, но если тут ее определить абстрактно, то нихера не работает
	// function () payable;

	// function hasEnded() public constant returns (bool);
	// function goalReached() public constant returns (bool);

	function claimRefund() public;
	
	
	
}