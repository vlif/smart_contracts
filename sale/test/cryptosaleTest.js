let chai = require("chai");
let chaiAsPromised = require("chai-as-promised");
chai.use(chaiAsPromised);
chai.should();

var BigNumber = require('bignumber.js');

// const utils = require('./utils')
// const Fund = artifacts.require(`${BASE_PATH}/storages/Fund`)
// const Cryptosale = artifacts.require("./Cryptosale.sol");
const Cryptosale = artifacts.require("./Cryptosale");
const ExampleToken = artifacts.require("./ExampleToken.sol");
const FreezingStorage = artifacts.require("./FreezingStorage.sol");
const RateProvider = artifacts.require("./RateProvider.sol");
const CryptosaleRefundVault = artifacts.require("./CryptosaleRefundVault.sol");
const ReferralRefundVault = artifacts.require("./ReferralRefundVault.sol");
const ExampleCrowdsale = artifacts.require("./ExampleCrowdsale.sol");
const TokenHolder = artifacts.require("./tokenHolder.sol");

const DAY = 24 * 3600;
let NOW, YESTERDAY, DAY_BEFORE_YESTERDAY, TOMORROW, DAY_AFTER_TOMORROW;

const initTime = (now) => {
    NOW = now;
    YESTERDAY = now - DAY;
    DAY_BEFORE_YESTERDAY = YESTERDAY - DAY;
    TOMORROW = now + DAY;
    DAY_AFTER_TOMORROW = TOMORROW + DAY;
};

initTime(Math.ceil(new Date("2017-11-13T15:00:00+0300").getTime() / 1000));

