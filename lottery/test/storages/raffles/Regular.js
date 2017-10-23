const _ = require('lodash')

const RegularRaffle = artifacts.require("./contracts/raffles/RegularRaffle")
const Ticket = artifacts.require("./contracts/storages/Ticket")
const Fund = artifacts.require("./contracts/storages/Fund")

contract('RegularRaffle', function(accounts) {
  beforeEach(async function () {
    this.owner = accounts[0]
    this.regularFund = await Fund.new()
    this.ticket = await Ticket.new()
    this.raffle = await RegularRaffle.new(
      this.regularFund.address,
      this.ticket.address, { from: this.owner }
    )
    await this.ticket.setCurrentRaffle(this.raffle.address)
    this.partOfFund = (await this.raffle.partOfFund.call()).valueOf()
  })

  describe('methods', function () {
    describe('constants', function () {
      describe('getPlayersCountBy', function () {
        beforeEach(async function () {
          await this.ticket.sign(accounts[0], 100)
        })

        it('should correctly calculate number of players by percent', async function () {
          assert.equal(1, (await this.raffle.getCategoryACount.call()).valueOf())
          assert.equal(4, (await this.raffle.getCategoryBCount.call()).valueOf())
        })
      })

      describe('getCategoryAWinning', function () {
        beforeEach(async function () {
          this.value = web3.toWei(6.5123123)
          await this.raffle.sendTransaction({ value: this.value, from: accounts[5] })
          await this.ticket.sign(accounts[0], 100)
          await this.raffle.stop(false)
        })

        it('should correctly calculate winning for winner of A category', async function () {
          assert.equal(
            web3.toWei(5.3),
            (await this.raffle.getCategoryAWinning.call()).valueOf()
          )
        })
      })

      describe('getCategoryBWinning', function () {
        beforeEach(async function () {
          this.value = web3.toWei(6.5123123)
          await this.raffle.sendTransaction({ value: this.value, from: accounts[6] })
          await this.ticket.sign(accounts[0], 100)
        })

        describe('when isJackpot is false', function () {
          beforeEach(async function () {
            await this.raffle.stop(false)
          })

          it('should correctly calculate winning for winner of B category', async function () {
            assert.equal(
              web3.toWei(0.3),
              (await this.raffle.getCategoryBWinning.call()).valueOf()
            )
          })
        })

        describe('when isJackpot is true', function () {
          beforeEach(async function () {
            await this.raffle.stop(true)
          })

          it('should correctly calculate winning for winner of B category', async function () {
            assert.equal(
              web3.toWei(0.2),
              (await this.raffle.getCategoryBWinning.call()).valueOf()
            )
          })
        })
      })

      describe('numberOfTickets', function () {
        beforeEach(async function () {
          await this.ticket.sign(accounts[0], 100)
        })

        it('should return number of tickets', async function () {
          assert.equal(100, (await this.raffle.getNumberOfTickets.call()).valueOf())
        })
      })

      describe('jackpot', function () {
        beforeEach(async function () {
          this.value = web3.toWei(6.5)
          await this.raffle.sendTransaction({ value: this.value, from: accounts[7] })
          await this.ticket.sign(accounts[0], 100)
          await this.raffle.stop(true)
        })

        it('should correctly calculate jackpot', async function () {
          assert.equal(
            web3.toWei(3.5),
            (await this.raffle.jackpot.call()).valueOf()
          )
        })
      })

      describe('fullFund', function () {
        beforeEach(async function () {
          this.value = web3.toWei(6.5)
          await this.raffle.sendTransaction({ value: this.value, from: accounts[8] })
          await this.raffle.stop(false)
        })

        it('should correctly calculate fullFund', async function () {
          assert.equal(web3.toWei(10), (await this.raffle.fullFund.call()).valueOf())
        })
      })

      describe('getWinningAmount', function () {
        beforeEach(async function () {
          this.value = web3.toWei(6.5)
          await this.raffle.sendTransaction({ value: this.value, from: accounts[9] })
          await this.ticket.sign(accounts[0], 100)
        })

        function generateTest (expected, index) {
          it(`should correctly calculate winning for ${index} player`, async function () {
            assert.equal(expected, (await this.raffle.getWinningAmount.call(index)).valueOf())
          })
        }

        describe('when param _isJackpot is false', function () {
          beforeEach(async function () {
            await this.raffle.stop(false)
          })

          generateTest(web3.toWei(5.3), 0)
          generateTest(web3.toWei(0.3), 1)
          generateTest(web3.toWei(0.3), 4)
          generateTest(web3.toWei(0), 5)
        })

        describe('when param _isJackpot is true', function () {
          beforeEach(async function () {
            await this.raffle.stop(true)
          })

          generateTest(web3.toWei(3.5), 0)
          generateTest(web3.toWei(0.2), 1)
          generateTest(web3.toWei(0.2), 4)
          generateTest(web3.toWei(0), 5)
        })
      })
    })

    describe('changing contract state', function () {
      describe('stop', function () {
        beforeEach(async function () {
          this.value = web3.toWei(6.5123)
          await this.raffle.sendTransaction({ value: this.value, from: accounts[10] })
          await this.ticket.sign(accounts[0], 100)
        })

        describe('when param _isJackpot is false', function () {
          beforeEach(async function () {
            await this.raffle.stop(false)
          })

          it('should set isJackpot to false', async function () {
            assert.equal(false, await this.raffle.isJackpot.call())
          })

          it('should set isStopped to true', async function () {
            assert.equal(true, await this.raffle.isStopped.call())
          })
        })

        describe('when param _isJackpot is true', function () {
          beforeEach(async function () {
            await this.raffle.stop(true)
          })

          it('should set isJackpot is true', async function () {
            assert.equal(true, await this.raffle.isJackpot.call())
          })

          it('should set isStopped to true', async function () {
            assert.equal(true, await this.raffle.isStopped.call())
          })
        })
      });

      describe('finish', function () {
        beforeEach(async function () {
          this.value = web3.toWei(6.5123)
          await this.raffle.sendTransaction({ value: this.value, from: accounts[11] })
          await this.ticket.sign(accounts[0], 100)
          await this.raffle.stop(false)
          await this.raffle.finish()
        })

        it('should set isFinished to true', async function () {
          assert.equal(true, await this.raffle.isFinished.call())
        })

        it('should transfer balance back to fund', async function () {
          assert.equal(this.value, web3.eth.getBalance(this.regularFund.address))
        })
      })

      describe('setJackpot', function () {
        beforeEach(async function () {
          await this.raffle.setJackpot(true)
        })

        it('should set isJackpot to true', async function () {
          assert.equal(true, await this.raffle.isJackpot.call())
        })
      })
    })
  });
});

function getFullFund (partOfFund, value) {
  return value * 100 / partOfFund
}
