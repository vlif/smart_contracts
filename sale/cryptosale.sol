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

	mapping (bytes3 => mapping (address => uint)) public ReferralPartners;
	ReferralRefundVault public referralRefundVault;

	/**
	 * Constructor function
	 */
	function Cryptosale(uint _revenuePercent, address _revenueWallet) {
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
	function buyTokens(address _beneficiary, uint _amountWei) internal {
		uint revenueAmountWei = _amountWei.mul(revenuePercent).div(100);
		tokenHolder.deposit.value(_amountWei.sub(revenueAmountWei))(_beneficiary); //buyTokens
		refundVault.deposit.value(revenueAmountWei)(_beneficiary);



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
        } else {
			tokenHolder.enableRefunds();
            refundVault.enableRefunds();
        }

		isFinalized = true;
	}

	// Фасадный метод
	function withdraw() public returns(bool) {
		return tokenHolder.withdraw(msg.sender);
	}

	function addReferralCode(bytes3 code, address partner, uint bonusPercent) onlyOwner returns(bool) { //99999
		require(bonusPercent > 0);
		require(bonusPercent < 100);

		ReferralPartners[code][partner] = bonusPercent;

		return true;
	}
}