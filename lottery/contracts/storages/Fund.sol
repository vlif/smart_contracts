pragma solidity 0.4.15;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';

import './../utils/Accesses.sol';

contract Fund is Accesses {
  using SafeMath for uint256;

  function () payable { credit(); }
  function credit() payable {}

  function transferFundToRaffle(address raffle, uint8 percentToRaffle) onlyCurrectTransfer(raffle) checkAccess {
    raffle.transfer(fundToRaffle(percentToRaffle));
  }

  /*
  * constants
  */

  function fundToRaffle(uint8 percentToRaffle) internal constant returns (uint256) {
    return this.balance.div(100).mul(percentToRaffle);
  }

  /*
  * modifiers
  */

  modifier onlyCurrectTransfer(address raffle) {
    require(raffle != 0x0);
    require(this.balance > 0);
    _;
  }
}
