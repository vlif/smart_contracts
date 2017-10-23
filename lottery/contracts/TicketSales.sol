pragma solidity 0.4.15;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import './storages/Ticket.sol';
import './storages/Fund.sol';

contract TicketSales {
  using SafeMath for uint256;

  event TicketPurchase(address indexed purchaser, uint256 value, uint256 amount);

  uint256 public ownerCommissionsPercent = 20;

  uint256 public regularFundPercent = 40;
  uint256 public instantFundPercent = 30;
  uint256 public finalFundPercent = 10;

  Fund internal regularFund;
  Fund internal finalFund;

  Ticket internal ticket;

  address public owner;

  function TicketSales(address regularFundAddress, address finalFundAddress, address ticketAddress) {
    regularFund = Fund(regularFundAddress);
    finalFund = Fund(finalFundAddress);
    ticket = Ticket(ticketAddress);
    owner = msg.sender;
  }

  // fallback function used to buy tickets
  function () payable { buyTickets(); }

  function buyTickets() payable {
    require(!ticket.isFinished());
    require(msg.value >= ticket.price());

    uint256 change = calculateChange(msg.value);
    uint256 weiAmount = msg.value - change;
    uint256 ticketsCount = weiAmount.div(ticket.price());

    forwardFunds(weiAmount, change);
    ticket.sign(msg.sender, ticketsCount);
    TicketPurchase(msg.sender, weiAmount, ticketsCount);
  }

  function forwardFunds(uint256 weiAmount, uint256 change) internal {
    owner.transfer(weiAmount.div(100).mul(ownerCommissionsPercent));
    regularFund.credit.value(weiAmount.div(100).mul(regularFundPercent))();
    finalFund.credit.value(weiAmount.div(100).mul(finalFundPercent))();

    if (change > 0) {
      msg.sender.transfer(change);
    }
  }

  function calculateChange(uint256 amount) constant returns (uint256) {
    return amount % ticket.price();
  }
}
