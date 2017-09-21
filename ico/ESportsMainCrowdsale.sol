pragma solidity ^0.4.16;

import "./zeppelin/crowdsale/RefundableCrowdsale.sol";
import "./ESportsConstants.sol";
import "./ESportsToken.sol";
import "./ESportsRateProvider.sol";

contract ESportsMainCrowdsale is usingESportsConstants, RefundableCrowdsale {
    // using usingESportsConstants..;

    // uint constant minimalPurchase = 0.05 ether; // 50 000 000 000 000 000 Wei

	// Overall 100.00% 60 000 000
	uint constant TEAM_TOKENS = 12000000 * TOKEN_DECIMAL_MULTIPLIER; // 20.00%
	uint constant INVESTOR_TOKENS = 3000000 * TOKEN_DECIMAL_MULTIPLIER; // 5.00%
	uint constant BUFFER_TOKENS = 6000000 * TOKEN_DECIMAL_MULTIPLIER; // 10.00%
	uint constant BONUS_TOKENS = 3000000 * TOKEN_DECIMAL_MULTIPLIER; // 5.00%
	uint constant COMPANY_COLD_STORAGE = 12000000 * TOKEN_DECIMAL_MULTIPLIER; // 20.00%
    // uint constant ICO_TOKENS = 24000000 * TOKEN_DECIMAL_MULTIPLIER; // 40.00%

	address constant TEAM_ADDRESS_KOVAN = 0x0065ee8FB8697C686C27C0cE79ec6FA1f395D27e;
    // address constant BOUNTY_ADDRESS = 0x0025ea8bBBB72199cf70FE25F92d3B298C3B162A;
    // address constant ICO_ACCOUNT_ADDRESS_KOVAN = 0x00cbCcd31cdeeF93c302F1f0440e0aba1E45a6A4;
    address constant TEAM_ADDRESS_REMIX = 0x583031d1113ad414f02576bd6afabfb302140225;
    address constant ICO_ACCOUNT_ADDRESS_REMIX = 0xdd870fa1b7c4700f2bd7f44238821c26f7392148;

    ESportsRateProviderI public rateProvider;

	/**
     * Constructor function
     */
    function ESportsMainCrowdsale(
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
		// token.mint(TEAM_ADDRESS_KOVAN, TEAM_TOKENS);
        ESportsToken(token).mintAndFreezePart(TEAM_ADDRESS_KOVAN, TEAM_TOKENS, 50, _startTime + 20 * 1 minutes); //+1 years

        // token.mint(BOUNTY_ADDRESS, bountyTokens);
        // token.mint(ICO_ACCOUNT_ADDRESS_KOVAN, icoTokens);

        ESportsToken(token).addExcluded(TEAM_ADDRESS_KOVAN);
        // ESportsToken(token).addExcluded(BOUNTY_ADDRESS);
        // ESportsToken(token).addExcluded(ICO_ACCOUNT_ADDRESS_KOVAN);

        ESportsRateProvider provider = new ESportsRateProvider();
        provider.transferOwnership(owner);
        rateProvider = provider;
	}

	/**
     * @dev Override token creation to integrate with ESports token.
     */
    function createTokenContract() internal returns (MintableToken) {
        return new ESportsToken();
    }


    /**
     * @dev Override getRate to integrate with rate provider.
     */
    function getRate(uint _value) internal constant returns (uint) {
        return rateProvider.getRate(msg.sender, soldTokens, _value, startTime);
    }

    /**
     * @dev Override getRateScale to integrate with rate provider.
     */
    function getRateScale() internal constant returns (uint) {
        return rateProvider.getRateScale();
    }

    /**
     * @dev Admin can set new rate provider.
     * @param _rateProviderAddress New rate provider.
     */
    function setRateProvider(address _rateProviderAddress) onlyOwner {
        require(_rateProviderAddress != 0);
        rateProvider = ESportsRateProviderI(_rateProviderAddress);
    }


	/**
     * @dev Admin can move end time.
     * @param _endTime New end time.
     */
    function setEndTime(uint32 _endTime) onlyOwner {
        endTime = _endTime;
    }

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
        token.transferOwnership(owner);
    }
}
