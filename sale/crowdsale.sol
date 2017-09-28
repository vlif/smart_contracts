pragma solidity ^0.4.16;

import "./open_zeppelin/crowdsale/RefundableCrowdsale.sol";
import "./constants.sol";

/**
 * 
 */
contract Token {
	function Token () {
		
	}	
}

/**
 * Пример контракта crowdsale
 * Контракт Cryptosale может покупать у Crowdsale со скидоном 
 * 
 */
contract ExampleCrowdsale is usingConstants, RefundableCrowdsale {
	function ExampleCrowdsale (
		uint32 _startTime,
		uint32 _endTime, 
		// uint _rate, 
		uint _softCapWei,
		uint _hardCapTokens, 
		address _wallet, 
		address _token,
		address _cryptosaleContractAddress
	) RefundableCrowdsale(
        _startTime,
        _endTime, 
        100,
        _hardCapTokens * TOKEN_DECIMAL_MULTIPLIER,
        _wallet,
        _token,
        _softCapWei // goal
	) {
		

		
	}
}