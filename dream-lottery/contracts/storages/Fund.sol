pragma solidity 0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import './../utils/Restriction.sol';
import './../DreamConstants.sol';

contract Fund is Restriction, DreamConstants {
    using SafeMath for uint256;

    mapping(address => uint) public balances;
    // how many funds are collected
    uint public totalAmount;
    // how many funds are payed as prize
    uint internal totalPrizeAmount;
    // absolute refund date
    uint32 internal refundDate;

    function Fund(uint _absoluteRefundDate) public {
        refundDate = uint32(_absoluteRefundDate);
    }

    function deposit(address _addr) public payable restricted {
        uint balance = balances[_addr];

        balances[_addr] = balance.add(msg.value);
        totalAmount = totalAmount.add(msg.value);
    }

    function withdraw() public restricted {
        msg.sender.transfer(this.balance);
    }

    function payPrize(address _addr, uint _amountWei) public restricted {
        // we have enough funds
        require(this.balance >= _amountWei);
        // user has balance, but prize must be grate than or equals
        require(balances[_addr] != 0 && balances[_addr] <= _amountWei);
        // drop user balance (no refund more)
        delete balances[_addr];
        // summarize total prize
        totalPrizeAmount = totalPrizeAmount.add(_amountWei);
        // send funds
        _addr.transfer(_amountWei);
    }

    /**
     * To test purposes.
     */
    function pay(address _addr, uint _amountWei) public restricted {
        // we have enough funds
        require(this.balance >= _amountWei);
        // send funds
        _addr.transfer(_amountWei);
    }

    function enableRefund() public restricted {
        require(refundDate > uint32(block.timestamp));
        refundDate = uint32(block.timestamp);
    }

    function refund() public {
        refund(msg.sender);
    }

    function refund(address _addr) public restricted {
        require(refundDate >= uint32(block.timestamp));
        require(balances[_addr] != 0);
        uint refund = refundAmount(_addr);
        balances[_addr] = 0;
        _addr.transfer(refund);
    }

    function refundAmount(address _addr) public constant returns (uint) {
        uint balance = balances[_addr];
        uint restTotal = totalAmount.add(totalPrizeAmount);
        uint share = balance.mul(ACCURACY).div(totalAmount);
        return restTotal.mul(share).div(ACCURACY);
    }
}
