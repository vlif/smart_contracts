// const MyWishCrowdsale = artifacts.require("./MyWishCrowdsale.sol");

// module.exports = function(deployer) {
//   deployer.deploy(MyWishCrowdsale, new Date("2017-10-25T9:00:00Z+0300").getTime() / 1000, new Date("2017-11-26T11:00:00Z+0300").getTime() / 1000, 22000000);
// };

// const SafeMath = artifacts.require('./base/math/SafeMath.sol');
// const Ownable = artifacts.require('./base/ownership/Ownable.sol');

const Cryptosale = artifacts.require("./Cryptosale.sol");
const ExampleToken = artifacts.require("./ExampleToken.sol");
const FreezingStorage = artifacts.require("./FreezingStorage.sol");

// web3.eth.getAccounts()
module.exports = function(deployer, network, accounts) { 
	// Use the accounts within your migrations.

	// deployer.deploy(SafeMath);
	// deployer.deploy(Ownable);

	deployer.deploy(Cryptosale,
		"9999999999999999", 
		accounts[0], //"0xca35b7d915458ef540ade6068dfe2f44e8fa733c"
		10
		, {overwrite: false}
	);

	deployer.deploy(FreezingStorage,
		accounts[0], //"0xca35b7d915458ef540ade6068dfe2f44e8fa733c"
		accounts[1] //"0xdd870fa1b7c4700f2bd7f44238821c26f7392148"
		, {overwrite: false}
	).then(function() {
		return deployer.deploy(
			ExampleToken, 
			FreezingStorage.address
			, {overwrite: false}
		);
	});
	
};