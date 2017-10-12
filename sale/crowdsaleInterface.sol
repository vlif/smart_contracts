pragma solidity ^0.4.16;

import "./base/crowdsale/RefundVault.sol";
import "./base/token/MintableToken.sol";

// Abstract crowdsale interface contract
contract CrowdsaleInterface {
	RefundVault public vault;
	MintableToken public token;
	// start and end timestamps where investments are allowed (both inclusive)
    uint public startTime;
	
	// Crowdsale should have payable function but if abstract declare this function here it is not work
	// function () payable;

	function claimRefund() public;

	function hasEnded() public constant returns (bool);
	function goalReached() public constant returns (bool);
}