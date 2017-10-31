pragma solidity ^0.4.16;

// import './zeppelin/ownership/Ownable.sol';
import './zeppelin/math/SafeMath.sol';

import './ParazitConstants.sol';

contract ParazitPreICORateProviderI {
    // Calculate actual rate using the specified parameters
    // return ETH to Token rate
    function getRate() public constant returns (uint);

    // Rate scale (or divider), to support not integer rates
    // return Rate divider
    // function getRateScale() public constant returns (uint);
}

// Contract for rate calculation
contract ParazitPreICORateProvider is ParazitConstants, ParazitPreICORateProviderI {
    using SafeMath for uint;
    
    // Rate calculate accuracy
    // uint constant RATE_SCALE = 1000000;
    // uint constant BASE_RATE = 2824858757; //* RATE_SCALE // 0.000354 eth = 1 Gpcc -> 1 ETH == 2824,8587570621468926553672316384 GPCC
    uint constant BASE_RATE = 3000; // * RATE_SCALE

    function getRate() public constant returns (uint) {
        uint rate = BASE_RATE;

        rate += rate.mul(30).div(100); // +30 %

        return rate;
    }
    
    // function getRateScale() public constant returns (uint) {
    //     return RATE_SCALE;
    // }
}