pragma solidity ^0.4.16;

import './zeppelin/token/MintableToken.sol';
import './zeppelin/math/SafeMath.sol';

import './ParazitConstants.sol';

// Token contract
contract ParazitGPCCToken is usingParazitConstants, MintableToken {
    function name() constant public returns (string _name) {
        return "GPCC Token";
    }

    function symbol() constant public returns (bytes32 _symbol) {
        return "GPCC";
    }

    function decimals() constant public returns (uint8 _decimals) {
        return TOKEN_DECIMALS_UINT8;
    }
}