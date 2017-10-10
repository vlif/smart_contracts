pragma solidity ^0.4.16;

import "./base/ownership/Ownable.sol";
import "./base/math/SafeMath.sol";

import "./tokenHolder.sol";
import "./cryptosaleRefundVault.sol";
import "./referralRefundVault.sol";

// Main cryptosale contract

// Transaction cost: 5049405 gas.
// Execution cost: 3824429 gas.

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

	// referralCode => partnerAddr => bonusPercent
	mapping (uint => address) public ReferralMapCodePartner;
	mapping (address => uint) public ReferralMapPartnerBonus;
	// Storage contract of referral revenue
	ReferralRefundVault public referralRefundVault;

	// Constructor function
	function Cryptosale(uint _revenuePercent, address _revenueWallet) {
		require(_revenuePercent > 0 && _revenuePercent < 100);

		tokenHolder = new TokenHolder();
		refundVault = new CryptosaleRefundVault(_revenueWallet);
		revenuePercent = _revenuePercent;

		referralRefundVault = new ReferralRefundVault();
	}

	// Buy sale tokens from crowdsale contract
	function() payable {
		require(!isFinalized);
			
		buyTokens(msg.sender, msg.value);
	}

	// Main calculation
	function buyTokens(address beneficiary, uint amountWei) internal {
		uint revenueAmountWei = amountWei.mul(revenuePercent).div(100);
		uint restAmountWei = amountWei.sub(revenueAmountWei);

		uint referralCode = getReferralCode(amountWei);
		address referralPartner = ReferralMapCodePartner[referralCode];
		if (referralPartner != address(0)) {
			uint bonusPercent = ReferralMapPartnerBonus[referralPartner];
			require(revenuePercent.add(bonusPercent) < 100);

			uint referralRevenueAmountWei = restAmountWei.mul(bonusPercent).div(100); // bonusPercent > 0
			restAmountWei = restAmountWei.sub(referralRevenueAmountWei);
		}
		
		tokenHolder.deposit.value(restAmountWei)(beneficiary); //buyTokens
		refundVault.deposit.value(revenueAmountWei)(beneficiary);
		
		if (referralRevenueAmountWei > 0)
			referralRefundVault.forwardFunds.value(referralRevenueAmountWei)(beneficiary, referralPartner); //deposit
	}

	// Method for changing crowdsale contract
	function setCrowdsale(address _crowdsale) onlyOwner public {
		require(_crowdsale != 0x0);
		require(tokenHolder.crowdsale() == address(0)); // can set crowdsale once

		tokenHolder.setCrowdsale(_crowdsale);
	}

	// Return funds if softcup is not reached
	// Throws exeption if crowdsale is not finished
	function claimRefund() public {
		require(isFinalized);
		require(!tokenHolder.crowdsaleGoalReached());

		tokenHolder.claimRefund(msg.sender);
		refundVault.claimRefund(msg.sender);

		referralRefundVault.claimRefund(msg.sender);
	}

	// Finalize cryptosale
	function finalize() onlyOwner public {
		require(!isFinalized);
		require(tokenHolder.crowdsaleHasEnded()); 

		if (tokenHolder.crowdsaleGoalReached()) {
			tokenHolder.close();
            refundVault.close();

            referralRefundVault.close();
        } else {
			tokenHolder.enableRefunds();
            refundVault.enableRefunds();

            referralRefundVault.enableRefunds();
        }

		isFinalized = true;
	}

	// Investor can get buyed tokens if tokenHolder's state == Withdraw (facade method)
	function withdraw() public {
		tokenHolder.withdraw(msg.sender);
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

	// Get referral code from amount of Wei
	function getReferralCode(uint amountWei) internal returns(uint) {
		uint meaningPartAmount = amountWei.div(100000000000); // 18 - 2 - 5
		uint basicPartAmount = amountWei.div(10000000000000000).mul(100000); // (18 - 2) * 5

		return meaningPartAmount.sub(basicPartAmount);
	}

	// Referral partners can get revenue if referralRefundVault's state == Withdraw (facade method)
	function referralWithdraw() public {
		referralRefundVault.withdraw(msg.sender);
	}
}