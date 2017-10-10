pragma solidity ^0.4.16;

import "./base/ownership/Ownable.sol";
import "./base/token/MintableToken.sol";

import "./crowdsaleInterface.sol";
import "./cryptosaleInterface.sol";

contract FreezingStorage is Ownable {
	// Linked crowdsale contract
	CrowdsaleInterface public crowdsale;
	// Linked cryptosale contract
	CryptosaleInterface public cryptosale;

	address public holderWallet;

	// Constructor function
	function FreezingStorage(address _holderWallet) {
		require(_holderWallet != address(0));

		holderWallet = _holderWallet;
	}

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

	// Sending tokens to wallet's holder if all conditions are reached
	function release() public {
		require(crowdsale.hasEnded());
		require(crowdsale.goalReached());
        require(cryptosale.isFinalized());

        MintableToken token = MintableToken(crowdsale.token());
        uint tokenAmount = token.balanceOf(this);
        require(tokenAmount > 0);

        token.transfer(holderWallet, tokenAmount);
    }
}