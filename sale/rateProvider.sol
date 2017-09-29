pragma solidity ^0.4.16;

import "./base/ownership/Ownable.sol";
import './base/math/SafeMath.sol';
import "./constants.sol";

// contract RateProviderI {
// }

contract RateProvider is usingConstants, Ownable { //RateProviderI
    using SafeMath for uint;

    address cryptosale;

    function RateProvider(address _cryptosaleContractAddress) { //RateProviderI(_cryptosaleContractAddress)
    	cryptosale = _cryptosaleContractAddress;	
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

		if (_buyer == cryptosale) {
			rate = rate.add(rate.mul(100).div(100)); // +10%
		}

        return rate;
    }
}