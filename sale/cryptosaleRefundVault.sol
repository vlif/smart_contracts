pragma solidity ^0.4.16;

import "./base/ownership/Ownable.sol";

import "./refundVaultProvider.sol";

/**
 * Storage contract of revenue cryptosale
 * We need 3 methods - deposit, refund/claimRefund, close
 * 
 */
contract CryptosaleRefundVault is Ownable, RefundVaultProvider {
	// Cryptosale wallet for getting revenue
	address public wallet;

	/**
	 * Constructor function
	 */
	function CryptosaleRefundVault(address _wallet) {
		require(_wallet != 0x0);

        wallet = _wallet;
	}

    function close() onlyOwner {
        super.close();
        wallet.transfer(this.balance); // send revenue to cryptosale
    }
}