pragma solidity 0.4.15;

import '../utils/Accesses.sol';

contract Ticket is Accesses {
  mapping (address => address[]) raffles;

  uint256 public price = 0.1 ether;
  address public raffle = 0x0;
  bool public isFinished;

  event SaleFinished();

  function setCurrentRaffle(address raffleAddress) checkAccess isNotFinished {
    raffle = raffleAddress;
  }

  function sign(address player, uint256 amount) checkAccess isNotFinished {
    require(raffle != 0x0);
    require(amount <= 100);

    for (uint i = 0; i < amount; i++) {
      raffles[raffle].push(player);
    }
  }

  function finish() checkAccess isNotFinished {
    isFinished = true;
    delete raffle;
    SaleFinished();
  }

  /*
  * constants
  */

  function getNumberPlayersByRaffle(address raffleAddress) constant returns (uint256) {
    return raffles[raffleAddress].length;
  }

  function getPlayerByRaffle(uint256 index, address raffleAddress) constant returns (address) {
    return raffles[raffleAddress][index];
  }

  /*
  * modifiers
  */

  modifier isNotFinished() {
    require(!isFinished);
    _;
  }
}
