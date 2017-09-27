pragma solidity ^0.4.16;

import "./zeppelin/ownership/Ownable.sol";
import './zeppelin/math/SafeMath.sol';

import "./ESportsConstants.sol";
import "./ESportsToken.sol";

contract ESportsBonusProviderI is Ownable {
    // address public bonusWallet;
    ESportsToken public token;

    function addBonus(
        address _buyer, 
        uint _totalSold,
        uint _amountTokens,
        uint32 _crowdsaleStartTime
    ) onlyOwner public constant returns (uint);

    function addDelayedBonus(
        address _buyer, 
        uint _totalSold,
        uint _amountTokens,
        uint32 _crowdsaleStartTime
    ) onlyOwner public returns (uint);

    function sendBonus(address _buyer, uint _amountBonusTokens) onlyOwner public returns (uint) {
        require(token.balanceOf(this) >= _amountBonusTokens);

        bool result = token.transfer(_buyer, _amountBonusTokens);
        if (!result) return 0;

        return _amountBonusTokens;
    }

    function releaseBonus(address _buyer, uint _totalSold) onlyOwner public returns (uint);
}

contract ESportsBonusProvider is usingESportsConstants, ESportsBonusProviderI {
    // 1) 10% on your investment during first week
    // 2) 10% to all investors during ICO ( not presale) if we reach 5 000 000 euro investments
    // 3) 5% on the investments with the referal link

    using SafeMath for uint;

    mapping (address => uint256) investorBonuses;
    uint constant FIRST_WEEK = 7 * 1 days;
    uint constant BONUS_THRESHOLD_ETR = 1 * TOKEN_DECIMAL_MULTIPLIER; // 20000 * 240 // 5 000 000 EUR -> 20 000 ETH -> ETR

    function ESportsBonusProvider(ESportsToken _token) { //address _bonusWallet
        // bonusWallet = _bonusWallet;
        token = _token;
    }

    function addBonus(
        address _buyer,
        uint _totalSold,
        uint _amountTokens,
        uint32 _startTime
    ) onlyOwner public constant returns (uint) {
        uint bonus = 0;
        
        // apply bonus for amount
        if (now < _startTime + FIRST_WEEK) {
            bonus = bonus.add(_amountTokens.mul(10).div(100)); // 1
        }

        return bonus;
    }

    function addDelayedBonus(
        address _buyer,
        uint _totalSold,
        uint _amountTokens,
        uint32 _startTime
    ) onlyOwner public returns (uint) {
        uint bonus = 0;

        if (_totalSold < BONUS_THRESHOLD_ETR) {
            uint amountThresholdBonus = _amountTokens.mul(10).div(100); // 2
            investorBonuses[_buyer] = investorBonuses[_buyer].add(amountThresholdBonus); 
            bonus = bonus.add(amountThresholdBonus);
        }

        return bonus;
    }
    
    function releaseBonus(address _buyer, uint _totalSold) onlyOwner public returns (uint) {
        require(_totalSold >= BONUS_THRESHOLD_ETR);
        require(investorBonuses[_buyer] > 0);

        uint amountBonusTokens = investorBonuses[_buyer];
        bool result = token.transfer(_buyer, amountBonusTokens);
        if (!result) return 0;
        investorBonuses[_buyer] = 0;

        return amountBonusTokens;
    }

    function getBonus(address _buyer) constant returns(uint) {
        return investorBonuses[_buyer];
    }
}