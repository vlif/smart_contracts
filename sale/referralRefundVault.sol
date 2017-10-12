pragma solidity ^0.4.16;

import "./base/math/SafeMath.sol";
import "./base/ownership/Ownable.sol";

import "./refundVaultProvider.sol";
import "./tokenHolder.sol";

/**
 * Storage contract of referral partner's revenue
 */
contract ReferralRefundVault is Ownable, RefundVaultProvider {
    using SafeMath for uint256;

    // Partner's referral revenue
    mapping (address => uint256) public partnersFunds;

    // This contract knows that who how much bought tokens
    TokenHolder public tokenHolder;
    // Cryptosale wallet
    address public cryptosaleWallet;

    function ReferralRefundVault(address _tokenHolder, address _cryptosaleWallet) {
        tokenHolder = TokenHolder(_tokenHolder);
        cryptosaleWallet = _cryptosaleWallet;
    }

    // Save investor's deposit funds for refunding and save partner's referral revenue
    function forwardFunds(address investor, address partner) onlyOwner payable public { //deposit
        require(state == State.Active);

        deposited[investor] = deposited[investor].add(msg.value);
        partnersFunds[partner] = partnersFunds[partner].add(msg.value);
    }

    // To give referral revenue
	function withdraw(address partner) onlyOwner public {
		require(state == State.Withdraw);
		uint depositedValue = partnersFunds[partner];
        require(depositedValue > 0);

        partnersFunds[partner] = 0;
        partner.transfer(depositedValue); // send revenue to referral partner
	}

    // If referral partners doesn't took the revenue at defined period then cryptosale will get it
    function releaseDanglingMoney() onlyOwner public {
        require(state == State.Withdraw);
        require(tokenHolder.getCrowdsaleStartTime() + 90 days <= now); // 3 months

        cryptosaleWallet.transfer(this.balance);
    }

    // [optional]
    function getBalance() onlyOwner public returns(uint) {
        return this.balance;
    }
}