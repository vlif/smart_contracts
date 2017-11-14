pragma solidity ^0.4.11;

import './InsertionSorter.sol';

contract InsertionSort {
	using InsertionSorter for uint[];

    uint[] public data;

    function generate(uint elementCount) {
        require(elementCount > 0);
        uint wheelResult;
        // data.length = elementCount;
        for (var i = 0; i < elementCount; i++) {
            wheelResult = uint8(uint256(block.timestamp+i)%37+i*5);
            data.push(wheelResult);
        }
    }
    
    function sort() {
        if (data.length == 0)
            return;
        data.sort();
    }
}
