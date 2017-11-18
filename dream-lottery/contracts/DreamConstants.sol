pragma solidity ^0.4.0;


contract DreamConstants {
    uint constant MINIMAL_DREAM = 3 ether;
    uint constant TICKET_PRICE = 0.1 ether;
    uint constant MAX_TICKETS = 2**32;
    uint constant MAX_AMOUNT = 2**32 * TICKET_PRICE;
    uint constant DREAM_K = 2; // koefficient for calculation dream based on value
    uint constant ACCURACY = 10**18; // calculation accuracy
    uint constant REFUND_AFTER = 90 days; // refund after ~3 month
}
