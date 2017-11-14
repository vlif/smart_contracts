const QuickSort = artifacts.require("./QuickSort.sol");
const QuickSorter = artifacts.require("./QuickSorter.sol");

const InsertionSort = artifacts.require("./InsertionSort.sol");
const InsertionSorter = artifacts.require("./InsertionSorter.sol");

module.exports = function(deployer, network, accounts) { 
	deployer.deploy(QuickSorter);
	deployer.link(QuickSorter, QuickSort);
	deployer.deploy(QuickSort);

	deployer.deploy(InsertionSorter);
	deployer.link(InsertionSorter, InsertionSort);
	deployer.deploy(InsertionSort);
}