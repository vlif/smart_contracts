pragma solidity 0.4.15;

import './../Fund.sol';
import './Base.sol';

contract RegularRaffle is BaseRaffle {
  uint8 public partOfJackpot = 35;
  uint8 public partOfFund = 65;

  Fund public fund;

  struct Category {
    uint8 percent;
    uint8 divider;
  }

  Category public categoryA = Category({ percent: 1, divider: 1 });
  Category public categoryB = Category({ percent: 4, divider: 1 });

  function RegularRaffle(address _fundAddress, address _ticketAddress) BaseRaffle(_ticketAddress) {
    fund = Fund(_fundAddress);
  }

  /*
  * payable methods
  */

  function () payable {}

  /*
  * owner methods
  */

  function stop(bool _isJackpot) onlyOwner isNotStopped {
    setJackpot(_isJackpot);
    isStopped = true;
    playedFund = this.balance;
  }

  function finish() onlyOwner onlyIsStopped isNotFinished {
    isFinished = true;
    fund.credit.value(this.balance)();
  }

  function setJackpot(bool _isJackpot) onlyOwner isNotStopped {
    isJackpot = _isJackpot;
  }

  /*
  * constants
  */

  function getPlayer(uint256 index) constant returns (address) {
    return ticket.getPlayerByRaffle(index, address(this));
  }

  function getNumberOfTickets() constant returns (uint256) {
    return ticket.getNumberPlayersByRaffle(address(this));
  }

  function fullFund() constant returns (uint256) {
    return playedFund.mul(100).div(partOfFund);
  }

  function jackpot() constant returns (uint256) {
    return fullFund().mul(partOfJackpot).div(100);
  }

  function getCategoryAWinning() constant returns (uint256) {
    uint256 winning = playedFund
      .sub(isJackpot ? jackpot() : 0)
      .sub(getCategoryBWinning().mul(getCategoryBCount()))
      .div(getCategoryACount());

    return roundUpToTicketPrice(winning);
  }

  function getCategoryACount() constant returns (uint256) {
    return getPlayersCountBy(categoryA.percent, categoryA.divider);
  }

  function getCategoryBWinning() constant returns (uint256) {
    return ticket.price().mul(isJackpot ? 2 : 3);
  }

  function getCategoryBCount() constant returns (uint256) {
    return getPlayersCountBy(categoryB.percent, categoryB.divider);
  }

  function getWinningAmount(uint256 place) constant returns (uint256) {
    uint256 categoryACount = getCategoryACount();
    uint256 categoryBCount = getCategoryBCount();

    if (!isStopped || place >= categoryACount + categoryBCount) {
      return 0;
    }

    if (isJackpot && place == 0) {
      return jackpot();
    }

    if (place < categoryACount) {
      return getCategoryAWinning();
    } else {
      return getCategoryBWinning();
    }
  }
}
