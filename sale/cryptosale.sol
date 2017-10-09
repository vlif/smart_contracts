pragma solidity ^0.4.16;

import "./base/ownership/Ownable.sol";
import "./base/math/SafeMath.sol";

import "./tokenHolder.sol";
import "./cryptosaleRefundVault.sol";
import "./referralRefundVault.sol";

/**
 * Main cryptosale contract
 *
 */
contract Cryptosale is Ownable {
	using SafeMath for uint;

	// This contract knows that who how much bought tokens
	TokenHolder public tokenHolder;
	// Revenue percentage cryptosale
	uint public revenuePercent;
	// Storage contract of revenue cryptosale
	CryptosaleRefundVault public refundVault;

	bool public isFinalized = false;

	// referralCode => partnerAddr => bonusPercent
	mapping (uint => address) public ReferralMapCodePartner;
	mapping (address => uint) public ReferralMapPartnerBonus;
	ReferralRefundVault public referralRefundVault;

	/**
	 * Constructor function
	 */
	function Cryptosale(uint _revenuePercent, address _revenueWallet) {
		require(_revenuePercent > 0);
		require(_revenuePercent < 100);

		tokenHolder = new TokenHolder();
		refundVault = new CryptosaleRefundVault(_revenueWallet);
		revenuePercent = _revenuePercent;

		referralRefundVault = new ReferralRefundVault();
	}

	/**
	 * Тут по ходу нам надо затариться токенами со скидкой у контракта crowdsale ! через TokenHolder !
	 */
	function() payable {
		require(!isFinalized);
			
		buyTokens(msg.sender, msg.value);
	}

	// Calculation
	function buyTokens(address beneficiary, uint amountWei) internal {
		uint revenueAmountWei = amountWei.mul(revenuePercent).div(100);
		uint restAmountWei = amountWei.sub(revenueAmountWei);

		uint referralCode = getReferralCode(amountWei);
		if (ReferralMapCodePartner[referralCode] != 0x0) {
			address partner = ReferralMapCodePartner[referralCode];
			uint bonusPercent = ReferralMapPartnerBonus[partner];
			uint referralRevenueAmountWei = restAmountWei.mul(bonusPercent).div(100);
		}
		restAmountWei = restAmountWei.sub(referralRevenueAmountWei);

		tokenHolder.deposit.value(restAmountWei)(beneficiary); //buyTokens
		refundVault.deposit.value(revenueAmountWei)(beneficiary);
		
		if (referralRevenueAmountWei > 0)
			referralRefundVault.deposit.value(referralRevenueAmountWei)(beneficiary);
	}

	// Можно затариваться в другом месте, фасадный метод
	function setCrowdsale(address _crowdsale) onlyOwner public {
		require(_crowdsale != 0x0);

		tokenHolder.setCrowdsale(_crowdsale);
	}

	// Возвращаем бабосики, если soft cup не пройден
	function claimRefund() public {
		require(isFinalized);
		require(!tokenHolder.crowdsaleGoalReached());

		tokenHolder.claimRefund(msg.sender);
		refundVault.claimRefund(msg.sender);
	}

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

	// Фасадный метод
	function withdraw() public returns(bool) {
		return tokenHolder.withdraw(msg.sender);
	}

	// Add referral partner
	function addReferralCode(uint code, address partner, uint bonusPercent) onlyOwner returns(bool) { //99999
		require(bonusPercent > 0);
		require(bonusPercent < 100);
		require(partner != 0x0);
		// require(code ???...);

		ReferralMapCodePartner[code] = partner;
		ReferralMapPartnerBonus[partner] = bonus;

		return true;
	}

	// Get referral code from amount of Wei
	function getReferralCode(uint amountWei) internal returns(uint) {
		uint meaningAmount = amountWei.div(100000000000); // 18 - 2 - 5
		uint mainPartAmount = amountWei.div(10000000000000000).mul(100000); // 18 - 2 * 5

		return meaningAmount.sub(mainPartAmount);
	}
}