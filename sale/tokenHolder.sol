pragma solidity ^0.4.16;

import "./base/ownership/Ownable.sol";
import "./base/math/SafeMath.sol";
import "./base/crowdsale/RefundVault.sol";
import "./base/token/MintableToken.sol";

import "./crowdsaleInterface.sol";
// import "./refundVaultProvider.sol";

// Second main contract (after cryptosale) is token's holder
contract TokenHolder is Ownable { //, RefundVaultProvider
	using SafeMath for uint256;

	event Refunded(address indexed beneficiary, uint weiAmount);

	mapping (address => uint256) public deposited;

	// Linked crowdsale contract
	CrowdsaleInterface public crowdsale;

	/**
	 * payable methods
	 */

	// Important
	function() payable { }

	/**
	 * public methods
	 */

	// Check that crowdsale has end
	function crowdsaleHasEnded() public constant returns(bool) {
		return crowdsale.hasEnded();
	}

	// Check that crowdsale is goal reached
	function crowdsaleGoalReached() public constant returns(bool) {
		return crowdsale.goalReached();
	}

	// Get start time of crowdsale
	function getCrowdsaleStartTime() public constant returns(uint) {
		return crowdsale.startTime();
	}
	// Get end time of crowdsale
	function getCrowdsaleEndTime() public constant returns(uint) {
		return crowdsale.endTime();
	}

	/**
	 * only owner methods
	 */

	// Main method of buying token from crowdsale
	function deposit(address beneficiary) onlyOwner payable public { //buyTokens
		require(crowdsale.call.value(msg.value)());

		deposited[beneficiary] = deposited[beneficiary].add(msg.value);
	}

	// Setting crowdsale contract. Can execute from cryptosale
	function setCrowdsale(address _crowdsale) onlyOwner public {
		crowdsale = CrowdsaleInterface(_crowdsale);
	}
	
	// Return funds if softcup is not reached
	function claimRefund(address investor) onlyOwner public {
		// require(state == State.Refunding);
		require(crowdsale.hasEnded() && !crowdsale.goalReached());

		uint depositedValue = deposited[investor];
		require(depositedValue > 0);

		RefundVault vault = RefundVault(crowdsale.vault());
		if (vault.deposited(this) > 0) {
			crowdsale.claimRefund(); // refund TokenHolder
		}
		// MintableToken token = MintableToken(crowdsale.token());
		// require(token.balanceOf(this) > 0);

		deposited[investor] = 0;
        investor.transfer(depositedValue); // refund investor
        Refunded(investor, depositedValue);
	}

	// To give tokens investors
	function withdraw(address investor) onlyOwner public {
		// require(state == State.Withdraw);
		require(crowdsale.hasEnded() && crowdsale.goalReached());
		uint depositedValue = deposited[investor];
        require(depositedValue > 0);

        deposited[investor] = 0;
        MintableToken token = MintableToken(crowdsale.token());
        token.transfer(investor, depositedValue);
	}

	/**
	 * optional methods
	 */

	function getDepositedAmount() public returns(uint) {
		RefundVault vault = RefundVault(crowdsale.vault());
		return vault.deposited(this);
	}
}