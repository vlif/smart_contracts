var Migrations = artifacts.require("./misc/Migrations.sol");

module.exports = function(deployer) {
	// Deploy the Migrations contract as our only task
	deployer.deploy(Migrations);
};
