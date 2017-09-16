pragma solidity ^0.4.16;

interface Refundable {
    function refund(uint _numTickets) returns (bool);
}

contract FuncConcert {
    
    address owner;
    uint public ticketsAmount;
    uint constant price = 1 ether;
    mapping (address => uint) public purchasers;
    
    function FuncConcert(uint _ticketsAmount) {
        owner = msg.sender;
        ticketsAmount = _ticketsAmount;
    }
    
    function () payable {
        buyTickets(1);
    }
    
    function buyTickets(uint _amount) payable {
        if (msg.value != (_amount * price) || _amount > ticketsAmount) {
            return;
        }
        purchasers[msg.sender] += _amount;
        ticketsAmount -= _amount;
        
        if (ticketsAmount == 0) {
            selfdestruct(owner);
        }
    }
    
    function website() returns (string) {
        
    }
}

contract AbstractFuncAttack is FuncConcert(10), Refundable {

    event TicketsRefunded(address _sender, uint _tickets);
    
    function refund(uint _numTickets) returns (bool) {
        if (purchasers[msg.sender] < _numTickets) {
            return false;
        }
        msg.sender.transfer(_numTickets * price);
        purchasers[msg.sender] -= _numTickets;
        
        ticketsAmount += _numTickets;
        TicketsRefunded(msg.sender, _numTickets);
        return true;
    }
    
    function website() returns (string) {
        return "http://website.com";
    }
}