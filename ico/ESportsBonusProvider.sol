pragma solidity ^0.4.16;

import "./zeppelin/ownership/Ownable.sol";
import './zeppelin/math/SafeMath.sol';

import "./ESportsConstants.sol";
import "./ESportsToken.sol";

contract ESportsBonusProviderI is Ownable {
    ESportsToken public token;
    address public returnAddressBonuses;

    function getBonusAmount(
        address _buyer, 
        uint _totalSold,
        uint _amountTokens,
        uint32 _startTime
    ) onlyOwner public constant returns (uint);

    function addDelayedBonus(
        address _buyer, 
        uint _totalSold,
        uint _amountTokens
    ) onlyOwner public returns (uint);

    function releaseBonus(address _buyer, uint _totalSold) onlyOwner public returns (uint);

    function sendBonus(address _buyer, uint _amountBonusTokens) onlyOwner public {
        require(token.transfer(_buyer, _amountBonusTokens));
    }
    
    function releaseThisBonuses() onlyOwner public returns (uint) {
        uint remainBonusTokens = token.balanceOf(this); // send all remaining bonuses
        require(token.transfer(returnAddressBonuses, remainBonusTokens));
    }
}

contract ESportsBonusProvider is usingESportsConstants, ESportsBonusProviderI {
    // 1) 10% on your investment during first week
    // 2) 10% to all investors during ICO ( not presale) if we reach 5 000 000 euro investments
    // 3) 5% on the investments with the referal link

    using SafeMath for uint;

    mapping (address => uint256) investorBonuses;
    uint constant FIRST_WEEK = 7 * 1 days;
    uint constant BONUS_THRESHOLD_ETR = 20000 * RATE * TOKEN_DECIMAL_MULTIPLIER; // 5 000 000 EUR -> 20 000 ETH -> ETR

    function ESportsBonusProvider(ESportsToken _token, address _returnAddressBonuses) {
        token = _token;
        returnAddressBonuses = _returnAddressBonuses;
    }

    function getBonusAmount(
        address _buyer,
        uint _totalSold,
        uint _amountTokens,
        uint32 _startTime
    ) onlyOwner public constant returns (uint) {
        uint bonus = 0;
        
        // apply bonus for amount
        if (now < _startTime + FIRST_WEEK) {
            bonus = bonus.add(_amountTokens.div(10)); // 1
        }

        return bonus;
    }

    function addDelayedBonus(
        address _buyer,
        uint _totalSold,
        uint _amountTokens
    ) onlyOwner public returns (uint) {
        uint bonus = 0;

        if (_totalSold < BONUS_THRESHOLD_ETR) {
            uint amountThresholdBonus = _amountTokens.div(10); // 2
            investorBonuses[_buyer] = investorBonuses[_buyer].add(amountThresholdBonus); 
            bonus = bonus.add(amountThresholdBonus);
        }

        return bonus;
    }

    function releaseBonus(address _buyer, uint _totalSold) onlyOwner public returns (uint) {
        require(_totalSold >= BONUS_THRESHOLD_ETR);
        require(investorBonuses[_buyer] > 0);

        uint amountBonusTokens = investorBonuses[_buyer];
        investorBonuses[_buyer] = 0;
        require(token.transfer(_buyer, amountBonusTokens));

        return amountBonusTokens;
    }

    function getDelayedBonusAmount(address _buyer) constant returns(uint) {
        return investorBonuses[_buyer];
    }
}