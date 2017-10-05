pragma solidity ^0.4.16;

import "./base/crowdsale/RefundableCrowdsale.sol";

import "./constants.sol";
import "./cryptosale.sol";
import "./rateProvider.sol";

/**
 * Example crowdsale contract
 * Contract cryptosale can buy sale tokens from crowdsale (rateProvider logic)
 * 
 */
//1506613146, 1506699546, "10000000000000000", 3, "0xdd870fa1b7c4700f2bd7f44238821c26f7392148", "0x5e72914535f202659083db3a02c984188fa26e9f", "0x0dcd2f752394c41875e259e00bb44fd505297caf"
contract ExampleCrowdsale is usingConstants, RefundableCrowdsale {
	address constant TEST_ACC = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
	uint constant TEST_TOKENS = 10000000;

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

		// token.mint(TEST_ACC, TEST_TOKENS);
	}

	/**
     * @dev Override getRate to integrate with rate provider.
     */
    function getRate() internal constant returns(uint) {
		return rateProvider.getRate(msg.sender, rate);
    }

    // [optional]
    function getDepositedAmount(address _beneficiary) public constant returns(uint) {
    	return vault.deposited(_beneficiary);
    }
}