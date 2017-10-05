pragma solidity ^0.4.16;

import './base/crowdsale/RefundVault.sol';
import './base/token/MintableToken.sol';

contract CrowdsaleInterface {
	RefundVault public vault;
	MintableToken public token;

	// У crowdsale должна быть паебал фоллбэк функция, но если тут ее определить абстрактно, то нихера не работает
	// function () payable;

	function claimRefund() public;

	function hasEnded() public constant returns (bool);
	function goalReached() public constant returns (bool);
}