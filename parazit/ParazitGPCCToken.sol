pragma solidity ^0.4.16;

import './zeppelin/token/MintableToken.sol';
import './zeppelin/math/SafeMath.sol';

import './ParazitConstants.sol';

// Token contract
contract ParazitGPCCToken is ParazitConstants, MintableToken {
    function name() constant public returns (string _name) {
        return "GPCC Token";
    }

    function symbol() constant public returns (string _symbol) {
        return "GPCC";
    }

    function decimals() constant public returns (uint8 _decimals) {
        return TOKEN_DECIMALS_UINT8;
    }
}