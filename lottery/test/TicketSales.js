const BASE_PATH = './../contracts'

const Fund = artifacts.require(`${BASE_PATH}/storages/Fund`)
const Ticket = artifacts.require(`${BASE_PATH}/storages/Ticket`)

const TicketSales = artifacts.require(`${BASE_PATH}/TicketSales`)

contract('TicketSales', function(accounts) {
  beforeEach(async function () {
    this.owner = accounts[0]
    this.ticketPrice = web3.toWei(0.1)
    this.ownerCommissionsPercent = 20
    this.regularFundPercent = 40
    this.instantFundPercent = 30
    this.finalFundPercent = 10

    this.regularFund = await Fund.new()
    this.finalFund = await Fund.new()
    this.ticket = await Ticket.new()

    this.ticketSales = await TicketSales.new(
      this.regularFund.address,
      this.finalFund.address,
      this.ticket.address
    )

    await this.ticket.setCurrentRaffle(this.ticketSales.address, { from: this.owner })
    await this.ticket.addAccess(this.ticketSales.address, { from: this.owner })
  })

  describe('state', () => {
    describe('defaults', () => {
      it("should have commissions equal 20", async function() {
        const ownerCommissionsPercent = await this.ticketSales.ownerCommissionsPercent.call()
        assert.equal(this.ownerCommissionsPercent, ownerCommissionsPercent.valueOf())
      });

      it("should have regularFundPercent equal 40", async function() {
        const regularFundPercent = await this.ticketSales.regularFundPercent.call()
        assert.equal(this.regularFundPercent, regularFundPercent.valueOf())
      });

      it("should have instantFundPercent equal 30", async function() {
        const instantFundPercent = await this.ticketSales.instantFundPercent.call()
        assert.equal(this.instantFundPercent, instantFundPercent.valueOf())
      });

      it("should have finalFundPercent equal 10", async function() {
        const finalFundPercent = await this.ticketSales.finalFundPercent.call()
        assert.equal(this.finalFundPercent, finalFundPercent.valueOf())
      });

      it("should have lottery owner", async function() {
        const owner = await this.ticketSales.owner.call()
        assert.equal(this.owner, owner.valueOf())
      });
    });
  })

  describe('methods', () => {
    describe('buyTickets', () => {
      const player = accounts[1]

      it("should sign 1 ticket to player", async function() {
        await this.ticketSales.sendTransaction({ from: player, value: this.ticketPrice })
        assert.equal(player, await this.ticket.getPlayerByRaffle.call(0, this.ticketSales.address))
      });

      it("should sign 2 tokens to investor", async function() {
        await this.ticketSales.sendTransaction({ from: player, value: this.ticketPrice * 2 })
        const indexes = [0, 1]
        indexes.forEach(async (i) => {
          assert.equal(player, await this.ticket.getPlayerByRaffle.call(index, this.ticketSales.address))
        })
      });

      it("should return the change to investor", async function() {
        await this.ticketSales.sendTransaction({ from: player, value: this.ticketPrice * 1.5 })
        assert.equal(player, await this.ticket.getPlayerByRaffle.call(0, this.ticketSales.address))
      });

      it("should transfer correct ether amount to owner", async function() {
        const ownerCommissionsPercent = (await this.ticketSales.ownerCommissionsPercent.call()).valueOf()
        await generateTestOfForwardFunds.call(this, this.owner, ownerCommissionsPercent, player)
      });

      it("should transfer correct ether amount to regular fund", async function() {
        const regularFundPercent = (await this.ticketSales.regularFundPercent.call()).valueOf()
        await generateTestOfForwardFunds.call(this, this.regularFund.address, regularFundPercent, player)
      });

      it("should transfer correct ether amount to final fund", async function() {
        const finalFundPercent = (await this.ticketSales.finalFundPercent.call()).valueOf()
        await generateTestOfForwardFunds.call(this, this.finalFund.address, finalFundPercent, player)
      });

      // it("should transfer correct ether amount to instant fund", async function() {});
    });
  });
});

async function generateTestOfForwardFunds (address, percent, player) {
  const expectedBalance = this.ticketPrice * (percent / 100)
  const token = this.token

  const preBalance = web3.eth.getBalance(address)
  await this.ticketSales.sendTransaction({ from: player, value: this.ticketPrice })
  const postBalance = web3.eth.getBalance(address)

  assert.equal(expectedBalance, postBalance - preBalance)
}
