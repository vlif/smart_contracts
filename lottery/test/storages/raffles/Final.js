const _ = require('lodash')

const FinalRaffleMock = artifacts.require("./contracts/raffles/mocks/FinalRaffleMock")
const FinalRaffle = artifacts.require("./contracts/raffles/FinalRaffle")
const Ticket = artifacts.require("./contracts/storages/Ticket")


contract('FinalRaffle', function(accounts) {
  beforeEach(async function () {
    this.owner = accounts[0]
    this.ticket = await Ticket.new()
    this.final = await FinalRaffle.new(this.ticket.address, { from: this.owner })

    await Promise.all(accounts.slice(0, 100).map((account) => this.final.addPlayer(account)))
  })

  describe('constants', function () {
    describe('getPlayersCountBy', function () {
      it('should correctly calculate number of players with divider is 1', async function () {
        assert.equal(5, (await this.final.getPlayersCountBy.call(5, 1)).valueOf())
      })

      it('should correctly calculate number of players with divider is 10', async function () {
        assert.equal(0, (await this.final.getPlayersCountBy.call(5, 10)).valueOf())
      })

      it('should correctly calculate number of players with divider is 100', async function () {
        assert.equal(0, (await this.final.getPlayersCountBy.call(5, 100)).valueOf())
      })
    })

    describe('getCategoryAWinning', function () {
      beforeEach(async function () {
        await this.final.sendTransaction({ value: web3.toWei(5), from: accounts[10] })
        await this.final.stop()
      })

      it('should correctly calculate winning for winner of A category', async function () {
        assert.equal(web3.toWei(0), (await this.final.getCategoryAWinning.call()).valueOf())
      })
    })

    describe('getCategoryBWinning', function () {
      it('should correctly calculate winning for winner of B category', async function () {
        await this.final.sendTransaction({ value: web3.toWei(10), from: accounts[10] })
        await this.final.stop()
        assert.equal(web3.toWei(0.6), (await this.final.getCategoryBWinning.call()).valueOf())
      })

      it('should correctly calculate winning for winner of B category', async function () {
        await this.final.sendTransaction({ value: web3.toWei(25), from: accounts[98] })
        await this.final.sendTransaction({ value: web3.toWei(25), from: accounts[97] })
        await this.final.stop()
        assert.equal(web3.toWei(3.3), (await this.final.getCategoryBWinning.call()).valueOf())
      })
    })

    describe('jackpot', function () {
      it('should correctly calculate jackpot', async function () {
        await this.final.sendTransaction({ value: web3.toWei(25), from: accounts[96] })
        await this.final.sendTransaction({ value: web3.toWei(25), from: accounts[95] })
        await this.final.stop()
        assert.equal(web3.toWei(40.1), (await this.final.jackpot.call()).valueOf())
      })
    })

    describe('getWinningAmount', function () {
      beforeEach(async function () {
        await this.final.sendTransaction({ value: web3.toWei(10), from: accounts[94] })
        await this.final.sendTransaction({ value: web3.toWei(10), from: accounts[93] })
        await this.final.sendTransaction({ value: web3.toWei(10), from: accounts[92] })
        await this.final.sendTransaction({ value: web3.toWei(10), from: accounts[91] })
        await this.final.sendTransaction({ value: web3.toWei(10), from: accounts[90] })
        await this.final.stop()
      })

      function generateTest (expected, index) {
        it(`should correctly calculate winning for ${index} player`, async function () {
          assert.equal(expected, (await this.final.getWinningAmount.call(index)).valueOf())
        })
      }

      generateTest(web3.toWei(40.1), 0)
      generateTest(web3.toWei(3.3), 1)
      generateTest(web3.toWei(0), 5)
    })
  })
})

contract('FinalRaffleMock', function(accounts) {
  beforeEach(async function () {
    this.owner = accounts[0]
    this.ticket = await Ticket.new()
    this.final = await FinalRaffleMock.new(this.ticket.address, { from: this.owner })
  })

  describe('constants', function () {
    describe('getPlayersCountBy', function () {
      it('should correctly calculate number of players with divider is 1', async function () {
        assert.equal(50, (await this.final.getPlayersCountBy.call(5, 1)).valueOf())
      })

      it('should correctly calculate number of players with divider is 10', async function () {
        assert.equal(5, (await this.final.getPlayersCountBy.call(5, 10)).valueOf())
      })

      it('should correctly calculate number of players with divider is 100', async function () {
        assert.equal(0, (await this.final.getPlayersCountBy.call(5, 100)).valueOf())
      })
    })

    describe('getCategoryAWinning', function () {
      beforeEach(async function () {
        await this.final.sendTransaction({ value: web3.toWei(5), from: accounts[10] })
        await this.final.stop()
      })

      it('should correctly calculate winning for winner of A category', async function () {
        assert.equal(web3.toWei(0.3), (await this.final.getCategoryAWinning.call()).valueOf())
      })
    })

    describe('getCategoryBWinning', function () {
      it('should correctly calculate winning for winner of B category', async function () {
        await this.final.sendTransaction({ value: web3.toWei(10), from: accounts[10] })
        await this.final.stop()
        assert.equal(web3.toWei(0), (await this.final.getCategoryBWinning.call()).valueOf())
      })

      it('should correctly calculate winning for winner of B category', async function () {
        await this.final.sendTransaction({ value: web3.toWei(25), from: accounts[98] })
        await this.final.sendTransaction({ value: web3.toWei(25), from: accounts[97] })
        await this.final.stop()
        assert.equal(web3.toWei(0.3), (await this.final.getCategoryBWinning.call()).valueOf())
      })
    })

    describe('jackpot', function () {
      it('should correctly calculate jackpot', async function () {
        await this.final.sendTransaction({ value: web3.toWei(25), from: accounts[96] })
        await this.final.sendTransaction({ value: web3.toWei(25), from: accounts[95] })
        await this.final.stop()
        assert.equal(web3.toWei(26), (await this.final.jackpot.call()).valueOf())
      })
    })

    describe('getWinningAmount', function () {
      beforeEach(async function () {
        await this.final.sendTransaction({ value: web3.toWei(10), from: accounts[94] })
        await this.final.sendTransaction({ value: web3.toWei(10), from: accounts[93] })
        await this.final.sendTransaction({ value: web3.toWei(10), from: accounts[92] })
        await this.final.sendTransaction({ value: web3.toWei(10), from: accounts[91] })
        await this.final.sendTransaction({ value: web3.toWei(10), from: accounts[90] })
        await this.final.stop()
      })

      function generateTest (expected, index) {
        it(`should correctly calculate winning for ${index} player`, async function () {
          assert.equal(expected, (await this.final.getWinningAmount.call(index)).valueOf())
        })
      }

      generateTest(web3.toWei(26), 0)
      generateTest(web3.toWei(3), 1)
      generateTest(web3.toWei(3), 5)
      generateTest(web3.toWei(0.3), 6)
      generateTest(web3.toWei(0.3), 30)
      generateTest(web3.toWei(0), 36)
    })
  })
})
