pragma solidity ^0.4.16;

import "./base/ownership/Ownable.sol";
import "./crowdsale.sol";

/**
 * 
 */
contract Cryptosale is Ownable {
	address crowdsale;

	// function Cryptosale () {
	// }	

	// function() payable {
	// }

	function setCrowdsale(address _crowdsale) onlyOwner returns(bool) {
		require(_crowdsale != 0x0);
		crowdsale = _crowdsale;
		return true;
	}
}