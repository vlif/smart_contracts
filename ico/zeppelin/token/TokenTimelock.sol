pragma solidity ^0.4.11;

import "./ERC20Basic.sol";
// import "../token/SafeERC20.sol";
// import "../ownership/Ownable.sol";

// import "../../ESportsToken.sol";

/**
 * @title TokenTimelock
 * @dev TokenTimelock is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 */
contract TokenTimelock { //is Ownable
    // using SafeERC20 for ERC20Basic;

    // ERC20 basic token contract being held
    ERC20Basic token;

    // beneficiary of tokens after they are released
    address public beneficiary;

    // timestamp when token release is enabled
    uint64 public releaseTime;

    function TokenTimelock(ERC20Basic _token, address _beneficiary, uint64 _releaseTime) {
        require(_releaseTime > now);
        token = _token;
        beneficiary = _beneficiary;
        releaseTime = _releaseTime;
    }

    /**
      * @notice Transfers tokens held by timelock to beneficiary.
      * Deprecated: please use TokenTimelock#release instead.
      */
    function claim() { //onlyOwner
        require(msg.sender == beneficiary);
        release();
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function release() { //onlyOwner
        require(now >= releaseTime);

        uint256 amount = token.balanceOf(this);
        require(amount > 0);

        // token.safeTransfer(beneficiary, amount);
        token.transfer(beneficiary, amount);
    }
}
