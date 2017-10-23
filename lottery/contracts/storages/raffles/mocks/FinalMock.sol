pragma solidity 0.4.15;

import './../Final.sol';

contract FinalRaffleMock is FinalRaffle {
  function FinalRaffleMock(address _ticketAddress) FinalRaffle(_ticketAddress) {}

  function getNumberOfTickets() onlyOwner constant returns (uint256) {
    return 1000;
  }
}
