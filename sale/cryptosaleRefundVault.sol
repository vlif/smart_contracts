pragma solidity ^0.4.16;

import "./base/ownership/Ownable.sol";

import "./refundVaultProvider.sol";

/**
 * Storage contract of revenue cryptosale
 */
contract CryptosaleRefundVault is Ownable, RefundVaultProvider {
	// Cryptosale wallet for getting revenue
	address public wallet;

	// Constructor function
	function CryptosaleRefundVault(address _wallet) {
		require(_wallet != 0x0);

        wallet = _wallet;
	}

	// Close cryptosale refund
    function close() onlyOwner {
        super.close();
        wallet.transfer(this.balance); // send revenue to cryptosale
    }

    // [optional]
	function getBalance() public returns(uint) {
		return this.balance;
	}
}