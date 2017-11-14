pragma solidity ^0.4.16;

import "./base/ownership/Ownable.sol";
import "./base/math/SafeMath.sol";

// import "./refundVaultProvider.sol";
import "./TokenHolder.sol";
import "./Cryptosale.sol";

/**
 * Storage contract of revenue cryptosale
 */
contract CryptosaleRefundVault is Ownable { //, RefundVaultProvider
    using SafeMath for uint256;

    event Refunded(address indexed beneficiary, uint weiAmount);

	// Cryptosale wallet for getting revenue
	address public wallet;

	mapping (address => uint256) public deposited;

	// This contract knows that who how much bought tokens
    TokenHolder public tokenHolder;

	// Constructor function
	function CryptosaleRefundVault(address _tokenHolder, address _wallet) {
		require(_wallet != 0x0);

        wallet = _wallet;
        tokenHolder = TokenHolder(_tokenHolder);
	}

	/**
	 * only owner methods
	 */

	// Close cryptosale refund
    function close() onlyOwner public {
        // super.close();
        wallet.transfer(this.balance); // send revenue to cryptosale
    }
    
    function claimRefund(address investor) onlyOwner public {
        // require(state == State.Refunding);
        require(tokenHolder.crowdsaleHasEnded() && !tokenHolder.crowdsaleGoalReached());
        uint depositedValue = deposited[investor];
        require(depositedValue > 0);

        deposited[investor] = 0;
        investor.transfer(depositedValue); // refund investor
        Refunded(investor, depositedValue);
    }

    function forwardFunds(address investor) onlyOwner payable public {
        // require(state == State.Active);
        
        Cryptosale cryptosale = Cryptosale(owner);
        if (tokenHolder.crowdsaleGoalReached() || msg.value >= cryptosale.goal()) {
        	wallet.transfer(msg.value);
    	} else {
        	deposited[investor] = deposited[investor].add(msg.value);
    	}
    }

    /**
	 * optional methods
	 */

	// Get contract balance
	function getBalance() public constant returns(uint) {
		return this.balance;
	}
}