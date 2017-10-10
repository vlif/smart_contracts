pragma solidity ^0.4.16;

import "./base/ownership/Ownable.sol";
import "./base/math/SafeMath.sol";
import "./base/crowdsale/RefundVault.sol";
import "./base/token/MintableToken.sol";

import "./crowdsaleInterface.sol";
import "./refundVaultProvider.sol";

// Second main contract (after cryptosale) is token's holder
contract TokenHolder is Ownable, RefundVaultProvider {
	using SafeMath for uint256;

	// Linked crowdsale contract
	CrowdsaleInterface public crowdsale;

	// Setting crowdsale contract Can execute from cryptosale
	function setCrowdsale(address _crowdsale) onlyOwner public {
		crowdsale = CrowdsaleInterface(_crowdsale);
	}

	// Main method of buying token from crowdsale
	function deposit(address beneficiary) onlyOwner payable public { //buyTokens
		require(crowdsale.call.value(msg.value)());

		deposited[beneficiary] = deposited[beneficiary].add(msg.value);
	}

	// Return funds if softcup is not reached
	function claimRefund(address investor) onlyOwner public {
		require(state == State.Refunding);
		uint depositedValue = deposited[investor];
		require(depositedValue > 0);

		RefundVault vault = RefundVault(crowdsale.vault());
		if (vault.deposited(this) > 0) {
			crowdsale.claimRefund(); // refund TokenHolder
		}

		deposited[investor] = 0;
        investor.transfer(depositedValue); // refund investor
        Refunded(investor, depositedValue);
	}

	// Important
	function() payable {
	}

	// Check that crowdsale has end
	function crowdsaleHasEnded() public returns(bool) {
		return crowdsale.hasEnded();
	}

	// Check that crowdsale is goal reached
	function crowdsaleGoalReached() public returns(bool) {
		return crowdsale.goalReached();
	}

	// To give tokens investors
	function withdraw(address investor) onlyOwner public {
		require(state == State.Withdraw);
		uint depositedValue = deposited[investor];
        require(depositedValue > 0);

        deposited[investor] = 0;
        MintableToken token = MintableToken(crowdsale.token());
        token.transfer(investor, depositedValue);
	}

	// [optional]
	function getDepositedAmount() public returns(uint) {
		RefundVault vault = RefundVault(crowdsale.vault());
		return vault.deposited(this);
	}
}