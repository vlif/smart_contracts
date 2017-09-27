pragma solidity ^0.4.16;

contract A {
    B public b;
    address public senderTest;
    function A(B _address) {
        senderTest = msg.sender;
        b = B(_address);
        b.test();
    }
}

contract B {
    address public senderTest;
    function test() {
        senderTest = msg.sender;
    }
}