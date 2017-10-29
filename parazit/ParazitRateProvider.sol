pragma solidity ^0.4.16;

// import './zeppelin/ownership/Ownable.sol';
import './zeppelin/math/SafeMath.sol';

import './ParazitConstants.sol';

contract ParazitRateProviderI {
    /**
     * @dev Calculate actual rate using the specified parameters.
     * @return ETH to Token rate.
     */
    function getRate() public constant returns (uint);

    /**
     * @dev rate scale (or divider), to support not integer rates.
     * @return Rate divider.
     */
    function getRateScale() public constant returns (uint);
}

contract ParazitRateProvider is ParazitConstants, ParazitRateProviderI {
    using SafeMath for uint;

    // Rate calculate accuracy
    uint constant RATE_SCALE = 1000000;
    uint constant BASE_RATE = 2824858757; //* RATE_SCALE // 0.000354 eth = 1 Gpcc -> 2824,8587570621468926553672316384
    
    function getRate() public constant returns (uint) {
        uint rate = BASE_RATE;

        rate += rate.mul(30).div(100); // +30 %

        return rate;
    }

    function getRateScale() public constant returns (uint) {
        return RATE_SCALE;
    }
}