pragma solidity ^0.4.16;

import "./base/token/MintableToken.sol"; 
import "./base/math/SafeMath.sol";

import "./constants.sol";

// Token contract
contract ExampleToken is usingConstants, MintableToken {
	address public FREEZING_STORAGE;
	uint constant FREEZING_STORAGE_TOKENS = 1000000 * TOKEN_DECIMAL_MULTIPLIER;

    function name() constant public returns (string _name) {
        return "Example Token";
    }

    function symbol() constant public returns (bytes32 _symbol) {
        return "EXT";
    }

    function decimals() constant public returns (uint8 _decimals) {
        return TOKEN_DECIMALS_UINT8;
    }

    function ExampleToken(address _freezingStorage) {
    	// Mint freezed Tokens
		FREEZING_STORAGE = _freezingStorage;
        token.mint(FREEZING_STORAGE, FREEZING_STORAGE_TOKENS);
    }
}