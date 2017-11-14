pragma solidity ^0.4.16;

import "./base/ownership/Ownable.sol";
import "./base/math/SafeMath.sol";

import "./TokenHolder.sol";
import "./CryptosaleRefundVault.sol";
import "./ReferralRefundVault.sol";

// Main cryptosale contract
contract Cryptosale is Ownable {
	using SafeMath for uint;

	// This contract knows that who how much bought tokens
	TokenHolder public tokenHolder;
	
	// Revenue percentage cryptosale
	uint public revenuePercent;
	// Storage contract of revenue cryptosale
	CryptosaleRefundVault public refundVault;

	// Flag of end cryptosale
	bool public isFinalized = false;
	
	// Minimum amount of funds to be raised in weis
    uint public goal;
    // Amount of raised money in wei
    uint public weiRaised;

	// referralCode => partnerAddr => bonusPercent
	mapping (uint => address) public ReferralMapCodePartner;
	mapping (address => uint) public ReferralMapPartnerBonus;
	// Storage contract of referral revenue
	ReferralRefundVault public referralRefundVault;
	uint public referralRevenueRate = 1;

	// Constructor function
	function Cryptosale(uint _goal, address _revenueWallet, uint _revenuePercent) {
		require(_revenuePercent > 0 && _revenuePercent < 100);
		require(_goal > 0);

		tokenHolder = new TokenHolder();
		refundVault = new CryptosaleRefundVault(address(tokenHolder), _revenueWallet);
		revenuePercent = _revenuePercent;

		referralRefundVault = new ReferralRefundVault(address(tokenHolder), _revenueWallet);

		goal = _goal;
	}

	/**
	 * payable methods
	 */

	// Buy sale tokens from crowdsale contract
	function() payable {
		buyTokens(msg.sender, msg.value, 0);
	}

	function buy(uint referralCode) payable {
		require(referralCode >= 10000 && referralCode <= 99999); // 5

		buyTokens(msg.sender, msg.value, referralCode);
	}

	/**
	 * public methods
	 */

	// Return funds if softcup is not reached
	// Throws exception if crowdsale is not finished
	function claimRefund() public {
		require(isFinalized);
		require(tokenHolder.crowdsaleHasEnded() && !tokenHolder.crowdsaleGoalReached());

		tokenHolder.claimRefund(msg.sender);
		refundVault.claimRefund(msg.sender);
		referralRefundVault.claimRefund(msg.sender);
	}

	// Investor can get buyed tokens if crowdsale ended and reached goal(tokenHolder's state == Withdraw (facade method))
	function withdraw() public {
		tokenHolder.withdraw(msg.sender);
	}

	// Referral partners can get revenue if crowdsale reached goal(referralRefundVault's state == Withdraw (facade method))
	function referralWithdraw() public {
		referralRefundVault.withdraw(msg.sender);
	}


	// Check that cryptosale contract is reached 
	function goalReached() public constant returns (bool) {
        return weiRaised == goal; //>=
    }


    /**
	 * internal methods
	 */

	// Main calculation
	function buyTokens(address beneficiary, uint amountWei, uint _referralCode) internal {
		require(!isFinalized);
		require(!goalReached());

		uint revenueAmountWei = amountWei.mul(revenuePercent).div(100);
		uint restAmountWei = amountWei.sub(revenueAmountWei);

		uint referralCode = _referralCode; // 2. referral code from function parameter
		if (referralCode == 0) {
			referralCode = getReferralCode(amountWei); // 1. referral code from msg.value
		}
		address referralPartner = ReferralMapCodePartner[referralCode];
		if (referralPartner != address(0)) {
			uint bonusPercent = ReferralMapPartnerBonus[referralPartner];
			require(bonusPercent.mul(referralRevenueRate) < 100);

			// bonusPercent > 0
			uint referralRevenueAmountWei = revenueAmountWei.mul(bonusPercent.mul(referralRevenueRate)).div(100);
		}

		uint change = 0;
		if (weiRaised.add(restAmountWei) > goal) {
			uint realAmount = goal.sub(weiRaised);
			change = restAmountWei.sub(realAmount);
			restAmountWei = restAmountWei.sub(change);
		}

		tokenHolder.deposit.value(restAmountWei)(beneficiary);
		
		// Update state
        weiRaised = weiRaised.add(restAmountWei);

		refundVault.forwardFunds.value(revenueAmountWei.sub(referralRevenueAmountWei))(beneficiary);
		if (referralRevenueAmountWei > 0) {
			referralRefundVault.forwardFunds.value(referralRevenueAmountWei)(beneficiary, referralPartner);
		}

		if (change != 0) {
            msg.sender.transfer(change);
        }
	}

	// Get referral code from amount of Wei
	function getReferralCode(uint amountWei) internal constant returns(uint) {
		uint meaningPartAmount = amountWei.div(100000000000); // 18 - 2 - 5
		uint basicPartAmount = amountWei.div(10000000000000000).mul(100000); // (18 - 2) * 5

		return meaningPartAmount.sub(basicPartAmount);
	}

	/**
	 * only owner methods
	 */

	// Method for changing crowdsale contract
	function setCrowdsale(address _crowdsale) onlyOwner public {
		require(_crowdsale != 0x0);
		require(tokenHolder.crowdsale() == address(0)); // can set crowdsale once

		tokenHolder.setCrowdsale(_crowdsale);
	}

	// Finalize cryptosale
	function finalize() onlyOwner public {
		require(!isFinalized);
		// require(!tokenHolder.crowdsaleIsFinalized());
		// require(tokenHolder.crowdsaleHasEnded());

		isFinalized = true;

		if (tokenHolder.crowdsaleGoalReached()) {
			// tokenHolder.close();
			refundVault.close();

			// referralRefundVault.close();
		}
/* 		else {
			tokenHolder.enableRefunds();
			refundVault.enableRefunds();

			referralRefundVault.enableRefunds();
		} */
	}

	// Add referral partner
	function addReferralCode(uint code, address partner, uint bonusPercent) onlyOwner returns(bool) { //99999
		require(bonusPercent > 0 && bonusPercent < 100);
		require(partner != 0x0);
		require(code >= 10000 && code <= 99999); // 5

		ReferralMapCodePartner[code] = partner;
		ReferralMapPartnerBonus[partner] = bonusPercent;

		return true;
	}

	// Set referral revenue rate
	function setReferralRevenueRate(uint _rate) onlyOwner {
		require(_rate > 0);
		referralRevenueRate = _rate;
	}
}