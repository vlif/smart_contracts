pragma solidity ^0.4.16;

import "./zeppelin/crowdsale/RefundableCrowdsale.sol";
import "./ESportsConstants.sol";
import "./ESportsToken.sol";
import "./ESportsRateProvider.sol";

contract ESportsPreCrowdsale is usingESportsConstants, RefundableCrowdsale {
	/**
     * Constructor function
     */
    function ESportsPreCrowdsale(
		uint32 _startTime,
        uint32 _endTime,
        address _wallet,
		uint _softCapWei,
		uint _hardCapTokens
	) RefundableCrowdsale(
        _startTime, 
        _endTime, 
        240, // 240 ETR = 1 ETH at the rate 1 ETH = 250 EUR
        _hardCapTokens * TOKEN_DECIMAL_MULTIPLIER, //(_hardCapTokens * TOKEN_DECIMAL_MULTIPLIER - TEAM_TOKENS - INVESTOR_TOKENS - ....), // 60 000 000
        _wallet,
        _softCapWei // _goal // 2 000 000 -> 8 000 ETH (250) -> 8 000 000 000 000 000 000 000 Wei
	) {


		
	}
}
