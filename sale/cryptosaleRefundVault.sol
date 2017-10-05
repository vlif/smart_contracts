pragma solidity ^0.4.16;

import "./base/math/SafeMath.sol";
import "./base/ownership/Ownable.sol";

import "./refundVaultCommon.sol";

/**
 * Storage contract of revenue cryptosale
 * We need 3 methods - deposit, refund/claimRefund, close
 *
 */
contract CryptosaleRefundVault is Ownable, RefundVaultCommon {
	using SafeMath for uint256;

	// Cryptosale wallet for getting revenue
	address public wallet;

	/**
	 * Constructor function
	 */
	function CryptosaleRefundVault(address _wallet) {
		require(_wallet != 0x0);

        wallet = _wallet;
	}

    function deposit(address _investor) onlyOwner payable {
        require(state == State.Active);

        deposited[_investor] = deposited[_investor].add(msg.value);
    }

    function close() onlyOwner {
        super.close();
        wallet.transfer(this.balance); // send revenue to cryptosale
    }
}