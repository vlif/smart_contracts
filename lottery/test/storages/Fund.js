const _ = require('lodash')
const BigNumber = require('bignumber.js')

const Fund = artifacts.require("./contracts/funds/Fund");

contract('Fund', function(accounts) {
  beforeEach(async function () {
    this.fund = await Fund.new()
    this.owner = accounts[0]
  })

  describe('methods', function () {
    describe('credit', function () {
      describe('from is owner', function () {
        it('should transfer eth to target',
          async function () {
            await generateCreditTest.call(this, web3.toWei(1), web3.toWei(1), this.owner)
          }
        );
      });

      describe('from is not owner', function () {
        it('should transfer eth to target',
          async function () {
            await generateCreditTest.call(this, web3.toWei(1), web3.toWei(1), accounts[1])
          }
        );
      });
    });

    describe('transferFundToRaffle', function () {
      describe('from is owner', function () {
        it('should transfer eth to target',
          async function () {
            await generateTransferFundToRaffleTest.call(this, web3.toWei(1), web3.toWei(1), accounts[1], this.owner)
          }
        );
      });

      describe('from is not owner', function () {
        it('should reject call',
          async function () {
            try {
              await generateTransferFundToRaffleTest.call(this, web3.toWei(1), web3.toWei(1), accounts[1], accounts[1])
            } catch (error) {
              assert.isAbove(error.message.search('invalid opcode'), -1, 'Invalid opcode error must be returned');
            }
          }
        );
      });
    });
  });
});

async function generateCreditTest(expectedBalance, value, from) {
  const preBalance = web3.eth.getBalance(this.fund.address)

  await this.fund.credit({ value, from })

  assert.equal(
    web3.fromWei(expectedBalance).valueOf(),
    web3.fromWei(web3.eth.getBalance(this.fund.address) - preBalance).valueOf()
  )
}

async function generateTransferFundToRaffleTest(expectedBalance, value, target, from, partOfFund = 100) {
  const preBalance = web3.eth.getBalance(target)

  await generateCreditTest.call(this, expectedBalance, value, from)
  await this.fund.transferFundToRaffle(target, partOfFund, { from })

  assert.equal(
    web3.fromWei(expectedBalance).valueOf(),
    web3.fromWei(web3.eth.getBalance(target) - preBalance).valueOf()
  )
}
