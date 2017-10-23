pragma solidity 0.4.15;

import './Base.sol';

contract FinalRaffle is BaseRaffle {
  uint8 public partOfJackpot = 50;

  address[] public tickets;

  struct Category {
    uint8 partOfFund;
    uint8 percent;
    uint8 divider;
  }

  Category public categoryA = Category({
    partOfFund: 30,
    divider: 10,
    percent: 5
  });

  Category public categoryB = Category({
    partOfFund: 20,
    divider: 1,
    percent: 3
  });

  function FinalRaffle(address _ticketAddress) BaseRaffle(_ticketAddress)  {}

  /*
  * payable methods
  */

  function () payable {}

  /*
  * owner methods
  */

  function stop() onlyOwner isNotStopped {
    isStopped = true;
    playedFund = this.balance;
  }

  function addPlayer(address player) onlyOwner {
    tickets.push(player);
  }

  /*
  * constants
  */

  function getPlayer(uint256 index) constant returns (address) {
    return tickets[index];
  }

  function getNumberOfTickets() constant returns (uint256) {
    return tickets.length;
  }

  function getPlayerBy(uint256 index) constant returns (address) {
    return tickets[index];
  }

  function jackpot() constant returns (uint256) {
    uint256 categoryASum = getCategoryAWinning().mul(getCategoryACount());
    uint256 categoryBSum = getCategoryBWinning().mul(getCategoryBCount());

    return playedFund.sub(categoryASum.add(categoryBSum));
  }

  function getCategoryAWinning() constant returns (uint256) {
    return getCategoryWinning(getCategoryACount(), categoryA.partOfFund);
  }

  function getCategoryACount() constant returns (uint256) {
    return getPlayersCountBy(categoryA.percent, categoryA.divider);
  }

  function getCategoryBWinning() constant returns (uint256) {
    return getCategoryWinning(getCategoryBCount(), categoryB.partOfFund);
  }

  function getCategoryBCount() constant returns (uint256) {
    return getPlayersCountBy(categoryB.percent, categoryB.divider);
  }

  function getCategoryWinning(uint256 count, uint8 partOfFund) constant returns (uint256) {
    if (count <= 0) return 0;
    return roundUpToTicketPrice((playedFund.mul(partOfFund).div(100)).div(count));
  }

  function getWinningAmount(uint256 place) constant returns (uint256) {
    uint256 categoryACount = getCategoryACount();
    uint256 categoryBCount = getCategoryBCount();

    if (!isStopped || place > categoryACount + categoryBCount) {
      return 0;
    }

    if (place == 0) {
      return jackpot();
    } else if (place <= categoryACount) {
      return getCategoryAWinning();
    } else {
      return getCategoryBWinning();
    }
  }
}
