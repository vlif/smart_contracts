pragma solidity 0.4.15;

import '../zeppelin-solidity/contracts/ownership/Ownable.sol';

import './../storages/raffles/Regular.sol';
import './../storages/raffles/Final.sol';
import './../storages/Fund.sol';
import './../storages/Ticket.sol';

contract RaffleOwner is Ownable {
  event RegularRaffleWinner(address indexed player, uint256 winning);
  event RegularRaffleStarted(address indexed raffle);
  event RegularRaffleStopped(address indexed raffle, uint256 balance);
  event RegularRaffleFinished(address indexed raffle);

  event FinishRaffleWinner(address indexed player, uint256 winning);
  event FinishRaffleStared(address indexed raffle, uint256 fund);

  FinalRaffle public finalRaffle;
  Fund public finalFund;

  RegularRaffle public nextRaffle;
  RegularRaffle public raffle;
  Fund public fund;

  Ticket public ticket;

  uint8 internal maxNumberOfRaffles = 30;
  uint8 internal numberOfRaffles = 0;

  struct Raffle {
    uint start;
    uint stop;
    uint finish;
  }

  address[] public rafflesAddresses;
  mapping (address => Raffle) raffles;

  function RaffleOwner(
    address fundAddress,
    address finalFundAddress,
    address ticketAddress
  ) {
    fund = Fund(fundAddress);
    ticket = Ticket(ticketAddress);
    finalFund = Fund(finalFundAddress);
    finalRaffle = new FinalRaffle(address(ticket));
  }

  /*
  * owner methods
  */

  function createRaffle() onlyOwner raffleIsNull {
    require(address(nextRaffle) != 0x0);
    raffle = nextRaffle;
    raffles[address(raffle)].start = block.number;
    rafflesAddresses.push(address(raffle));
    RegularRaffleStarted(address(raffle));
  }

  function stopRaffle(bool isJackpot) onlyOwner {
    fund.transferFundToRaffle(address(raffle), raffle.partOfFund());
    raffle.stop(isJackpot);
    raffles[address(raffle)].stop = block.number;
    RegularRaffleStopped(address(raffle), raffle.balance);

    createNewRaffle();
  }

  function setWinner(uint256 playerIndex, uint256 place) onlyOwner {
    address player = ticket.getPlayerByRaffle(playerIndex, address(raffle));
    uint256 winning = raffle.setWinner(player, place);
    finalRaffle.addPlayer(player);
    RegularRaffleWinner(player, winning);
  }

  function finishRaffle() onlyOwner {
    raffles[address(raffle)].finish = block.number;
    raffle.finish();
    delete raffle;

    RegularRaffleFinished(address(raffle));
  }

  function finish() onlyOwner raffleIsNull {
    finalFund.transferFundToRaffle(address(finalRaffle), finalRaffle.partOfFund());
    fund.transferFundToRaffle(address(finalRaffle), finalRaffle.partOfFund());
    finalRaffle.stop();

    FinishRaffleStared(finalRaffle, finalRaffle.balance);
  }

  function setFinalWinner(uint256 playerIndex, uint256 place) onlyOwner {
    address player = finalRaffle.getPlayer(playerIndex);
    uint256 winning = finalRaffle.setWinner(player, place);
    FinishRaffleWinner(player, winning);
  }

  function createNewRaffle() onlyOwner {
    if (numberOfRaffles < 30) {
      RegularRaffle newRaffle = new RegularRaffle(address(fund), address(ticket));
      ticket.setCurrentRaffle(address(newRaffle));
      nextRaffle = newRaffle;
      numberOfRaffles++;
    } else {
      delete nextRaffle;
      ticket.finish();
    }
  }

  /*
  * constants
  */

  function rafflesAddressesCount() constant returns (uint) {
    return rafflesAddresses.length;
  }

  function getRaffleBy(address addressRaffle) constant returns (uint startBlock, uint stopBlock, uint finishBlock) {
    startBlock = raffles[addressRaffle].start;
    stopBlock = raffles[addressRaffle].stop;
    finishBlock = raffles[addressRaffle].finish;
  }

  /*
  * modifiers
  */

  modifier raffleIsNull() {
    require(address(raffle) == 0x0);
    _;
  }
}
