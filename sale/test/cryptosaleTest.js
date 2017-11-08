let chai = require("chai");
let chaiAsPromised = require("chai-as-promised");
chai.use(chaiAsPromised);
chai.should();

// const utils = require('./utils')
const Cryptosale = artifacts.require("./Cryptosale.sol");
const ExampleToken = artifacts.require("./ExampleToken.sol");
const FreezingStorage = artifacts.require("./FreezingStorage.sol");
const RateProvider = artifacts.require("./RateProvider.sol");
const CryptosaleRefundVault = artifacts.require("./CryptosaleRefundVault.sol");
const ReferralRefundVault = artifacts.require("./ReferralRefundVault.sol");
const ExampleCrowdsale = artifacts.require("./ExampleCrowdsale.sol");


contract('Cryptosale', function(accounts) {

	it ('#0', function() {
        accounts.forEach(function (account, index) {
            web3.eth.getBalance(account, function (_, balance) {
                console.info("Account " + index + " (" + account + ") balance is " + web3.fromWei(balance, "ether"));
            });
        });
    });

	it ('#1 Cryptosale construct', async() => {
        // snapshotId = (await snapshot()).result;
        const cryptosale = await Cryptosale.deployed("9999999999999999", accounts[0], 10);
        (await cryptosale.tokenHolder()).should.have.length(42);
        (await cryptosale.refundVault()).should.have.length(42);
        (await cryptosale.referralRefundVault()).should.have.length(42);

        (await CryptosaleRefundVault.at(await cryptosale.refundVault()).tokenHolder())
        	.should.be.equals(await cryptosale.tokenHolder(), 'tokenHolder must be');
    	(await ReferralRefundVault.at(await cryptosale.referralRefundVault()).tokenHolder())
        	.should.be.equals(await cryptosale.tokenHolder(), 'tokenHolder must be');
    });

    // it ('#2', async() => {
    // 	await Cryptosale.deployed("9999999999999999", accounts[0], 10)
    // 		.then(function(cryptosale) {
    // 			cryptosale.isFinalized()
    // 				.then(function(finalized) {
    // 					console.info(finalized);
    // 				});
    // 		});
    // });

    it ('#2 Example token construct', async() => {
    	const freezingStorage = await FreezingStorage.deployed(accounts[0], accounts[1]);
    	const exampleToken = await ExampleToken.deployed(freezingStorage.address);
    	freezingStorage.address.should.be.equals(await exampleToken.FREEZING_STORAGE(), 'FREEZING_STORAGE must be');
        (await exampleToken.balanceOf(freezingStorage.address)).toNumber()
            .should.be.equals(Number(web3.toWei(1, 'ether')), 'balanceOf freezingStorage must be');
    });

    it('#3 Example crowdsale construct', async() => {
        // snapshotId = (await snapshot()).result;
        const crowdsale = await ExampleCrowdsale.deployed();
        (await crowdsale.token()).should.have.length(42);
    });
    
});