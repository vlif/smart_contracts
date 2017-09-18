pragma solidity ^0.4.16;

import "./zeppelin/crowdsale/RefundableCrowdsale.sol";

import "./ESportsConstants.sol";
import "./ESportsToken.sol";
import "./ESportsRateProvider.sol";

contract ESportsCrowdsale is usingESportsConstants, RefundableCrowdsale {
	// uint constant minimalPurchase = 0.05 ether;

	// Overall 100.00% 60 000 000
	uint constant teamTokens = 12000000 * TOKEN_DECIMAL_MULTIPLIER; // 20.00%
	uint constant investorTokens = 3000000 * TOKEN_DECIMAL_MULTIPLIER; // 5.00%
	uint constant bufferTokens = 6000000 * TOKEN_DECIMAL_MULTIPLIER; // 10.00%
	uint constant bonusTokens = 3000000 * TOKEN_DECIMAL_MULTIPLIER; // 5.00%
	uint constant companyColdStorage = 12000000 * TOKEN_DECIMAL_MULTIPLIER; // 20.00%
    uint constant icoTokens = 24000000 * TOKEN_DECIMAL_MULTIPLIER; // 40.00%

	// address constant teamAddress = 0x001a041f7ABAb9871a22D2bEd0EC4dAb228866c3;
    // address constant bountyAddress = 0x0025ea8bBBB72199cf70FE25F92d3B298C3B162A;
    // address constant icoAccountAddress = 0x003b3f928c428525e9836C1d1b52016F4833c2f0;

    ESportsRateProviderI public rateProvider;

	/**
     * Constructor function
     */
	function ESportsCrowdsale(
		uint32 _startTime,
        uint32 _endTime,
        address _wallet, //address _addressOfTokenUsedAsReward,
		uint _softCapWei,
		uint _hardCapTokens
	) RefundableCrowdsale(
		_startTime, 
		_endTime, 
		1500, 
		_hardCapTokens * TOKEN_DECIMAL_MULTIPLIER, // 105 000 000
		_wallet, //_addressOfTokenUsedAsReward
		_softCapWei // _goal
	) {
		// token.mint(teamAddress, teamTokens);
        // token.mint(bountyAddress, bountyTokens);
        // token.mint(icoAccountAddress, icoTokens);

        // ESportsToken(token).addExcluded(teamAddress);
        // ESportsToken(token).addExcluded(bountyAddress);
        // ESportsToken(token).addExcluded(icoAccountAddress);

        // ESportsRateProvider provider = new ESportsRateProvider();
        // provider.transferOwnership(owner);
        // rateProvider = provider;



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
        return rateProvider.getRate(msg.sender, soldTokens, _value);
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