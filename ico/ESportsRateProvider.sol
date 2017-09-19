pragma solidity ^0.4.16;

import "./zeppelin/ownership/Ownable.sol";

import "./ESportsConstants.sol";

contract ESportsRateProviderI {
    /**
     * @dev Calculate actual rate using the specified parameters.
     * @param buyer     Investor (buyer) address.
     * @param totalSold Amount of sold tokens.
     * @param amountWei Amount of wei to purchase.
     * @return ETH to Token rate.
     */
    function getRate(
        address buyer, 
        uint totalSold, 
        uint amountWei, 
        uint32 crowdsaleStartTime
    ) public constant returns (uint);

    /**
     * @dev rate scale (or divider), to support not integer rates.
     * @return Rate divider.
     */
    function getRateScale() public constant returns (uint);
}

contract ESportsRateProvider is usingESportsConstants, ESportsRateProviderI, Ownable {
    // rate calculate accuracy
    uint constant RATE_SCALE = 10000;
    uint constant BASE_RATE = 1500 * RATE_SCALE;
    uint firstWeek = 7;

    function getRateScale() public constant returns (uint) {
        return RATE_SCALE;
    }

    function getRate(
        address buyer, 
        uint totalSold, 
        uint amountWei, 
        uint32 startTime //crowdsaleStartTime
    ) public constant returns (uint) {
        uint rate;

        rate = BASE_RATE;

        // apply bonus for amount
        // if (now < startTime + firstWeek * 1 days) {
        //     rate += rate * 10 / 100; // + 10%
        // }
        
        return rate;
    }
}
