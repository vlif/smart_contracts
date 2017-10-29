pragma solidity ^0.4.16;

import './zeppelin/crowdsale/RefundableCrowdsale.sol';

import './ParazitConstants.sol';
import './ParazitMainRateProvider.sol';
import './ParazitGPCCToken.sol';

// Main crowdsale contract
contract ParazitMainCrowdsale is ParazitConstants, RefundableCrowdsale {
    uint constant TEAM_TOKENS = 20000000 * TOKEN_DECIMAL_MULTIPLIER; // 10%
    uint constant BOUNTY_TOKENS = 4000000 * TOKEN_DECIMAL_MULTIPLIER; // 2%

    // Test addresses. This addresses must be changed before deployment to mainnet
    address constant TEAM_ADDRESS = 0x583031d1113ad414f02576bd6afabfb302140225;
    address constant BOUNTY_ADDRESS = 0xdd870fa1b7c4700f2bd7f44238821c26f7392148;

    ParazitMainRateProviderI public rateProvider;
    bool private isInit = false;

    //1509281673,1509282633,"16666666666666666666666","200000000","0xca35b7d915458ef540ade6068dfe2f44e8fa733c","0x5e72914535f202659083db3a02c984188fa26e9f"
	function ParazitMainCrowdsale (
		uint32 _startTime, // crowdsale start time
		uint32 _endTime, // crowdsale end time
		uint _softCapWei, // minimum amount of funds to be raised in weis
        uint _hardCup, // maximum amount of tokens to mint
		address _wallet, // address where funds are collected
        address _token // the token being sold
	) RefundableCrowdsale(
        _startTime,
        _endTime,
        _hardCup * TOKEN_DECIMAL_MULTIPLIER, // 200 000 000 // 100%
        _wallet,
        _token,
        _softCapWei // 16666666666666666666666,666666667 Wei -> 16666,666666666666666666666666667 ETH -> 5000000,0000000000000000000000001 USD (300)
	) {
        ParazitMainRateProvider provider = new ParazitMainRateProvider();
        // provider.transferOwnership(owner);
        rateProvider = provider;
	}

    // Initialization of crowdsale. Starts once after deployment token contract
    // , deployment crowdsale contract and change token contract's owner 
    function init() onlyOwner public returns(bool) {
        require(!isInit);

        isInit = true;
        ParazitGPCCToken gpccToken = ParazitGPCCToken(token);

        require(token.mint(TEAM_ADDRESS, TEAM_TOKENS));
        require(token.mint(BOUNTY_ADDRESS, BOUNTY_TOKENS));

        gpccToken.addExcluded(TEAM_ADDRESS);
        gpccToken.addExcluded(BOUNTY_ADDRESS);

        return true;
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
        rateProvider = ParazitMainRateProviderI(_rateProviderAddress);
    }

    // Admin can move end time.
    function setEndTime(uint32 _endTime) onlyOwner notFinalized {
        require(_endTime > startTime);
        endTime = _endTime;
    }

    // Main crowdsale finalization. Allow move tokens if crowdsale goal reached
    function finalization() internal {
        super.finalization();

        token.finishMinting();
        if (goalReached()) {
            ParazitGPCCToken(token).allowMoveTokens();
        }
        token.transferOwnership(owner);
    }
}