pragma solidity ^0.4.16;

import "./zeppelin/ownership/Ownable.sol";
import './zeppelin/math/SafeMath.sol';

import "./ESportsConstants.sol";
import "./ESportsToken.sol";

contract ESportsBonusProviderI is Ownable {
    mapping (address => uint256) investor_bonuses;
    address bonusWallet;
    ESportsToken token;

    function addBonus(
        address _buyer, 
        uint _totalSold,
        uint _amountTokens,
        uint32 _crowdsaleStartTime
    ) onlyOwner public returns (uint); //constant

    function getBonus(address _buyer, uint _totalSold) onlyOwner public returns (uint);
}

contract ESportsBonusProvider is usingESportsConstants, ESportsBonusProviderI {
    // 1) 10% on your investment during first week
    // 2) 10% to all investors during ICO ( not presale) if we reach 5 000 000 euro investments


    using SafeMath for uint;

    uint constant FIRST_WEEK = 7;
    // 20000 * 240
    uint constant BONUS_THRESHOLD_ETR = 1 * TOKEN_DECIMAL_MULTIPLIER; // 5 000 000 EUR -> 20 000 ETH -> ETR

    function ESportsBonusProvider(address _bonusWallet, ESportsToken _token) {
        bonusWallet = _bonusWallet;
        token = _token;
    }

    function addBonus(
        address _buyer,
        uint _totalSold,
        uint _amountTokens,
        uint32 _startTime //crowdsaleStartTime
    ) onlyOwner public returns (uint) { //constant
        uint bonus = 0;
        
        // apply bonus for amount
        if (now < _startTime + FIRST_WEEK * 1 days) {
            bonus += bonus.add(_amountTokens.mul(10).div(100)); // 1
        }
        
        if (_totalSold < BONUS_THRESHOLD_ETR) {
            investor_bonuses[_buyer] = investor_bonuses[_buyer].add(bonus);
        }

        return bonus;
    }

    function getBonus(address _buyer, uint _totalSold) onlyOwner public returns (uint) {
        require(_totalSold >= BONUS_THRESHOLD_ETR);
        require(investor_bonuses[_buyer] > 0);

        bool result = token.transfer(_buyer, investor_bonuses[_buyer]);
        if (!result) return 0;

        return investor_bonuses[_buyer];
    }
}