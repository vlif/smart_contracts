pragma solidity ^0.4.16;

import "./base/crowdsale/RefundableCrowdsale.sol";
import "./constants.sol";
import "./cryptosale.sol";
import "./rateProvider.sol";

/**
 * Пример контракта crowdsale
 * Контракт Cryptosale может покупать у Crowdsale со скидоном (логика в rateProvider)
 * 
 */
//1506613146, 1506699546, "10000000000000000", 3, "0xdd870fa1b7c4700f2bd7f44238821c26f7392148", "0x5e72914535f202659083db3a02c984188fa26e9f", "0x0dcd2f752394c41875e259e00bb44fd505297caf"
contract ExampleCrowdsale is usingConstants, RefundableCrowdsale {
	address constant TEST_ACC = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
	uint constant TEST_TOKENS = 10000000;

	RateProvider public rateProvider; //RateProviderI

	function ExampleCrowdsale (
		uint32 _startTime,
		uint32 _endTime, 
		// uint _rate, 
		uint _softCapWei, // 0.01
		uint _hardCapTokens, // 3
		address _wallet,
		address _token,
		address _cryptosaleContractAddress
	) RefundableCrowdsale(
        _startTime,
        _endTime, 
        240,
        _hardCapTokens * TOKEN_DECIMAL_MULTIPLIER,
        _wallet,
        _token,
        _softCapWei // goal
	) {
		RateProvider provider = new RateProvider(_cryptosaleContractAddress);
        // provider.transferOwnership(owner);
        rateProvider = provider;

		// token.mint(TEST_ACC, TEST_TOKENS);



	}

	/**
     * @dev Override getRate to integrate with rate provider.
     */
    function getRate() internal constant returns(uint) { //uint _value
		return rateProvider.getRate(msg.sender, rate); //, soldTokens, _value, startTime
    }

    function test(uint param) returns(uint) {
    	return param;
    }
}