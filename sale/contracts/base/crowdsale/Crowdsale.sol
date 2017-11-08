pragma solidity ^0.4.11;

import '../token/MintableToken.sol';
import '../math/SafeMath.sol';

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract Crowdsale {
    using SafeMath for uint256;

    // The token being sold
    MintableToken public token;

    // start and end timestamps where investments are allowed (both inclusive)
    uint256 public startTime;
    uint256 public endTime;

    // address where funds are collected
    address public wallet;

    // how many token units a buyer gets per wei
    uint256 public rate;

    // amount of raised money in wei
    uint256 public weiRaised;

    /**
     * @dev Amount of already sold tokens.
     */
    // uint public soldTokens;

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
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, uint _hardCap, address _wallet, address _token) {
        require(_startTime >= now);
        require(_endTime >= _startTime);
        require(_rate > 0);
        require(_wallet != 0x0);
        // require(_hardCap > _rate);

        // token = createTokenContract();
        token = MintableToken(_token);

        startTime = _startTime;
        endTime = _endTime;
        rate = _rate;
        hardCap = _hardCap;
        wallet = _wallet;
    }

    // creates the token to be sold.
    // override this method to have crowdsale of a specific mintable token.
    // function createTokenContract() internal returns (MintableToken) {
    //     return new MintableToken();
    // }

    // fallback function can be used to buy tokens
    function () payable {
        buyTokens(msg.sender, msg.value);
    }

    /**
     * @dev this method might be overridden for implementing any sale logic.
     * @return Actual rate.
     */
    function getRate() internal constant returns (uint) { //uint amountWei
        return rate;
    }

    // low level token purchase function
    function buyTokens(address beneficiary, uint amountWei) internal { //public payable
        require(beneficiary != 0x0);

        // total minted tokens
        uint totalSupply = token.totalSupply();

        uint actualRate = getRate(); //amountWei
        // uint rateScale = getRateScale();

        require(validPurchase(amountWei, actualRate, totalSupply));

        // calculate token amount to be created
        // uint tokens = amountWei.mul(actualRate).div(rateScale);
        uint256 tokens = amountWei.mul(actualRate);


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
        // soldTokens = soldTokens.add(tokens);

        token.mint(beneficiary, tokens);
        TokenPurchase(beneficiary, beneficiary, amountWei, tokens);


        if (change != 0) {
            msg.sender.transfer(change);
        }

        
        forwardFunds(beneficiary, amountWei);
    }

    // send ether to the fund collection wallet
    // override to create custom fund forwarding mechanisms
    function forwardFunds(address beneficiary, uint amountWei) internal {
        wallet.transfer(msg.value);
    }

    // @return true if the transaction can buy tokens
    function validPurchase(uint _amountWei, uint _actualRate, uint _totalSupply) internal constant returns (bool) {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = _amountWei != 0;
        bool hardCapNotReached = _totalSupply <= hardCap.sub(_actualRate);

        return withinPeriod && nonZeroPurchase && hardCapNotReached;
    }

    // @return true if crowdsale event has ended
    function hasEnded() public constant returns (bool) {
        return now > endTime || token.totalSupply() > hardCap.sub(rate);
    }

    /**
     * @return true if crowdsale event has started
     */
    function hasStarted() public constant returns (bool) {
        return now >= startTime;
    }

    /**
     * @dev Check this crowdsale event has ended considering with amount to buy.
     * @param _value Amount to spend.
     * @return true if crowdsale event has ended
     */
    // function hasEnded(uint _value) public constant returns (bool) {
    //     uint actualRate = getRate(); //_value
    //     return now > endTime || token.totalSupply() > hardCap.sub(actualRate);
    // }
}