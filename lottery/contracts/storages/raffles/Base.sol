pragma solidity 0.4.15;

import '../../zeppelin-solidity/contracts/math/SafeMath.sol';
import './../../utils/Accesses.sol';
import './../Ticket.sol';

contract BaseRaffle is Accesses {
  using SafeMath for uint256;

  Ticket public ticket;

  // Raffle is finished
  bool public isFinished = false;

  // Receiving tokens is stopped
  bool public isStopped = false;

  bool public isJackpot = false;

  uint8 public partOfFund = 100;

  uint256 public playedFund;

  function BaseRaffle (address _ticketAddress) {
    ticket = Ticket(_ticketAddress);
  }

  /*
  * owner methods
  */

  function setWinner(address to, uint256 place) onlyOwner onlyIsStopped returns (uint256) {
    require(to != 0x0);
    return forwardWinning(to, place);
  }

  /*
  * internal methods
  */

  function forwardWinning(address player, uint256 place) onlyOwner internal returns (uint256) {
    uint256 winning = getWinningAmount(place);
    require(winning > 0);
    player.transfer(winning);
    return winning;
  }

  /*
  * constants
  */

  function getPlayersCountBy(uint8 percent, uint8 divider) constant returns (uint256) {
    if (divider <= 0) return 0;
    return getNumberOfTickets().mul(percent).div(divider).div(100);
  }

  function roundUpToTicketPrice (uint256 number) constant returns (uint256)  {
    return number - number % ticket.price();
  }

  function getWinningAmount(uint256) constant returns (uint256) {}

  function getNumberOfTickets() constant returns (uint256) {}

  /*
  * modifiers
  */

  modifier isNotFinished() {
    require(!isFinished);
    _;
  }

  modifier onlyIsStopped() {
    require(isStopped);
    _;
  }

  modifier isNotStopped() {
    require(!isStopped);
    _;
  }
}
