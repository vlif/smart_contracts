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
        address buyer,
        uint baseRate
        // uint totalSold,
        // uint amountWei,
        // uint32 startTime
    ) public constant returns (uint) {
        uint rate = baseRate;

		if (buyer == tokenHolder) {
			rate = rate.add(rate.mul(10).div(100)); // + 10%
		}

        return rate;
    }
}