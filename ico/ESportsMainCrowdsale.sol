pragma solidity ^0.4.16;

/**
 * ATTENTION! Source code of zeppelin smart contract was changed.
 */

import "./zeppelin/crowdsale/RefundableCrowdsale.sol";
import "./zeppelin/math/SafeMath.sol";

import "./ESportsConstants.sol";
import "./ESportsToken.sol";
import "./ESportsBonusProvider.sol";

contract ESportsMainCrowdsale is ESportsConstants, RefundableCrowdsale {
    uint constant OVERALL_AMOUNT_TOKENS = 60000000 * TOKEN_DECIMAL_MULTIPLIER; // overall 100.00%
    uint constant TEAM_BEN_TOKENS = 6000000 * TOKEN_DECIMAL_MULTIPLIER; // 20.00% // Founders
    uint constant TEAM_PHIL_TOKENS = 6000000 * TOKEN_DECIMAL_MULTIPLIER;
    uint constant COMPANY_COLD_STORAGE_TOKENS = 12000000 * TOKEN_DECIMAL_MULTIPLIER; // 20.00%
    uint constant INVESTOR_TOKENS = 3000000 * TOKEN_DECIMAL_MULTIPLIER; // 5.00%
    uint constant BONUS_TOKENS = 3000000 * TOKEN_DECIMAL_MULTIPLIER; // 5.00% // Pre-sale
	uint constant BUFFER_TOKENS = 6000000 * TOKEN_DECIMAL_MULTIPLIER; // 10.00%
    uint constant PRE_SALE_TOKENS = 12000000 * TOKEN_DECIMAL_MULTIPLIER; // 20.00%

    // Mainnet addresses
    address constant TEAM_BEN_ADDRESS = 0x2E352Ed15C4321f4dd7EdFc19402666dE8713cd8;
    address constant TEAM_PHIL_ADDRESS = 0x4466de3a8f4f0a0f5470b50fdc9f91fa04e00e34;
    address constant INVESTOR_ADDRESS = 0x14f8d0c41097ca6fddb6aa4fd6a3332af3741847;
    address constant BONUS_ADDRESS = 0x5baee4a9938d8f59edbe4dc109119983db4b7bd6;
    address constant COMPANY_COLD_STORAGE_ADDRESS = 0x700d6ae53be946085bb91f96eb1cf9e420236762;
    address constant PRE_SALE_ADDRESS = 0xcb2809926e615245b3af4ebce5af9fbe1a6a4321;
    
    address btcBuyer = 0x1eee4c7d88aadec2ab82dd191491d1a9edf21e9a;

    ESportsBonusProvider public bonusProvider;

    bool private isInit = false;
    
	/**
     * Constructor function
     */
    function ESportsMainCrowdsale(
        uint32 _startTime,
        uint32 _endTime,
        uint _softCapWei, // 4000000 EUR
        address _wallet,
        address _token
	) RefundableCrowdsale(
        _startTime,
        _endTime, 
        RATE,
        OVERALL_AMOUNT_TOKENS,
        _wallet,
        _token,
        _softCapWei
	) {
	}

    /**
     * @dev Release delayed bonus tokens
     * @return Amount of got bonus tokens
     */
    function releaseBonus() returns(uint) {
        return bonusProvider.releaseBonus(msg.sender, soldTokens);
    }

    /**
     * @dev Trasfer bonuses and adding delayed bonuses
     * @param _beneficiary Future bonuses holder
     * @param _tokens Amount of bonus tokens
     */
    function postBuyTokens(address _beneficiary, uint _tokens) internal {
        uint bonuses = bonusProvider.getBonusAmount(_beneficiary, soldTokens, _tokens, startTime);
        bonusProvider.addDelayedBonus(_beneficiary, soldTokens, _tokens);

        if (bonuses > 0) {
            bonusProvider.sendBonus(_beneficiary, bonuses);
        }
    }

    /**
     * @dev Initialization of crowdsale. Starts once after deployment token contract
     * , deployment crowdsale contract and changу token contract's owner 
     */
    function init() onlyOwner public returns(bool) {
        require(!isInit);

        ESportsToken ertToken = ESportsToken(token);
        isInit = true;

        ESportsBonusProvider bProvider = new ESportsBonusProvider(ertToken, COMPANY_COLD_STORAGE_ADDRESS);
        // bProvider.transferOwnership(owner);
        bonusProvider = bProvider;

        mintToFounders(ertToken);

        require(token.mint(INVESTOR_ADDRESS, INVESTOR_TOKENS));
        require(token.mint(COMPANY_COLD_STORAGE_ADDRESS, COMPANY_COLD_STORAGE_TOKENS));
        require(token.mint(PRE_SALE_ADDRESS, PRE_SALE_TOKENS));

        // bonuses
        require(token.mint(BONUS_ADDRESS, BONUS_TOKENS));
        require(token.mint(bonusProvider, BUFFER_TOKENS)); // mint bonus token to bonus provider
        
        ertToken.addExcluded(INVESTOR_ADDRESS);
        ertToken.addExcluded(BONUS_ADDRESS);
        ertToken.addExcluded(COMPANY_COLD_STORAGE_ADDRESS);
        ertToken.addExcluded(PRE_SALE_ADDRESS);

        ertToken.addExcluded(address(bonusProvider));

        return true;
    }

    /**
     * @dev Mint of tokens in the name of the founders and freeze part of them
     */
    function mintToFounders(ESportsToken ertToken) internal {
        ertToken.mintTimelocked(TEAM_BEN_ADDRESS, TEAM_BEN_TOKENS.mul(20).div(100), startTime + 1 years);
        ertToken.mintTimelocked(TEAM_BEN_ADDRESS, TEAM_BEN_TOKENS.mul(30).div(100), startTime + 3 years);
        ertToken.mintTimelocked(TEAM_BEN_ADDRESS, TEAM_BEN_TOKENS.mul(30).div(100), startTime + 5 years);
        require(token.mint(TEAM_BEN_ADDRESS, TEAM_BEN_TOKENS.mul(20).div(100)));

        ertToken.mintTimelocked(TEAM_PHIL_ADDRESS, TEAM_PHIL_TOKENS.mul(20).div(100), startTime + 1 years);
        ertToken.mintTimelocked(TEAM_PHIL_ADDRESS, TEAM_PHIL_TOKENS.mul(30).div(100), startTime + 3 years);
        ertToken.mintTimelocked(TEAM_PHIL_ADDRESS, TEAM_PHIL_TOKENS.mul(30).div(100), startTime + 5 years);
        require(token.mint(TEAM_PHIL_ADDRESS, TEAM_PHIL_TOKENS.mul(20).div(100)));
    }

    /**
     * @dev Purchase for bitcoin. Can start only btc buyer
     */
    function buyForBitcoin(address _beneficiary, uint _amountWei) public returns(bool) {
        require(msg.sender == btcBuyer);

        buyTokens(_beneficiary, _amountWei);
        
        return true;
    }

    /**
     * @dev Set new address who can buy tokens for bitcoin
     */
    function setBtcBuyer(address _newBtcBuyerAddress) onlyOwner returns(bool) {
        require(_newBtcBuyerAddress != 0x0);

        btcBuyer = _newBtcBuyerAddress;

        return true;
    }

    /**
     * @dev Finish the crowdsale
     */
    function finalization() internal {
        super.finalization();
        token.finishMinting();

        bonusProvider.releaseThisBonuses();

        if (goalReached()) {
            ESportsToken(token).allowMoveTokens();
        }
        token.transferOwnership(owner); // change token owner
    }
}