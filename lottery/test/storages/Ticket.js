const { isNull } = require('./../helpers')

const Ticket = artifacts.require("./contracts/storages/Ticket.sol");

contract('Ticket', function(accounts) {
  describe('methods', () => {
    beforeEach(async function () {
      this.owner = accounts[0]
      this.investor = accounts[1]
      this.ticket = await Ticket.new({ from: this.owner })
      this.ticket.setCurrentRaffle(this.ticket.address)
    });

    describe('constants', () => {
      it("should have ticket price equal 0.1 eth", async function() {
        const ticketPrice = await this.ticket.price.call()
        assert.equal(web3.toWei(0.1), ticketPrice.valueOf())
      });
    })

    describe('sign', async function () {
      it('should buy ticket', async function () {
        const amount = 1;

        const preNumberPlayers = await this.ticket.getNumberPlayersByRaffle.call(this.ticket.address)
        await this.ticket.sign(this.investor, amount)
        const postNumberPlayers = await this.ticket.getNumberPlayersByRaffle.call(this.ticket.address)

        const lastPlayer = await this.ticket.getPlayerByRaffle.call(postNumberPlayers - 1, this.ticket.address)

        assert.equal(lastPlayer, this.investor)
        assert.equal(postNumberPlayers - preNumberPlayers, amount)
      });
    });
  });
});
