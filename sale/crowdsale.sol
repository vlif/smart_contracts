pragma solidity ^0.4.16;

import "./base/crowdsale/RefundableCrowdsale.sol";

import "./constants.sol";
import "./cryptosale.sol";
import "./rateProvider.sol";

// delete
import "./freezingStorage.sol";
import "./token.sol";

/**
 * Example crowdsale contract
 * Contract cryptosale can buy sale tokens from crowdsale (rateProvider logic)
 */
contract ExampleCrowdsale is usingConstants, RefundableCrowdsale {
	RateProvider public rateProvider;

	function ExampleCrowdsale (
		uint32 _startTime,
		uint32 _endTime,
		// uint _rate,
		uint _softCapWei, // 0.01
		uint _hardCapTokens, // 3
		address _wallet,
		address _token,
		address _tokenHolder
	) RefundableCrowdsale(
        _startTime,
        _endTime, 
        240,
        _hardCapTokens * TOKEN_DECIMAL_MULTIPLIER,
        _wallet,
        _token,
        _softCapWei // goal
	) {
		require(_tokenHolder != 0x0);

		RateProvider provider = new RateProvider(_tokenHolder);
        // provider.transferOwnership(owner);
        rateProvider = provider;
	}

	// Override getRate to integrate with rate provider.
    function getRate() internal constant returns(uint) {
		return rateProvider.getRate(msg.sender, rate);
    }

    
    // [optional]
    function getDepositedAmount(address _beneficiary) public constant returns(uint) {
    	return vault.deposited(_beneficiary);
    }
}