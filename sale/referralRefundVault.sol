pragma solidity ^0.4.16;

import "./base/math/SafeMath.sol";
import "./base/ownership/Ownable.sol";

import "./refundVaultProvider.sol";

/**
 * Storage contract of referral partner's revenue
 */
contract ReferralRefundVault is Ownable, RefundVaultProvider {
    using SafeMath for uint256;

    // Partner's referral revenue
    mapping (address => uint256) public partnersFunds;

    // Save investor's deposit funds for refunding and save partner's referral revenue
    function forwardFunds(address investor, address partner) onlyOwner payable { //deposit
        require(state == State.Active);

        deposited[investor] = deposited[investor].add(msg.value);
        partnersFunds[partner] = partnersFunds[partner].add(msg.value);
    }

    // To give referral revenue
	function withdraw(address partner) onlyOwner {
		require(state == State.Withdraw);
		uint depositedValue = partnersFunds[partner];
        require(depositedValue > 0);

        partnersFunds[partner] = 0;
        partner.transfer(depositedValue); // send revenue to referral partner
	}
}