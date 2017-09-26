pragma solidity ^0.4.16;

import "./zeppelin/crowdsale/RefundableCrowdsale.sol";
import './zeppelin/math/SafeMath.sol';

import "./ESportsConstants.sol";
import "./ESportsToken.sol";
// import "./ESportsRateProvider.sol";
// import "./ESportsFreezingStorage.sol";
import "./ESportsBonusProvider.sol";

contract ESportsMainCrowdsale is usingESportsConstants, RefundableCrowdsale {
    // uint constant minimalPurchase = 0.05 ether; // 50 000 000 000 000 000 Wei

	// Overall 100.00% 60 000 000
	// uint constant TEAM_TOKENS = 12000000 * TOKEN_DECIMAL_MULTIPLIER; // 20.00% // Founders
    uint constant TEAM_BEN_TOKENS = 6000000 * TOKEN_DECIMAL_MULTIPLIER;
    uint constant TEAM_PHIL_TOKENS = 6000000 * TOKEN_DECIMAL_MULTIPLIER;
    uint constant COMPANY_COLD_STORAGE_TOKENS = 12000000 * TOKEN_DECIMAL_MULTIPLIER; // 20.00%
	// it is separate wallet which is driven by the team and can be rewarded from to any investor the TEAM choose
    uint constant INVESTOR_TOKENS = 3000000 * TOKEN_DECIMAL_MULTIPLIER; // 5.00%
    
    uint constant BONUS_TOKENS = 3000000 * TOKEN_DECIMAL_MULTIPLIER; // 5.00% // pre-sale
	uint constant BUFFER_TOKENS = 6000000 * TOKEN_DECIMAL_MULTIPLIER; // 10.00%

    uint constant PRE_ICO_TOKENS = 12000000 * TOKEN_DECIMAL_MULTIPLIER;
    // uint constant ICO_TOKENS = 24000000 * TOKEN_DECIMAL_MULTIPLIER; // 40.00%

	// address constant TEAM_ADDRESS_KOVAN = 0x0065ee8FB8697C686C27C0cE79ec6FA1f395D27e;
    address constant TEAM_BEN_ADDRESS_KOVAN = 0x000b341E1774b02D77a1175971BC50b841D21eD0;
    address constant TEAM_PHIL_ADDRESS_KOVAN = 0x004C05E2c37a73233B63d09c52C4f68AFDfb1763;
    address constant WALLET_ADDRESS_KOVAN = 0x00cbCcd31cdeeF93c302F1f0440e0aba1E45a6A4;
    address constant INVESTOR_ADDRESS_KOVAN = 0x00657a4639f55083524242540ED3B0bdA534f69B;
    address constant BONUS_ADDRESS_KOVAN = 0x0005762D49BC63F16B39aead421b2ad9Db794f2B;
    // address constant PRE_ICO_ADDRESS = ;

    // ESportsRateProviderI public rateProvider;
    ESportsBonusProviderI public bonusProvider;

    bool private isInit = false;

	/**
     * Constructor function
     */
    function ESportsMainCrowdsale(
        uint32 _startTime,
        uint32 _endTime,
        uint _softCapWei,
        uint _hardCapTokens,
        address _wallet,
        address _token
	) RefundableCrowdsale(
        _startTime,
        _endTime, 
        240, // 240 ETR = 1 ETH at the rate 1 ETH = 250 EUR
        _hardCapTokens * TOKEN_DECIMAL_MULTIPLIER, //(_hardCapTokens * TOKEN_DECIMAL_MULTIPLIER - TEAM_TOKENS - INVESTOR_TOKENS - ....), // 60 000 000
        _wallet, //=WALLET_ADDRESS_KOVAN
        _token,
        _softCapWei // _goal // 2 000 000 -> 8 000 ETH (250) -> 8 000 000 000 000 000 000 000 Wei
	) {
        // token.delegatecall(bytes4(sha3("transferOwnership(address)")), this);



	}

	/**
     * @dev Override token creation to integrate with ESports token.
     */
    // function createTokenContract() internal returns(MintableToken) {
    //     return new ESportsToken();
    // }

    /**
     * @dev Override getRate to integrate with rate provider.
     */
    // function getRate(uint _value) internal constant returns(uint) {
    //     return rateProvider.getRate(msg.sender, soldTokens, _value, startTime);
    // }

    /**
     * @dev Override getRateScale to integrate with rate provider.
     */
    // function getRateScale() internal constant returns(uint) {
    //     return rateProvider.getRateScale();
    // }

    ///**
    // * @dev Admin can set new rate provider.
    // * @param _rateProviderAddress New rate provider.
    // */
    // function setRateProvider(address _rateProviderAddress) onlyOwner {
    //     require(_rateProviderAddress != 0);

    //     rateProvider = ESportsRateProviderI(_rateProviderAddress);
    // }

    function addBonus(uint _amountTokens) internal returns(uint) {
        return bonusProvider.addBonus(msg.sender, soldTokens, _amountTokens, startTime);
    }

    function getBonus() returns(uint) {
        return bonusProvider.getBonus(msg.sender, soldTokens);
    }

    function sendBonus(address _beneficiary, uint _amountBonusTokens) internal returns(uint) {
        return bonusProvider.sendBonus(_beneficiary, _amountBonusTokens);
    }

    function setBonusProvider(address _bonusProviderAddress) onlyOwner {
        require(_bonusProviderAddress != 0);

        bonusProvider = ESportsBonusProviderI(_bonusProviderAddress);
    }

	///**
    // * @dev Admin can move end time.
    // * @param _endTime New end time.
    // */
    // function setEndTime(uint32 _endTime) onlyOwner {
    //     endTime = _endTime;
    // }

    // function validPurchase(uint _amountWei, uint _actualRate, uint _totalSupply) internal constant returns (bool) {
    //     if (_amountWei < minimalPurchase) {
    //         return false;
    //     }

    //     return super.validPurchase(_amountWei, _actualRate, _totalSupply);
    // }

    function finalization() internal {
        super.finalization();
        token.finishMinting();
        if (!goalReached()) {
            return;
        }

        ESportsToken(token).crowdsaleFinished();
        token.transferOwnership(owner); // change token owner
    }

    function init() onlyOwner public returns(bool) {
        require(!isInit);

        mintToFounders();

        token.mint(INVESTOR_ADDRESS_KOVAN, INVESTOR_TOKENS);

        // bonuses
        token.mint(BONUS_ADDRESS_KOVAN, BONUS_TOKENS);
        token.mint(this, BUFFER_TOKENS);

        // ESportsToken(token).addExcluded(TEAM_ADDRESS_KOVAN);
        ESportsToken(token).addExcluded(INVESTOR_ADDRESS_KOVAN);
        ESportsToken(token).addExcluded(BONUS_ADDRESS_KOVAN);

        initProviders();

        isInit = true;
        return isInit;
    }

    function mintToFounders() onlyOwner internal returns(bool) {
        // ESportsToken(token).mintAndFreezePart(TEAM_ADDRESS_KOVAN, TEAM_TOKENS, 50, _startTime + 5 * 1 minutes); //+1 years
        // token.mint(TEAM_ADDRESS_KOVAN, TEAM_TOKENS);

        ESportsToken(token).mintTimelocked(TEAM_BEN_ADDRESS_KOVAN, TEAM_BEN_TOKENS.mul(20).div(100), startTime + 1 years); //minutes
        ESportsToken(token).mintTimelocked(TEAM_BEN_ADDRESS_KOVAN, TEAM_BEN_TOKENS.mul(30).div(100), startTime + 3 years); //minutes
        ESportsToken(token).mintTimelocked(TEAM_BEN_ADDRESS_KOVAN, TEAM_BEN_TOKENS.mul(30).div(100), startTime + 5 years); //minutes
        token.mint(TEAM_BEN_ADDRESS_KOVAN, TEAM_BEN_TOKENS.mul(20).div(100));

        ESportsToken(token).mintTimelocked(TEAM_PHIL_ADDRESS_KOVAN, TEAM_PHIL_TOKENS.mul(20).div(100), startTime + 1 years); //minutes
        ESportsToken(token).mintTimelocked(TEAM_PHIL_ADDRESS_KOVAN, TEAM_PHIL_TOKENS.mul(30).div(100), startTime + 3 years); //minutes
        ESportsToken(token).mintTimelocked(TEAM_PHIL_ADDRESS_KOVAN, TEAM_PHIL_TOKENS.mul(30).div(100), startTime + 5 years); //minutes
        token.mint(TEAM_PHIL_ADDRESS_KOVAN, TEAM_PHIL_TOKENS.mul(20).div(100));

        return true;
    }

    function initProviders() onlyOwner internal returns(bool) {
        // ESportsRateProvider rProvider = new ESportsRateProvider();
        // rProvider.transferOwnership(owner);
        // rateProvider = rProvider;

        ESportsBonusProvider bProvider = new ESportsBonusProvider(this, ESportsToken(token));
        // bProvider.transferOwnership(owner);
        bonusProvider = bProvider;

        return true;
    }
}