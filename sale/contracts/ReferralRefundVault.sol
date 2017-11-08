pragma solidity ^0.4.16;

import "./base/math/SafeMath.sol";
import "./base/ownership/Ownable.sol";

// import "./RefundVaultProvider.sol";
import "./TokenHolder.sol";

/**
 * Storage contract of referral partner's revenue
 */
contract ReferralRefundVault is Ownable { //, RefundVaultProvider
    using SafeMath for uint256;
    
    event Refunded(address indexed beneficiary, uint weiAmount);
    
    // Partner's referral revenue
    mapping (address => uint256) public partnersFunds;
    mapping (address => uint256) public deposited;

    // This contract knows that who how much bought tokens
    TokenHolder public tokenHolder;
    // Cryptosale wallet
    address public cryptosaleWallet;

    function ReferralRefundVault(address _tokenHolder, address _cryptosaleWallet) {
        tokenHolder = TokenHolder(_tokenHolder);
        cryptosaleWallet = _cryptosaleWallet;
    }

    /**
     * public methods
     */

    // If referral partners doesn't took the revenue at defined period then cryptosale will get it
    function releaseDanglingMoney() public {
        // require(state == State.Withdraw);
        require(tokenHolder.getCrowdsaleEndTime() + 90 days <= now); //3 minutes

        cryptosaleWallet.transfer(this.balance);
    }

    /**
     * payable methods
     */

    // Save investor's deposit funds for refunding and save partner's referral revenue
    function forwardFunds(address investor, address partner) onlyOwner payable public { //deposit
        // require(state == State.Active);

        if (tokenHolder.crowdsaleGoalReached()) {
            partner.transfer(msg.value);
        } else {
            deposited[investor] = deposited[investor].add(msg.value);
            partnersFunds[partner] = partnersFunds[partner].add(msg.value);
        }
    }

    /**
     * only owner methods
     */
    
    // To give referral revenue
	function withdraw(address partner) onlyOwner public {
		// require(state == State.Withdraw);
        require(tokenHolder.crowdsaleGoalReached());
		uint depositedValue = partnersFunds[partner];
        require(depositedValue > 0);

        partnersFunds[partner] = 0;
        partner.transfer(depositedValue); // send revenue to referral partner
	}

    function claimRefund(address investor) onlyOwner {
        // require(state == State.Refunding);
        require(tokenHolder.crowdsaleHasEnded() && !tokenHolder.crowdsaleGoalReached());
        uint depositedValue = deposited[investor];
        require(depositedValue > 0);

        deposited[investor] = 0;
        investor.transfer(depositedValue); // refund investor
        Refunded(investor, depositedValue);
    }

    /**
     * optional methods
     */

    // Get contract balance [optional]
    function getBalance() public constant returns(uint) {
        return this.balance;
    }
}