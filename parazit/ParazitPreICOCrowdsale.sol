pragma solidity ^0.4.16;

/**
 * ATTENTION! Source code of zeppelin smart contract was changed.
 */

import './zeppelin/crowdsale/RefundableCrowdsale.sol';

import './ParazitConstants.sol';
import './ParazitPreICORateProvider.sol';
import './ParazitGPCCToken.sol';

// Pre ICO crowdsale contract
contract ParazitPreICOCrowdsale is ParazitConstants, RefundableCrowdsale {
    ParazitPreICORateProviderI public rateProvider;

    //1509281673,1509282633,"666666666666666666666","10000000","0xca35b7d915458ef540ade6068dfe2f44e8fa733c","0x5e72914535f202659083db3a02c984188fa26e9f"
	function ParazitPreICOCrowdsale (
		uint32 _startTime, // pre ico start time
		uint32 _endTime, // pre ico end time
		uint _softCapWei, // minimum amount of funds to be raised in weis
        uint _hardCup, // maximum amount of tokens to mint
		address _wallet, // address where funds are collected
        address _token // the token being sold
	) RefundableCrowdsale(
        _startTime,
        _endTime,
        _hardCup * TOKEN_DECIMAL_MULTIPLIER, // 10 000 000 // 5%
        _wallet,
        _token,
        _softCapWei // 666666666666666666666 Wei -> 666,666666666666666666 ETH -> 199999,9999999999999998 USD (300)
	) {
        ParazitPreICORateProvider provider = new ParazitPreICORateProvider();
        // provider.transferOwnership(owner);
        rateProvider = provider;
	}

	// Override token creation to integrate with GPCC token
    // function createTokenContract() internal returns (MintableToken) {
    //     return new ParazitGPCCToken();
    // }

	// Override getRate to integrate with rate provider
    function getRate() internal constant returns(uint) {
		return rateProvider.getRate();
    }

    // Override getRateScale to integrate with rate provider
    // function getRateScale() internal constant returns (uint) {
    //     return rateProvider.getRateScale();
    // }

    // Admin can set new rate provider
    function setRateProvider(address _rateProviderAddress) onlyOwner {
        require(_rateProviderAddress != 0x0);
        rateProvider = ParazitPreICORateProviderI(_rateProviderAddress);
    }

    // Admin can move end time
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