pragma solidity ^0.4.16;

import './zeppelin/token/MintableToken.sol';
import './zeppelin/math/SafeMath.sol';

import './ParazitConstants.sol';

// Token contract
contract ParazitGPCCToken is ParazitConstants, MintableToken {
    // Pause token transfer. After successfully finished crowdsale it becomes false
    bool public paused = true;
    // Accounts who can transfer token even if paused. Works only during crowdsale
    mapping(address => bool) excluded;

    function name() constant public returns (string _name) {
        return "GPCC Token";
    }

    function symbol() constant public returns (string _symbol) { // EIP-20 Compliance
        return "GPCC";
    }

    function decimals() constant public returns (uint8 _decimals) {
        return TOKEN_DECIMALS_UINT8;
    }
    	
    function allowMoveTokens() onlyOwner {
        paused = false;
    }

    function addExcluded(address _toExclude) onlyOwner {
        excluded[_toExclude] = true;
    }

    // Wrapper of token.transferFrom
    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
        require(!paused || excluded[_from]);
        return super.transferFrom(_from, _to, _value);
    }

    // Wrapper of token.transfer
    function transfer(address _to, uint256 _value) returns (bool) {
        require(!paused || excluded[msg.sender]);
        return super.transfer(_to, _value);
    }
}