pragma solidity 0.4.15;

import '../zeppelin-solidity/contracts/ownership/Ownable.sol';

contract Accesses is Ownable {
  mapping (address => bool) internal accesses;

  function addAccess(address _address) onlyOwner {
    accesses[_address] = true;
  }

  function isHaveAccess(address account) constant returns (bool) {
    return msg.sender == owner || accesses[account];
  }

  modifier checkAccess() {
    require(isHaveAccess(msg.sender));
    _;
  }
}
