const { isNull } = require('./../helpers')

const BASE_PATH = './contracts'

const RaffleOwner = artifacts.require(`${BASE_PATH}/Raffle/Regular/RaffleOwner`)

const RegularRaffle = artifacts.require(`${BASE_PATH}/storages/raffles/RegularRaffle`)
const Fund = artifacts.require(`${BASE_PATH}/storages/funds/Fund`)
const Ticket = artifacts.require(`${BASE_PATH}/storages/Ticket.sol`);

contract('RaffleOwner', function(accounts) {
  beforeEach(async function () {
    this.owner = accounts[0]
    this.tokenCost = web3.toWei(0.1)

    this.finalFund = await Fund.new()
    this.ticket = await Ticket.new()
    this.fund = await Fund.new()

    this.raffleOwner = await RaffleOwner.new(
      this.fund.address,
      this.finalFund.address,
      this.ticket.address,
      { from: this.owner }
    )

    await this.finalFund.addAccess(this.raffleOwner.address, { from: this.owner })
    await this.ticket.addAccess(this.raffleOwner.address, { from: this.owner })
    await this.fund.addAccess(this.raffleOwner.address, { from: this.owner })

    this.raffleOwner.createNewRaffle({ from: this.owner })
  })

  describe('cases', () => {
    describe('maximum raffles', () => {
      it("should stop selling tickets after create 30th raffle", async function() {
        for (let i = 0; i <= 29; i++) {
          await this.fund.credit({ from: accounts[i], value: web3.toWei(10) })
          await this.ticket.sign(accounts[0], 100)

          await this.raffleOwner.createRaffle({ from: this.owner })
          await this.raffleOwner.stopRaffle(false, { from: this.owner })
          await this.raffleOwner.finishRaffle({ from: this.owner })
        }

        assert.equal(true, await this.ticket.isFinished.call())
      });
    });
  });

  describe('methods', () => {
    describe('createRaffle', () => {
      describe('from is owner', () => {
        it("should create new raffle with fund", async function() {
          await this.fund.credit({ from: accounts[1], value: web3.toWei(10) })
          await this.ticket.sign(accounts[0], 100)

          const expectedFundBalance = web3.eth.getBalance(this.fund.address) / 100 * 65

          await this.raffleOwner.createRaffle({ from: this.owner })

          const raffle = RegularRaffle.at(await this.raffleOwner.raffle.call())
          await this.raffleOwner.stopRaffle(false, { from: this.owner })
          const raffleBalance = web3.eth.getBalance(raffle.address)

          assert.equal(true, !isNull(raffle.address))
          assert.equal(expectedFundBalance.valueOf(), raffleBalance.valueOf())
        });
      });

      describe('from is not owner', () => {
        it("should reject call", async function() {
          try {
            await this.raffleOwner.createRaffle({ from: accounts[9] })
          } catch (error) {
            assert.isAbove(error.message.search('invalid opcode'), -1, 'Invalid opcode error must be returned');
          }

          const raffle = await this.raffleOwner.raffle.call()
          assert.equal(true, isNull(raffle.valueOf()))
        });
      });
    });

    describe('stopRaffle', () => {
      it("should correct stop lottery", async function() {
        await this.fund.credit({ from: accounts[2], value: web3.toWei(10) })
        await this.ticket.sign(accounts[0], 100)

        await this.raffleOwner.createRaffle({ from: this.owner })

        const raffle = RegularRaffle.at(await this.raffleOwner.raffle.call())
        await this.raffleOwner.stopRaffle(false, { from: this.owner })

        assert.equal(true, await raffle.isStopped.call())
      });
    });

    describe('setWinner', () => {
      it("should transfer winning to winner", async function() {
        await this.fund.credit({ from: accounts[3], value: web3.toWei(10) })
        await this.ticket.sign(accounts[0], 100)

        await this.raffleOwner.createRaffle({ from: this.owner })

        const raffle = RegularRaffle.at(await this.raffleOwner.raffle.call())

        await this.raffleOwner.stopRaffle(true, { from: this.owner })
        await this.raffleOwner.setWinner(0, 0, { from: this.owner })

        const expectedPlayerAddress = await this.ticket.getPlayerByRaffle.call(0, raffle.address)

        assert.equal(expectedPlayerAddress, accounts[0])
      });
    });

    describe('finishRaffle', () => {
      it("should correct finish lottery", async function() {
        await this.fund.credit({ from: accounts[3], value: web3.toWei(10) })
        await this.ticket.sign(accounts[0], 100)

        await this.raffleOwner.createRaffle({ from: this.owner })

        const raffle = RegularRaffle.at(await this.raffleOwner.raffle.call())

        await this.raffleOwner.stopRaffle(false, { from: this.owner })

        await this.raffleOwner.finishRaffle({ from: this.owner })
        const raffleAddress = await this.raffleOwner.raffle.call()

        assert.equal(true, isNull(raffleAddress))
        assert.equal(true, await raffle.isFinished.call())
      });
    });

    describe('finish', () => {
      it("should stop selling tokens and transfer all funds to final raffle", async function() {
        const expectedRaffleBalance = web3.toWei(10)

        await this.finalFund.credit({ from: accounts[4], value: expectedRaffleBalance / 2 })
        await this.fund.credit({ from: accounts[4], value: expectedRaffleBalance / 2 })

        await this.raffleOwner.finish({ from: this.owner })
        const raffle = RegularRaffle.at(await this.raffleOwner.finalRaffle.call())

        const finalFundBalance = web3.eth.getBalance(this.finalFund.address)
        const fundBalance = web3.eth.getBalance(this.fund.address)
        const raffleBalance = web3.eth.getBalance(raffle.address)

        assert.equal(expectedRaffleBalance, raffleBalance.valueOf())
        assert.equal(0, finalFundBalance.valueOf())
        assert.equal(0, fundBalance.valueOf())
      });
    });
  });
});
