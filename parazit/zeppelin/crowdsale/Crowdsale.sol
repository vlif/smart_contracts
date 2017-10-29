pragma solidity ^0.4.11;

import '../token/MintableToken.sol';
import '../math/SafeMath.sol';

/**
 * @title Crowdsale 
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 *
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet 
 * as they arrive.
 */
contract Crowdsale {
    using SafeMath for uint;

    // The token being sold
    MintableToken public token;

    // start and end timestamps where investments are allowed (both inclusive)
    uint32 public startTime;
    uint32 public endTime;

    // address where funds are collected
    address public wallet;

    // amount of raised money in wei
    uint public weiRaised;

    /**
     * @dev Amount of already sold tokens.
     */
    uint public soldTokens;

    /**
     * @dev Maximum amount of tokens to mint.
     */
    uint public hardCap;

    /**
     * event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint value, uint amount);

    function Crowdsale(uint32 _startTime, uint32 _endTime, uint _hardCap, address _wallet) {
        require(_startTime >= now);
        require(_endTime >= _startTime);
        require(_wallet != 0x0);
        require(_hardCap > 0); //_rate

        token = createTokenContract();

        startTime = _startTime;
        endTime = _endTime;
        hardCap = _hardCap;
        wallet = _wallet;
    }

    // creates the token to be sold.
    // override this method to have crowdsale of a specific mintable token.
    function createTokenContract() internal returns (MintableToken) {
        return new MintableToken();
    }

    /**
     * @dev this method might be overridden for implementing any sale logic.
     * @return Actual rate.
     */
    function getRate() internal constant returns (uint);

    // Fallback function can be used to buy tokens
    function() payable {
        buyTokens(msg.sender, msg.value);
    }

    // Low level token purchase function
    function buyTokens(address beneficiary, uint amountWei) internal {
        require(beneficiary != 0x0);

        // total minted tokens
        uint totalSupply = token.totalSupply();

        // actual token minting rate (with considering bonuses and discounts)
        uint actualRate = getRate();

        require(validPurchase(amountWei, actualRate, totalSupply));

        // calculate token amount to be created
        uint tokens = amountWei.mul(actualRate);


        // change, if minted token would be less
        uint change = 0;

        // if hard cap reached
        if (tokens.add(totalSupply) > hardCap) {
            // rest tokens
            uint maxTokens = hardCap.sub(totalSupply);
            uint realAmount = maxTokens.div(actualRate);

            // rest tokens rounded by actualRate
            tokens = realAmount.mul(actualRate);
            change = amountWei - realAmount;
            amountWei = realAmount;
        }


        // update state
        weiRaised = weiRaised.add(amountWei);
        soldTokens = soldTokens.add(tokens);

        token.mint(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, amountWei, tokens);

        if (change != 0) {
            msg.sender.transfer(change);
        }
        forwardFunds(amountWei);
    }

    // Send ether to the fund collection wallet
    // Override to create custom fund forwarding mechanisms
    function forwardFunds(uint amountWei) internal {
        wallet.transfer(amountWei);
    }

    /**
     * @dev Check if the specified purchase is valid.
     * @return true if the transaction can buy tokens
     */
    function validPurchase(uint _amountWei, uint _actualRate, uint _totalSupply) internal constant returns (bool) {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = _amountWei != 0;
        bool hardCapNotReached = _totalSupply <= hardCap.sub(_actualRate);

        return withinPeriod && nonZeroPurchase && hardCapNotReached;
    }

    /**
     * @dev Because of discount hasEnded might be true, but validPurchase returns false.
     * @return true if crowdsale event has ended
     */
    function hasEnded() public constant returns (bool) {
        return now > endTime || token.totalSupply() > hardCap.sub(getRate());
    }

    /**
     * @return true if crowdsale event has started
     */
    function hasStarted() public constant returns (bool) {
        return now >= startTime;
    }
}