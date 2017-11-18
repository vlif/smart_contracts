const chai = require("chai");
const chaiAsPromised = require("chai-as-promised");
chai.use(chaiAsPromised);
chai.should();

const BigNumber = require("bignumber.js");
// const utils = require("./utils");
const DreamData = artifacts.require("./DreamData.sol");

// const ether = web3.toWei(1, 'ether');
// const gwei = web3.toWei(1, 'gwei');
// const END = new Date("2017-10-10T16:00:00Z").getTime() / 1000;

contract('DreamData', function (accounts) {
    it("2 digits", async() => {
        const data = await DreamData.new();

        const receipt = await data.sendTransaction({data: 0x0123});
        console.log(receipt.logs[0].args);
    });

    it("1 digits", async() => {
        const data = await DreamData.new();

        const receipt = await data.sendTransaction({data: 0x04});
        console.log(receipt.logs[0].args);
    });
});