contract('Cryptosale', function(accounts) {
    beforeEach(async function () {
        this.owner = accounts[0]

        this.cryptosale = await Cryptosale.new("9999999999999999", accounts[0], 10);
        // this.cryptosale = await Cryptosale.at(Cryptosale.address);
        // console.log(this.cryptosale.address);
        // console.log(await this.cryptosale.tokenHolder.call());

        this.freezingStorage = await FreezingStorage.new(accounts[0], accounts[1]);
        // console.log(this.freezingStorage.address);



    })

    // describe('state', () => {
        // describe('defaults', () => {

        	it ('#0 Accounts', function() {
                accounts.forEach(function (account, index) {
                    web3.eth.getBalance(account, function (_, balance) {
                        console.info("Account " + index + " (" + account + ") balance is " + web3.fromWei(balance, "ether"));
                    });
                });
            });

        	it ('#1 Cryptosale construct', async() => {
                // console.log(this.owner);
                this.cryptosale = await Cryptosale.new("9999999999999999", accounts[0], 10);

                // snapshotId = (await snapshot()).result;
                // console.info(await this.cryptosale.tokenHolder.call());

                (await this.cryptosale.tokenHolder.call()).should.have.length(42);
                (await this.cryptosale.refundVault.call()).should.have.length(42);
                (await this.cryptosale.referralRefundVault.call()).should.have.length(42);

                (await CryptosaleRefundVault.at(await this.cryptosale.refundVault()).tokenHolder())
                	.should.be.equals(await this.cryptosale.tokenHolder(), 'tokenHolder must be');
            	(await ReferralRefundVault.at(await this.cryptosale.referralRefundVault()).tokenHolder())
                	.should.be.equals(await this.cryptosale.tokenHolder(), 'tokenHolder must be');
            });

        // });
    // });

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
    	// console.info(await this.cryptosale.tokenHolder.call());
        // console.info(this.freezingStorage.address);

        this.freezingStorage = await FreezingStorage.new(accounts[0], accounts[1]);
        this.exampleToken = await ExampleToken.new(this.freezingStorage.address);
        // const freezingStorage = await FreezingStorage.deployed(accounts[0], accounts[1]);
    	// const exampleToken = await ExampleToken.deployed(freezingStorage.address);

    	freezingStorage.address.should.be.equals(await exampleToken.FREEZING_STORAGE(), 'FREEZING_STORAGE must be');
        (await exampleToken.balanceOf(freezingStorage.address)).toNumber()
            .should.be.equals(Number(web3.toWei(1, 'ether')), 'balanceOf freezingStorage must be');
    });

    it('#3 Example crowdsale construct', async() => {
        // snapshotId = (await snapshot()).result;
        // const crowdsale = await ExampleCrowdsale.deployed();
        this.cryptosale = await Cryptosale.new("9999999999999999", accounts[0], 10);
        this.exampleToken = await ExampleToken.new(this.freezingStorage.address);

        const tokenHolder = await this.cryptosale.tokenHolder();
        // console.log(tokenHolder);
        // console.log(new Date("2017-11-13T15:00:00+0300").getTime() / 1000);
        this.exampleCrowdsale = await ExampleCrowdsale.new(
            new Date("2017-11-12T15:00:10+0300").getTime() / 1000, //Date.parse("2017-11-13T13:00:00.474Z") / 1000, 
            new Date("2017-12-26T11:00:00+0300").getTime() / 1000, //Date.parse("2017-12-26T11:00:00.474Z") / 1000, 
            web3.toWei(0.01, 'ether'),
            3,
            accounts[0],
            this.exampleToken.address,
            tokenHolder
        );

        (await exampleCrowdsale.token()).should.have.length(42);

        (await this.exampleCrowdsale.hasStarted()).should.be.equals(true);
        (await this.exampleCrowdsale.hasEnded()).should.be.equals(false);
    });

    it('#4 Check Example crowdsale already finished', async() => {
        this.cryptosale = await Cryptosale.new("9999999999999999", accounts[0], 10);
        this.exampleToken = await ExampleToken.new(this.freezingStorage.address);
        const tokenHolder = await this.cryptosale.tokenHolder();
        this.exampleCrowdsale = await ExampleCrowdsale.new(
            DAY_BEFORE_YESTERDAY, 
            YESTERDAY,
            web3.toWei(0.01, 'ether'),
            3,
            accounts[0],
            this.exampleToken.address,
            tokenHolder
        );
        (await this.exampleCrowdsale.hasStarted()).should.be.equals(true);
        (await this.exampleCrowdsale.hasEnded()).should.be.equals(true);
    });
    
    // it('#5 check simple buy token', async() => {
    //     const crowdsale = await Crowdsale.new(YESTERDAY, TOMORROW, HARD_CAP_TOKENS);
    //     const ETH = web3.toWei(1, 'ether');
    //     const TOKENS = ETH * RATE_30;
    //     await crowdsale.sendTransaction({from: BUYER_1, value: ETH});
    //     const token = Token.at(await crowdsale.token());
    //     (await token.balanceOf(BUYER_1)).toNumber().should.be.equals(TOKENS);
    //     (await new Promise (function (resolve, reject) {
    //         web3.eth.getBalance(COLD_WALLET, function (error, result) {
    //             if (error) {
    //                 reject(error);
    //             } else {
    //                 resolve(result);
    //             }
    //         })})).toNumber().should.be.equals(Number(ETH), 'money should be on cold wallet');
    // });

    it('#5 Сheck simple buy token(cryptosale)', async() => {
        this.cryptosale = await Cryptosale.new("9999999999999999", accounts[3], 10);
        this.exampleToken = await ExampleToken.new(this.freezingStorage.address);
        const tokenHolder = TokenHolder.at(await this.cryptosale.tokenHolder());
        this.exampleCrowdsale = await ExampleCrowdsale.new(
            new Date("2017-11-12T15:00:10+0300").getTime() / 1000, //Date.parse("2017-11-13T13:00:00.474Z") / 1000, 
            new Date("2017-12-26T11:00:00+0300").getTime() / 1000, //Date.parse("2017-12-26T11:00:00.474Z") / 1000, 
            web3.toWei(0.01, 'ether'),
            3,
            accounts[0],
            this.exampleToken.address,
            tokenHolder.address
        );

        // 6. Вызывается Сryptosale.setCrowdsale для задания адреса Crowdsale
        // this.cryptosale.setCrowdsale.call(this.exampleCrowdsale.address);
        // console.log(tokenHolder.address);
        this.cryptosale.setCrowdsale(this.exampleCrowdsale.address);
        const tokenHolderCrowdsale = ExampleCrowdsale.at(await tokenHolder.crowdsale.call());
        // console.log(await tokenHolder.crowdsale());
        // console.log(tokenHolderCrowdsale.address);
        (tokenHolderCrowdsale.address)
            .should.be.equals(this.exampleCrowdsale.address, 'tokeHolder crowdsale must be crowdsale');

        // 7. Вызывается Token.transferOwnership для задания корректного владельца токена(нужно, чтобы это был Crowdsale)
        this.exampleToken.transferOwnership(this.exampleCrowdsale.address);
        // console.log(await this.exampleToken.owner());
        (await this.exampleToken.owner())
            .should.be.equals(this.exampleCrowdsale.address, 'token owner must be crowdsale');
        
        // console.log(tokenHolder.address);

        // check rate 
        const rateProvider = RateProvider.at(await this.exampleCrowdsale.rateProvider());
        // console.log((await rateProvider.getRate(tokenHolder.address, 240)).toNumber());
        ((await rateProvider.getRate(tokenHolder.address, 240)).toNumber())
            .should.be.equals(264, 'rate for tokenHolder must be ');

        //9999999999999999 goal
        //240 rate
        //1000000000000000000 amountWei
        //1 999 999 999 999 999 700
        //-10% 100000000000000000
        //900000000000000000
        //890000000000000001
        //9999999999999999
        //264 rate + bonus 10%
        //2639999999999999736
        //10000000 100000000000000000 верно
        // 2000000000000000000 / 264 = 7575757575757575,7575757575757576
        // 7575757575757575 * 264 = 1999999999999999800
        // 7575757575757574,6212121212121212

        // web3.eth.getBalance(accounts[2], function (_, balance) {
        //     console.info(Number(web3.fromWei(balance, "ether"))); //100000
        // });
        // web3.eth.getBalance(accounts[3], function (_, balance) {
        //     console.info(Number(web3.fromWei(balance, "ether"))); //100000
        // });

        // console.log((await this.exampleToken.totalSupply()).toNumber()); // 1000000000000000000
        // console.log((await this.exampleToken.balanceOf(tokenHolder.address)).toNumber()); // 0

        const ETH = web3.toWei(1, 'ether');
        // console.log(ETH);
        await this.cryptosale.sendTransaction({from: accounts[2], value: ETH});
        // web3.eth.getBalance(accounts[2], function (_, balance) {
        //     console.info(Number(web3.fromWei(balance, "ether"))); //100000
        // });
        // console.log((await this.exampleToken.balanceOf(accounts[2])));
        // console.log((await this.exampleToken.balanceOf(tokenHolder.address))); // 1999999999999999800
        // console.log((await this.exampleToken.totalSupply())); // 2999999999999999800
        // web3.eth.getBalance(tokenHolder.address, function (_, balance) {
        //     console.info(Number(web3.fromWei(balance, "ether"))); //100000
        // });
        // web3.eth.getBalance(accounts[3], function (_, balance) {
        //     console.info(balance.toNumber()); //Number( //100000
        // });
        // console.log((await this.exampleToken.totalSupply()).toString(10));
        (Number(await this.exampleToken.balanceOf(accounts[2])))
            .should.be.equals(0, 'Balance of account[2] should be');

        let bignum1 = new BigNumber(await this.exampleToken.balanceOf(tokenHolder.address));
        let bignum2 = new BigNumber('1999999999999999800');
        bignum1.toNumber().should.be.equals(bignum2.toNumber(), 'Balance of tokenHolder should be');
        
        let bignum3 = new BigNumber(await this.exampleToken.totalSupply());
        let bignum4 = new BigNumber('2999999999999999800');
        // console.log(bignum1);
        // console.log(bignum2);
        bignum3.toNumber().should.be.equals(bignum4.toNumber(), 'totalSupply must be');
    });



});