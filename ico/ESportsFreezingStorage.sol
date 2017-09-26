pragma solidity ^0.4.16;

// import './zeppelin/token/ERC20Basic.sol';

import "./ESportsToken.sol";

contract ESportsFreezingStorage {
	// timestamp when token release is enabled
    uint64 public releaseTime;

	// ERC20 basic token contract being held
    ESportsToken token;
    // ERC20Basic token;

    function ESportsFreezingStorage(ESportsToken _token, uint64 _releaseTime) { //ERC20Basic
        require(_releaseTime > now);
   		
        releaseTime = _releaseTime;
        token = _token;
    }

    function release(address _beneficiary) returns(uint) { //onlyOwner
        //require(now >= releaseTime);
        if (now < releaseTime) return 0;

        uint amount = token.balanceOf(this);
        //require(amount > 0);
        if (amount == 0)  return 0;

        // token.safeTransfer(beneficiary, amount);
        bool result = token.transfer(_beneficiary, amount);
        if (!result) return 0;
        
        return amount;
    }
}