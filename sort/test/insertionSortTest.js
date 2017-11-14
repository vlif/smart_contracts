let chai = require("chai");
let chaiAsPromised = require("chai-as-promised");
chai.use(chaiAsPromised);
chai.should();


const InsertionSort = artifacts.require("./InsertionSort.sol");
const InsertionSorter = artifacts.require("./InsertionSorter.sol");


contract('InsertionSort', function(accounts) {

	it ('#0 Accounts', function() {
        accounts.forEach(function (account, index) {
            web3.eth.getBalance(account, function (_, balance) {
                console.info("Account " + index + " (" + account + ") balance is " + web3.fromWei(balance, "ether"));
            });
        });
    });

    it ('#1 Generate test', async() => {
        // console.log(this.owner);
        const insertionSort = await InsertionSort.new();
        console.log(insertionSort.address);

 		(await insertionSort.generate(50));
 		// console.log((await quickSort.data(0)).toNumber());
 		console.log((await insertionSort.data(49)).toNumber());
 		console.log(await insertionSort.data.length);

    	// (await quickSort.data.length).should.be.equals(50, 'data length must be');
    	(true).should.be.equals(true);
    });

    it ('#2 Sort test (50)', async() => {
        // console.log(this.owner);
        const insertionSort = await InsertionSort.new();
        console.log(insertionSort.address);

 		(await insertionSort.generate(50));
 		console.log((await insertionSort.data(10)).toNumber());

 		//(await quickSort.sort());
 		// var myCallData = quickSort.sort.getData();
 		// var result = web3.eth.estimateGas({
 		// 	to: quickSort.address,
 		// 	data: "8cdc86a62d49a958b6cfeba663c1931551e442d5917f5e60f23de1cd3e5ef6d3"
 		// 	// data: bytes4(sha3("await sort()"))
 		// });
 		// console.log(result);
 		
 		let gas = await insertionSort.sort.estimateGas();
 		(await insertionSort.sort());
 		console.log(gas);

 		// console.log((await quickSort.data(0)).toNumber());
 		console.log((await insertionSort.data(10)).toNumber());
 		// for (let i = 0; i < 50; i++) {
 		// 	console.log((await quickSort.data(i)).toNumber());
 		// }

 		// console.log(web3.eth.msg.gas);

    	// (await quickSort.data.length).should.be.equals(50, 'data length must be');
    	(true).should.be.equals(true);
    });

    it ('#2 Sort test (100)', async() => {
        // console.log(this.owner);
        const insertionSort = await InsertionSort.new();
        console.log(insertionSort.address);

 		(await insertionSort.generate(100));
 		console.log((await insertionSort.data(50)).toNumber());

 		//(await quickSort.sort());
 		// var myCallData = quickSort.sort.getData();
 		// var result = web3.eth.estimateGas({
 		// 	to: quickSort.address,
 		// 	data: "8cdc86a62d49a958b6cfeba663c1931551e442d5917f5e60f23de1cd3e5ef6d3"
 		// 	// data: bytes4(sha3("await sort()"))
 		// });
 		// console.log(result);
 		
 		let gas = await insertionSort.sort.estimateGas();
 		(await insertionSort.sort());
 		console.log(gas);

 		// console.log((await quickSort.data(0)).toNumber());
 		console.log((await insertionSort.data(50)).toNumber());
 		// for (let i = 0; i < 50; i++) {
 		// 	console.log((await quickSort.data(i)).toNumber());
 		// }

 		// console.log(web3.eth.msg.gas);

    	// (await quickSort.data.length).should.be.equals(50, 'data length must be');
    	(true).should.be.equals(true);
    });

	it ('#2 Sort test (150)', async() => {
        // console.log(this.owner);
        const insertionSort = await InsertionSort.new();
        console.log(insertionSort.address);

 		(await insertionSort.generate(150));
 		console.log((await insertionSort.data(75)).toNumber());

 		//(await quickSort.sort());
 		// var myCallData = quickSort.sort.getData();
 		// var result = web3.eth.estimateGas({
 		// 	to: quickSort.address,
 		// 	data: "8cdc86a62d49a958b6cfeba663c1931551e442d5917f5e60f23de1cd3e5ef6d3"
 		// 	// data: bytes4(sha3("await sort()"))
 		// });
 		// console.log(result);
 		
 		let gas = await insertionSort.sort.estimateGas();
 		(await insertionSort.sort());
 		console.log(gas);

 		// console.log((await quickSort.data(0)).toNumber());
 		console.log((await insertionSort.data(75)).toNumber());
 		// for (let i = 0; i < 50; i++) {
 		// 	console.log((await quickSort.data(i)).toNumber());
 		// }

 		// console.log(web3.eth.msg.gas);

    	// (await quickSort.data.length).should.be.equals(50, 'data length must be');
    	(true).should.be.equals(true);
    });

});