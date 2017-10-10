pragma solidity ^0.4.16;

import "./base/crowdsale/RefundVault.sol";
import "./base/token/MintableToken.sol";

contract CrowdsaleInterface {
	RefundVault public vault;
	MintableToken public token;

	// Crowdsale should have payable function but if abstract declare this function here it is not work
	// function () payable;

	function claimRefund() public;

	function hasEnded() public constant returns (bool);
	function goalReached() public constant returns (bool);
}