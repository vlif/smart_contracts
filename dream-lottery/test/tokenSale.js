const chai = require("chai");
const chaiAsPromised = require("chai-as-promised");
chai.use(chaiAsPromised);
chai.should();
const BigNumber = require("bignumber.js");
const utils = require("./utils");
const TicketSale = artifacts.require("./TicketSale.sol");
const TicketHolder = artifacts.require("./TicketHolder.sol");

const ether = web3.toWei(1, 'ether');
const gwei = web3.toWei(1, 'gwei');
const END = new Date("2017-10-10T16:00:00Z").getTime() / 1000;

contract('TicketSale', function (accounts) {
    const OWNER = accounts[0];
    const FIRST = accounts[1];

    it("simple flow", async() => {
        const ticketSale = await TicketSale.new(END);
        const ticketHolderAddress = await ticketSale.ticketHolder();
        const ticketHolder = TicketHolder.at(ticketHolderAddress);

        let isEnded = await ticketSale.isEnded();
        isEnded.should.be.false;

        await ticketSale.sendTransaction({value: ether, data: 0x03});

        const playerCount = await ticketHolder.getPlayersCount();
        playerCount.toNumber().should.be.equals(1);

        const player = await ticketHolder.getTickets(0);
        player[0].should.be.equals(OWNER);
        player[1].toNumber().should.be.equals(10);
        new BigNumber(ether).mul(3).toString().should.be.equals(player[2].toString());

        await ticketSale.sendTransaction({value: ether, from: FIRST, data: 0x0200});
        await ticketSale.sendTransaction({value: ether, from: FIRST});
        await ticketSale.finish();

        utils.increaseTime(web3, 300);
        // after increase time we need to do such shit
        isEnded = await ticketSale.isEnded();
        isEnded = await ticketSale.isEnded();
        isEnded.should.be.true;

        await ticketSale.setWinner(0);
    });

    it("multi buy", async() => {
        const ticketSale = await TicketSale.new(END);
        for (let i = 0; i < 20; i ++) {
            const acc = accounts[i + 1];
            const eth = new BigNumber(ether).plus(new BigNumber(gwei).mul(i));
            await ticketSale.sendTransaction({value: eth, from: acc, data: 0x0150});
        }
    });
});
