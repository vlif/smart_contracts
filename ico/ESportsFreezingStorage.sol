pragma solidity ^0.4.16;

contract ESportsFreezingStorage {
	// timestamp when token release is enabled
    uint64 public releaseTime;

    function ESportsFreezingStorage(uint64 _releaseTime) {
        require(_releaseTime > now);
   		
        releaseTime = _releaseTime;
    }
}
