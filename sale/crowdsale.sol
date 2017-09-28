pragma solidity ^0.4.16;

import "./base/crowdsale/RefundableCrowdsale.sol";
import "./constants.sol";
import "./cryptosale.sol";

/**
 * Пример контракта crowdsale
 * Контракт Cryptosale может покупать у Crowdsale со скидоном 
 * 
 */
contract ExampleCrowdsale is usingConstants, RefundableCrowdsale {
	Cryptosale cryptosale;

	address constant TEST_ACC = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
	uint constant TEST_TOKENS = 10000000;

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
		cryptosale = Cryptosale(_cryptosaleContractAddress);

		// token.mint(TEST_ACC, TEST_TOKENS);



	}
}