pragma solidity ^0.4.16;

import './zeppelin/crowdsale/RefundableCrowdsale.sol';

import './ParazitConstants.sol';
import './ParazitRateProvider.sol';
import './ParazitGPCCToken.sol';

// Pre ICO crowdsale contract
contract ParazitMainCrowdsale is ParazitConstants, RefundableCrowdsale 
{
    ParazitRateProviderI public rateProvider;

	function ParazitMainCrowdsale (
		uint32 _startTime, // pre ico start time
		uint32 _endTime, // pre ico end time
		uint _softCapWei, // minimum amount of funds to be raised in weis
        uint _hardCup, // maximum amount of tokens to mint
		address _wallet, // address where funds are collected
        address _token // the token being sold
	) RefundableCrowdsale(
        _startTime, 
        _endTime,
        _hardCup * TOKEN_DECIMAL_MULTIPLIER, // 10000000 // 5%
        _wallet, 
        _token,
        _softCapWei // 666666666666666666666 Wei -> 666,666666666666666666 ETH -> 199999,9999999999999998 USD (300)
	) {
        ParazitRateProvider provider = new ParazitRateProvider();
        // provider.transferOwnership(owner);
        rateProvider = provider;
	}

	// Override token creation to integrate with GPCC token.
    // function createTokenContract() internal returns (MintableToken) {
    //     return new ParazitGPCCToken();
    // }

	// Override getRate to integrate with rate provider.
    function getRate() internal constant returns(uint) {
		return rateProvider.getRate();
    }

    // Override getRateScale to integrate with rate provider.
    function getRateScale() internal constant returns (uint) {
        return rateProvider.getRateScale();
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

    // If pre ico finished then we need to change token owner
    function finalization() internal {
        super.finalization();

        token.transferOwnership(owner);
    }
}