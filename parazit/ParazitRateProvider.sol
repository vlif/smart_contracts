pragma solidity ^0.4.16;

// import './zeppelin/ownership/Ownable.sol';
import './zeppelin/math/SafeMath.sol';

import './ParazitConstants.sol';

contract ParazitRateProviderI {
    /**
     * @dev Calculate actual rate using the specified parameters.
     * @param buyer     Investor (buyer) address.
     * @param totalSold Amount of sold tokens.
     * @return ETH to Token rate.
     */
    function getRate(address buyer, uint totalSold) public constant returns (uint);
}

contract ParazitRateProvider is usingParazitConstants {
    using SafeMath for uint;

    uint constant BASE_RATE = 1;
    uint constant PRE_SALE_STEP = 5000000 * TOKEN_DECIMAL_MULTIPLIER;
    
    function getRate(address buyer, uint totalSold) public constant returns (uint) {
        uint rate = BASE_RATE;

        if (totalSold < PRE_SALE_STEP) {
            rate += rate.mul(30).div(100); // + 30 %
        }

        return rate;
    }
}