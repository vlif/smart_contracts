let chai = require("chai");
let chaiAsPromised = require("chai-as-promised");
chai.use(chaiAsPromised);
chai.should();


const QuickSort = artifacts.require("./QuickSort.sol");
const QuickSorter = artifacts.require("./QuickSorter.sol");


contract('QuickSort', function(accounts) {

	it ('#0 Accounts', function() {
        accounts.forEach(function (account, index) {
            web3.eth.getBalance(account, function (_, balance) {
                console.info("Account " + index + " (" + account + ") balance is " + web3.fromWei(balance, "ether"));
            });
        });
    });

	it ('#1 Generate test', async() => {
        // console.log(this.owner);
        const quickSort = await QuickSort.new();
        console.log(quickSort.address);

 		(await quickSort.generate(50));
 		// console.log((await quickSort.data(0)).toNumber());
 		console.log((await quickSort.data(49)).toNumber());
 		console.log(await quickSort.data.length);

    	// (await quickSort.data.length).should.be.equals(50, 'data length must be');
    	(true).should.be.equals(true);
    });

    it ('#2 Sort test (50)', async() => {
        // console.log(this.owner);
        const quickSort = await QuickSort.new();
        console.log(quickSort.address);

 		(await quickSort.generate(50));
 		console.log((await quickSort.data(10)).toNumber());

 		//(await quickSort.sort());
 		// var myCallData = quickSort.sort.getData();
 		// var result = web3.eth.estimateGas({
 		// 	to: quickSort.address,
 		// 	data: "8cdc86a62d49a958b6cfeba663c1931551e442d5917f5e60f23de1cd3e5ef6d3"
 		// 	// data: bytes4(sha3("await sort()"))
 		// });
 		// console.log(result);
 		
 		let gas = await quickSort.sort.estimateGas();
 		(await quickSort.sort());
 		console.log(gas);

 		// console.log((await quickSort.data(0)).toNumber());
 		console.log((await quickSort.data(10)).toNumber());
 		// for (let i = 0; i < 50; i++) {
 		// 	console.log((await quickSort.data(i)).toNumber());
 		// }

 		// console.log(web3.eth.msg.gas);

    	// (await quickSort.data.length).should.be.equals(50, 'data length must be');
    	(true).should.be.equals(true);
    });

   //  it ('#3 test', function() {
   //  	return QuickSort.new().then(function(quickSort) {
   //  		// const quickSort = quickSort;
   //  		// console.log(quickSort.address);

   //  		quickSort.generate(50).then(function() {
   //  			return quickSort.data(10).then(function(ten) {
   //  				// console.log(ten.toNumber());

   //  				return web3.eth.estimateGas({ //var result = 
			//  			to: quickSort.address,
			//  			// data: "8cdc86a62d49a958b6cfeba663c1931551e442d5917f5e60f23de1cd3e5ef6d3"
			//  			data: web3.sha3("sort()")
			//  		}, function(err, transactionHash) {
			//  			console.log(transactionHash);
			//  			// web3.eth.getTransaction(transactionHash, function(error, result) {
			//  			// 	console.log(result);
			//  			// });
			//  			web3.eth.getTransactionReceipt(transactionHash, function(error, result) {
			// 				console.log(result);
			//  			});
			//  		});
			//  		// console.log(result);

   //  			});
   //  		});

   //  		(true).should.be.equals(true);
	 	// });
   //  });

   it ('#2 Sort test (100)', async() => {
        // console.log(this.owner);
        const quickSort = await QuickSort.new();
        console.log(quickSort.address);

 		(await quickSort.generate(100));
 		console.log((await quickSort.data(50)).toNumber());

 		//(await quickSort.sort());
 		// var myCallData = quickSort.sort.getData();
 		// var result = web3.eth.estimateGas({
 		// 	to: quickSort.address,
 		// 	data: "8cdc86a62d49a958b6cfeba663c1931551e442d5917f5e60f23de1cd3e5ef6d3"
 		// 	// data: bytes4(sha3("await sort()"))
 		// });
 		// console.log(result);
 		
 		let gas = await quickSort.sort.estimateGas();
 		(await quickSort.sort());
 		console.log(gas);

 		// console.log((await quickSort.data(0)).toNumber());
 		console.log((await quickSort.data(50)).toNumber());
 		// for (let i = 0; i < 50; i++) {
 		// 	console.log((await quickSort.data(i)).toNumber());
 		// }

 		// console.log(web3.eth.msg.gas);

    	// (await quickSort.data.length).should.be.equals(50, 'data length must be');
    	(true).should.be.equals(true);
    });

   it ('#2 Sort test (150)', async() => {
        // console.log(this.owner);
        const quickSort = await QuickSort.new();
        console.log(quickSort.address);

    (await quickSort.generate(150));
    console.log((await quickSort.data(75)).toNumber());

    //(await quickSort.sort());
    // var myCallData = quickSort.sort.getData();
    // var result = web3.eth.estimateGas({
    //  to: quickSort.address,
    //  data: "8cdc86a62d49a958b6cfeba663c1931551e442d5917f5e60f23de1cd3e5ef6d3"
    //  // data: bytes4(sha3("await sort()"))
    // });
    // console.log(result);
    
    let gas = await quickSort.sort.estimateGas();
    (await quickSort.sort());
    console.log(gas);

    // console.log((await quickSort.data(0)).toNumber());
    console.log((await quickSort.data(75)).toNumber());
    // for (let i = 0; i < 50; i++) {
    //  console.log((await quickSort.data(i)).toNumber());
    // }

    // console.log(web3.eth.msg.gas);

      // (await quickSort.data.length).should.be.equals(50, 'data length must be');
      (true).should.be.equals(true);
    });

});