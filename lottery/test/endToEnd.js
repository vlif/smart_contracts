const _ = require('lodash')

const BASE_PATH = './contracts'

const FinalRaffleMock = artifacts.require("./contracts/raffles/mocks/FinalRaffleMock")
const FinalRaffle = artifacts.require(`${BASE_PATH}/storages/raffles/FinalRaffle`)
const RegularRaffle = artifacts.require(`${BASE_PATH}/storages/raffles/RegularRaffle`)

const Fund = artifacts.require(`${BASE_PATH}/storages/funds/Fund`)

const Ticket = artifacts.require(`${BASE_PATH}/storages/Ticket`)

const RaffleOwner = artifacts.require(`${BASE_PATH}/Raffle/Regular/RaffleOwner`)
const TicketSales = artifacts.require(`${BASE_PATH}/TicketSales`)

contract('End to end.', function(accounts) {
  before(async function () {
    this.owner = accounts[0]
    this.ticketPrice = web3.toWei(0.1)

    this.ticket = await Ticket.new()

    this.regularFund = await Fund.new()
    this.finalFund = await Fund.new()

    this.ticketSales = await TicketSales.new(
      this.regularFund.address,
      this.finalFund.address,
      this.ticket.address,
      { from: this.owner }
    )

    this.raffleOwner = await RaffleOwner.new(
      this.regularFund.address,
      this.finalFund.address,
      this.ticket.address,
      { from: this.owner }
    )

    await this.regularFund.addAccess(this.raffleOwner.address, { from: this.owner })
    await this.finalFund.addAccess(this.raffleOwner.address, { from: this.owner })
    await this.ticket.addAccess(this.raffleOwner.address, { from: this.owner })
    await this.ticket.addAccess(this.ticketSales.address, { from: this.owner })

    await this.raffleOwner.createNewRaffle({ from: this.owner })
  });

  function regularRaffleFlow(index, isJackpot, mul) {
    describe(`regular raffle #${index}`, async function () {
      it('should set next raffle to raffle', async function () {
        await Promise.all(accounts.map(async (account) =>
          this.ticketSales.sendTransaction({ from: account, value: this.ticketPrice * mul })
        ))

        const expected = await this.raffleOwner.nextRaffle.call()
        await this.raffleOwner.createRaffle()
        assert.equal(expected, await this.raffleOwner.raffle.call())
      })

      it('should stop current raffle', async function () {
        await this.raffleOwner.stopRaffle(isJackpot)
      })

      it('should set winners from current raffle', async function () {
        const raffle = RegularRaffle.at(await this.raffleOwner.raffle.call())
        const winnersCount = await raffle.getCategoryACount.call() + await raffle.getCategoryBCount.call()
        await Promise.all(_.range(0, winnersCount).map(async(i) =>
          this.raffleOwner.setWinner(i, i)
        ))
      })

      it('should finish current raffle', async function () {
        await this.raffleOwner.finishRaffle()
      })
    })
  }

  describe.skip('Bugs case', async function() {
    describe('with 30 players', async function() {
      await regularRaffleFlow(0, false, 1)
    })
  })

  describe.skip('Success case', async function() {
    await Promise.all(_.range(0, 30).map(async (i) =>
      await regularRaffleFlow(i, i % 5 === 0, 5)
    ))

    describe.skip('Final raffle', async function() {
      it('should start finish raffle', async function () {
        await this.raffleOwner.finish()
        const finalRaffle = FinalRaffle.at(await this.raffleOwner.finalRaffle())

        await Promise.all(_.range(0, 60).map(async(i) =>
          this.raffleOwner.setFinalWinner(i, i)
        ))

        assert.equal(0, web3.eth.getBalance(finalRaffle.address).valueOf())
      })
    })
  })
});
