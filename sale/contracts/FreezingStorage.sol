pragma solidity ^0.4.16;

import "./base/ownership/Ownable.sol";
import "./base/token/MintableToken.sol";
import "./base/math/SafeMath.sol";

import "./CrowdsaleInterface.sol";
import "./CryptosaleInterface.sol";

contract FreezingStorage is Ownable {
	using SafeMath for uint256;

	// Linked crowdsale contract
	CrowdsaleInterface public crowdsale;
	// Linked cryptosale contract
	CryptosaleInterface public cryptosale;

	address public forwardWallet;
	address public backwordWallet;

	// Constructor function
	function FreezingStorage(address _forwardWallet, address _backwordWallet) {
		require(_forwardWallet != address(0) && _backwordWallet != address(0));

		forwardWallet = _forwardWallet;
		backwordWallet = _backwordWallet;
	}

	/**
     * public methods
     */

	// Sending tokens to forwardWallet and backwordWallet
	function release() public returns(bool) {
		require(cryptosale.isFinalized());

        MintableToken token = MintableToken(crowdsale.token());
    	uint tokenAmount = token.balanceOf(this);
        require(tokenAmount > 0);
        
        if (cryptosale.goalReached() && crowdsale.goalReached()) {
        	token.transfer(forwardWallet, tokenAmount);
    	} else {
    		if (!cryptosale.goalReached() && crowdsale.goalReached()) {
    			// uint realHonoredTokenAmount = (tokenAmount * (cryptosale.weiRaised() * 100 / cryptosale.goal())) / 100;
    			uint k =  100 - (100 - (cryptosale.weiRaised() * 100 / cryptosale.goal())) / 2;
    			uint realHonoredTokenAmount = cryptosale.weiRaised() * k / 100; //tokenAmount
				
    			token.transfer(forwardWallet, realHonoredTokenAmount);
    			token.transfer(backwordWallet, tokenAmount.sub(realHonoredTokenAmount));
			} else {
				token.transfer(backwordWallet, tokenAmount);
			}
    	}
    	
    	return true;
    }

    /**
     * only owner methods
     */

	// Setting crowdsale contract. Can set crowdsale once
	function setCrowdsale(address _crowdsale) onlyOwner public {
		require(_crowdsale != 0x0 && crowdsale == address(0));

		crowdsale = CrowdsaleInterface(_crowdsale);
	}

	// Setting cryptosale contract. Can set cryptosale once
	function setCryptosale(address _cryptosale) onlyOwner public {
		require(_cryptosale != 0x0 && cryptosale == address(0));

		cryptosale = CryptosaleInterface(_cryptosale);
	}
}