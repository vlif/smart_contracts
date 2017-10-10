pragma solidity ^0.4.16;

import "./base/token/MintableToken.sol"; 
import "./base/math/SafeMath.sol";

import "./constants.sol";

// Token contract
contract ExampleToken is usingConstants, MintableToken {
    function name() constant public returns (string _name) {
        return "Example Token";
    }

    function symbol() constant public returns (bytes32 _symbol) {
        return "EXT";
    }

    function decimals() constant public returns (uint8 _decimals) {
        return TOKEN_DECIMALS_UINT8;
    }
}