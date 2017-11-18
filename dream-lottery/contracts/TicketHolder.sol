pragma solidity 0.4.18;


import './utils/Restriction.sol';
import './DreamConstants.sol';


contract TicketHolder is Restriction, DreamConstants {
    event SaleFinished();

    struct Ticket {
        uint32 ticketAmount;
        uint32 playerIndex;
        uint dreamAmount;
    }

    uint64 public totalTickets;

    mapping (address => Ticket) internal tickets;

    address[] internal players;

    /**
     * @dev Issue tickets for the specified address.
     * @param _addr Receiver address.
     * @param _ticketAmount Amount of tickets to issue.
     * @param _dreamAmount Amount of dream or zero, if use previous.
     */
    function issueTickets(address _addr, uint _ticketAmount, uint _dreamAmount) public restricted {
        assert(_ticketAmount <= MAX_TICKETS);
        Ticket storage ticket = tickets[_addr];

        // if fist issue for this user
        if (ticket.ticketAmount == 0) {
            require(_dreamAmount >= MINIMAL_DREAM);
            ticket.playerIndex = uint32(players.length);
            players.push(_addr);
        }

        // add new ticket amount
        ticket.ticketAmount += uint32(_ticketAmount);
        // check to overflow
        require(ticket.ticketAmount >= _ticketAmount);

        // cal total
        totalTickets += uint64(_ticketAmount);

        // replace dream if new dream is not empty
        if (_dreamAmount != 0) {
            ticket.dreamAmount = _dreamAmount;
        }
    }

    function setWinner(address _addr) public restricted {
        Ticket storage ticket = tickets[_addr];
        require(ticket.ticketAmount != 0);
        ticket.ticketAmount = 0;
    }

    function getTickets(uint index) public constant returns (address addr, uint ticketAmount, uint dreamAmount) {
        if (players.length == 0) {
            return;
        }
        if (index > players.length - 1) {
            return;
        }

        addr = players[index];
        Ticket storage ticket = tickets[addr];
        ticketAmount = ticket.ticketAmount;
        dreamAmount = ticket.dreamAmount;
    }

    function getPlayersCount() public constant returns (uint) {
        return players.length;
    }
}
