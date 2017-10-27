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

    // Kovan test addresses. This addresses must be changed before deployment to mainnet
    address constant TEAM_BEN_ADDRESS = 0x000b341E1774b02D77a1175971BC50b841D21eD0; //0x14723a09acff6d2a60dcdf7aa4aff308fddc160c
    address constant TEAM_PHIL_ADDRESS = 0x004C05E2c37a73233B63d09c52C4f68AFDfb1763; //0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db
    address constant INVESTOR_ADDRESS = 0x00657a4639f55083524242540ED3B0bdA534f69B; //0x583031d1113ad414f02576bd6afabfb302140225
    address constant BONUS_ADDRESS = 0x0005762D49BC63F16B39aead421b2ad9Db794f2B; //0x583031d1113ad414f02576bd6afabfb302140225
    address constant COMPANY_COLD_STORAGE_ADDRESS = 0x0019d9b0BF58beA7b5aFB6977Af87243650bBcC4; //0xdd870fa1b7c4700f2bd7f44238821c26f7392148
    address constant PRE_SALE_ADDRESS = 0x00F1Eb3e6009De9460DcBaE5b2496a40c2DBE576; //0x583031d1113ad414f02576bd6afabfb302140225
    
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