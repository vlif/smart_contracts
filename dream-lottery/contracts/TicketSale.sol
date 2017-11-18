pragma solidity 0.4.18;


import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import './utils/Restriction.sol';
import './DreamConstants.sol';
import './TicketHolder.sol';
import './storages/Fund.sol';

contract TicketSale is Restriction, DreamConstants {
    using SafeMath for uint256;

    event TicketPurchase(address indexed purchaser, uint value, uint amount);

    TicketHolder public ticketHolder;
    Fund internal fund;

    uint32 internal endDate;

    function TicketSale(uint _endDate) public {
        require(_endDate > block.timestamp);
        uint refundDate = block.timestamp + REFUND_AFTER;
        // end date mist be less then refund
        require(_endDate < refundDate);

        ticketHolder = new TicketHolder();
        ticketHolder.giveAccess(msg.sender);

        fund = new Fund(refundDate);
        fund.giveAccess(msg.sender);

        endDate = uint32(_endDate);
    }

    // fallback function used to buy tickets
    function() public payable notEnded {
        uint dreamWei = 0;
        if (msg.data.length != 0) {
            uint dreamEth = parseDream();
            dreamWei = dreamEth * 1 ether;
        }
        buyTicketsInternal(msg.sender, msg.value, dreamWei);
    }

    function buyTickets(uint _dreamAmount) public payable notEnded {
        buyTicketsInternal(msg.sender, msg.value, _dreamAmount);
    }

    function buyTicketsInternal(address _addr, uint _valueWei, uint _dreamAmount) internal {
        require(_valueWei >= TICKET_PRICE);

        uint change = _valueWei % TICKET_PRICE;
        uint weiAmount = _valueWei - change;
        uint ticketCount = weiAmount.div(TICKET_PRICE);

        // issue right amount of tickets
        ticketHolder.issueTickets(_addr, ticketCount, _dreamAmount);

        // transfer to fund
        fund.deposit.value(weiAmount)(_addr);

        // return change
        if (change != 0) {
            msg.sender.transfer(change);
        }
    }

    /**
     * @dev Refund proxy method. Player can refund by this method.
     */
    function refund() public {
        fund.refund(msg.sender);
    }


    // server integration methods
    /**
     * @dev Set winner by index. It will get dream prize.
     * @param _playerIndex The winner player index.
     */
    function setWinner(uint _playerIndex) public restricted ended {
        address playerAddress;
        uint ticketAmount;
        uint dreamAmount;
        (playerAddress, ticketAmount, dreamAmount) = ticketHolder.getTickets(_playerIndex);
        require(playerAddress != 0);

        // check that player has tickets and drop it
        ticketHolder.setWinner(playerAddress);

        // pay the player's dream
        fund.payPrize(playerAddress, dreamAmount);
    }

    /**
     * @dev Send funds to player by index. In case server calculate all.
     * @param _playerIndex The winner player index.
     * @param _amountWei Amount of prize in wei.
     */
    function payPrize(uint _playerIndex, uint _amountWei) public restricted {
        address playerAddress;
        uint ticketAmount;
        uint dreamAmount;
        (playerAddress, ticketAmount, dreamAmount) = ticketHolder.getTickets(_playerIndex);
        require(playerAddress != 0);

        // pay the player's dream
        fund.pay(playerAddress, _amountWei);
    }

    /**
     * @dev Server method. Finish lottery (force finish if required), enable refund.
     */
    function finish() public restricted {
        // force end
        if (endDate > uint32(block.timestamp)) {
            endDate = uint32(block.timestamp);
        }

        fund.enableRefund();
    }

    // constant methods
    function isEnded() public constant returns (bool) {
        return block.timestamp > endDate;
    }

    function parseDream() public constant returns (uint result) {
        for (uint i = 0; i < msg.data.length; i ++) {
            uint power = (msg.data.length - i - 1) * 2;
            uint b = uint(msg.data[i]);
            result += b / 16 * (10 ** (power + 1)) + b % 16 * (10 ** power);
        }
    }

    modifier notEnded() {
        require(!isEnded());
        _;
    }

    modifier ended() {
        require(isEnded());
        _;
    }
}
