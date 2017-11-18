#!/usr/bin/env bash
echo "TicketSale.sol"
solc --bin --abi --gas --optimize -o target --overwrite contracts/TicketSale.sol
