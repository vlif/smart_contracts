pragma solidity ^0.4.17;

import "./open_zeppelin/crowdsale/RefundableCrowdsale.sol";

/**
 * 
 */
contract Token {
	function Token () {
		
	}	
}

/**
 * Контракт Cryptosale может покупать у Crowdsale со скидоном 
 * 
 */
contract Crowdsale is RefundableCrowdsale {
	function Crowdsale (
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


/**
 * 
 */
contract Cryptosale {
	function Cryptosale () {
		
	}	

	function() payable {

	}
}