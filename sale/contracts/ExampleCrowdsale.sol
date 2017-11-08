pragma solidity ^0.4.16;

import "./base/crowdsale/RefundableCrowdsale.sol";

import "./Constants.sol";
import "./Cryptosale.sol";
import "./RateProvider.sol";

// delete
// import "./FreezingStorage.sol";
// import "./ExampleToken.sol";

/**
 * Example crowdsale contract
 * Contract cryptosale can buy sale tokens from crowdsale (rateProvider logic)
 */
contract ExampleCrowdsale is Constants, RefundableCrowdsale {
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

	/**
     * internal methods
     */

	// Override getRate to integrate with rate provider.
    function getRate() internal constant returns(uint) {
		return rateProvider.getRate(msg.sender, rate);
    }

    /**
     * optional methods
     */

    function getDepositedAmount(address _beneficiary) public constant returns(uint) {
    	return vault.deposited(_beneficiary);
    }
}