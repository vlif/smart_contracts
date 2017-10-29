pragma solidity ^0.4.16;

// import './zeppelin/ownership/Ownable.sol';
import './zeppelin/math/SafeMath.sol';

import './ParazitConstants.sol';

contract ParazitMainRateProviderI {
    // Calculate actual rate using the specified parameters
    // Return ETH to Token rate
    function getRate() public constant returns (uint);

    // Rate scale (or divider), to support not integer rates
    // Return Rate divider
    function getRateScale() public constant returns (uint);
}

// Contract for rate calculation
contract ParazitMainRateProvider is ParazitConstants, ParazitMainRateProviderI {
    using SafeMath for uint;

    // Rate calculate accuracy
    uint constant RATE_SCALE = 1000000;
    uint constant BASE_RATE = 2824858757; //* RATE_SCALE // 0.000354 eth = 1 Gpcc -> 2824,8587570621468926553672316384
    
    function getRate() public constant returns (uint) {
        uint rate = BASE_RATE;

        rate += rate.mul(20).div(100); // +20 %

        return rate;
    }

    function getRateScale() public constant returns (uint) {
        return RATE_SCALE;
    }
}