// const MyWishCrowdsale = artifacts.require("./MyWishCrowdsale.sol");

// module.exports = function(deployer) {
//   deployer.deploy(MyWishCrowdsale, new Date("2017-10-25T9:00:00+0300").getTime() / 1000, new Date("2017-11-26T11:00:00+0300").getTime() / 1000, 22000000);
// };

// const SafeMath = artifacts.require('./base/math/SafeMath.sol');
// const Ownable = artifacts.require('./base/ownership/Ownable.sol');

const Cryptosale = artifacts.require("./Cryptosale.sol");
const ExampleToken = artifacts.require("./ExampleToken.sol");
const FreezingStorage = artifacts.require("./FreezingStorage.sol");
const ExampleCrowdsale = artifacts.require("./ExampleCrowdsale.sol");

// web3.eth.getAccounts()
module.exports = function(deployer, network, accounts) { 
	// Use the accounts within your migrations.

	// deployer.deploy(SafeMath);
	// deployer.deploy(Ownable);

	// var cryptosale;

	return deployer.deploy(Cryptosale,
		"9999999999999999", 
		accounts[0], //"0xca35b7d915458ef540ade6068dfe2f44e8fa733c"
		10
		// , {overwrite: false}
	).then(function() {

		return deployer.deploy(FreezingStorage,
			accounts[0], //"0xca35b7d915458ef540ade6068dfe2f44e8fa733c"
			accounts[1] //"0xdd870fa1b7c4700f2bd7f44238821c26f7392148"
			// , {overwrite: false}
		).then(function() {
			return deployer.deploy(
				ExampleToken,
				FreezingStorage.address
				// , {overwrite: false}
			);
		}).then(function() {
			return Cryptosale.deployed();
		}).then(function(instance) {
			var cryptosale = instance; //Cryptosale.deployed()

			return cryptosale.tokenHolder().then(function(tokenHolderInstance) {
				// console.info(Date.parse("2017-11-13T13:00:00.474Z")); //2017-11-08T11:02:23.474Z
				// console.info(new Date("2017-11-09T09:00:00+0300"));
				// console.info(web3.toWei(0.01, 'ether'));
				// console.info(accounts[0]);
				// console.info(ExampleToken.address);
				// console.info(tokenHolderInstance);

				// uint32 _startTime,
				// uint32 _endTime,
				// // uint _rate,
				// uint _softCapWei, // 0.01
				// uint _hardCapTokens, // 3
				// address _wallet,
				// address _token,
				// address _tokenHolder 
				return deployer.deploy(ExampleCrowdsale,
					new Date("2017-11-13T15:00:01+0300").getTime() / 1000, //Date.parse("2017-11-13T13:00:00.474Z") / 1000, 
					new Date("2017-12-26T11:00:00+0300").getTime() / 1000, //Date.parse("2017-12-26T11:00:00.474Z") / 1000, 
					web3.toWei(0.01, 'ether'),
					3,
					accounts[0],
					ExampleToken.address,
					tokenHolderInstance //.address
				);

			});

		});

	});
	
};