pragma solidity ^0.4.7;

contract usingESportsConstants {
    uint constant TOKEN_DECIMALS = 18;
    uint8 constant TOKEN_DECIMALS_UINT8 = 18;
    uint constant TOKEN_DECIMAL_MULTIPLIER = 10 ** TOKEN_DECIMALS;
    uint constant RATE = 240; // 240 ETR = 1 ETH at the rate 1 ETH = 250 EUR
}