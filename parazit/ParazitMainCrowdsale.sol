pragma solidity ^0.4.16;

import './zeppelin/crowdsale/RefundableCrowdsale.sol';

import './ParazitConstants.sol';
import './ParazitRateProvider.sol';
import './ParazitGPCCToken.sol';

// Crowdsale contract (pre-ico + ico)
contract ParazitMainCrowdsale is usingParazitConstants, RefundableCrowdsale {
	ParazitRateProviderI public rateProvider;

	function ParazitMainCrowdsale (
		uint32 _startTime, // pre ico start time
		uint32 _endTime, // ?
		uint _softCapWei, // ? goal 
		uint _hardCapTokens, // 200000000
		address _wallet // ?
	) RefundableCrowdsale(
        _startTime, 
        _endTime,
        _hardCapTokens * TOKEN_DECIMAL_MULTIPLIER, 
        _wallet, 
        _softCapWei
	) {
	}

	// Override token creation to integrate with MyWill token.
    function createTokenContract() internal returns (MintableToken) {
        return new ParazitGPCCToken();
    }

	// Override getRate to integrate with rate provider.
    function getRate() internal constant returns(uint) {
		return rateProvider.getRate(msg.sender, soldTokens);
    }

    // Admin can set new rate provider.
    function setRateProvider(address _rateProviderAddress) onlyOwner {
        require(_rateProviderAddress != 0x0);
        rateProvider = ParazitRateProviderI(_rateProviderAddress);
    }

    // Admin can move end time.
    function setEndTime(uint32 _endTime) onlyOwner notFinalized {
        require(_endTime > startTime);
        endTime = _endTime;
    }
}