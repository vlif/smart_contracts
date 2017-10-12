pragma solidity ^0.4.16;

// Abstract cryptosale interface contract
contract CryptosaleInterface {
	bool public isFinalized;
	// minimum amount of funds to be raised in weis
    uint public goal;
    // amount of raised money in wei
    uint public weiRaised;
    
    function goalReached() public constant returns (bool);
}