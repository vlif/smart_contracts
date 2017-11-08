pragma solidity ^0.4.16;

import "./base/token/MintableToken.sol";
import "./base/math/SafeMath.sol";

import "./Constants.sol";

// Token contract
contract ExampleToken is Constants, MintableToken {
	address public FREEZING_STORAGE; //constant
	uint constant FREEZING_STORAGE_TOKENS = 1 * TOKEN_DECIMAL_MULTIPLIER;
    
    function name() constant public returns (string _name) {
        return "Example Token";
    }

    function symbol() constant public returns (string _symbol) { // EIP-20 Compliance
        return "EXT";
    }

    function decimals() constant public returns (uint8 _decimals) {
        return TOKEN_DECIMALS_UINT8;
    }
    
    // Constructor function
    function ExampleToken(address _freezingStorage) {
        require(_freezingStorage != 0x0);
    	// Mint freezed Tokens
		FREEZING_STORAGE = _freezingStorage;
        mint(FREEZING_STORAGE, FREEZING_STORAGE_TOKENS);
    }
}