pragma solidity ^0.4.16;

import "./base/ownership/Ownable.sol";
import "./base/math/SafeMath.sol";
import "./constants.sol";

// contract RateProviderI {
// }

contract RateProvider is usingConstants, Ownable { //RateProviderI
    using SafeMath for uint;
    
    address tokenHolder;

    function RateProvider(address _tokenHolder) { //RateProviderI(_tokenHolder)
    	tokenHolder = _tokenHolder;
    }
    
    function getRate(
        address _buyer,
        uint _baseRate
        // uint _totalSold,
        // uint _amountWei,
        // uint32 _startTime
    ) public constant returns (uint) {
        uint rate;
        rate = _baseRate;

		if (_buyer == tokenHolder) {
			rate = rate.add(rate.mul(10).div(100)); // + 10%
		}

        return rate;
    }
}