pragma solidity ^0.4.16;

import "./base/ownership/Ownable.sol";
import "./base/math/SafeMath.sol";

import "./constants.sol";

contract RateProvider is Constants, Ownable {
    using SafeMath for uint;
    
    address public tokenHolder;

    function RateProvider(address _tokenHolder) {
    	tokenHolder = _tokenHolder;
    }
    
    function getRate(
        address buyer,
        uint baseRate
    ) public constant returns (uint) {
        uint rate = baseRate;

		if (buyer == tokenHolder) {
			rate = rate.add(rate.div(10)); // + 10%
		}

        return rate;
    }
}