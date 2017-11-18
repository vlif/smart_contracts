const TicketSale = artifacts.require('./TicketSale.sol');

module.exports = function (deployer) {
    deployer.deploy(TicketSale, new Date("2017-10-10T16:00:00Z").getTime() / 1000);
};
