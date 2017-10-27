pragma solidity ^0.4.16;

import "./zeppelin/ownership/Ownable.sol";
// import './zeppelin/token/ERC20Basic.sol';

import "./ESportsToken.sol";

contract ESportsFreezingStorage is Ownable {
	// Timestamp when token release is enabled
    uint64 public releaseTime;

	// ERC20 basic token contract being held
    // ERC20Basic token;
    ESportsToken token;
    
    function ESportsFreezingStorage(ESportsToken _token, uint64 _releaseTime) { //ERC20Basic
        require(_releaseTime > now);
   		
        releaseTime = _releaseTime;
        token = _token;
    }

    function release(address _beneficiary) onlyOwner returns(uint) {
        require(now >= releaseTime);

        uint amount = token.balanceOf(this);
        require(amount > 0);

        // token.safeTransfer(beneficiary, amount);
        require(token.transfer(_beneficiary, amount));
        
        return amount;
    }
}