pragma solidity ^0.4.16;

import "./base/ownership/Ownable.sol";

contract RefundVaultCommon is Ownable {
    using SafeMath for uint256;
    
	mapping (address => uint256) public deposited;

	enum State { Active, Refunding, Withdraw }
	State public state;

	event Closed();
    event RefundsEnabled();
    event Refunded(address indexed beneficiary, uint weiAmount);

    /**
	 * Constructor function
	 */
    function RefundVaultCommon() {
    	state = State.Active;
    }

    function deposit(address _investor) onlyOwner payable {
        require(state == State.Active);

        deposited[_investor] = deposited[_investor].add(msg.value);
    }

    function close() onlyOwner public {
		require(state == State.Active);

        state = State.Withdraw;
        Closed();
	}

	function enableRefunds() onlyOwner public {
		require(state == State.Active);

        state = State.Refunding;
        RefundsEnabled();
	}

	function claimRefund(address _investor) onlyOwner {
        require(state == State.Refunding);
        uint depositedValue = deposited[_investor];
        require(depositedValue > 0);

        deposited[_investor] = 0;
        _investor.transfer(depositedValue); // refund investor
        Refunded(_investor, depositedValue);
    }
}