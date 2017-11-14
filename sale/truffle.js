const TestRPC = require("ethereumjs-testrpc");
const ether = '0000000000000000000';
module.exports = {
	// See <http://truffleframework.com/docs/advanced/configuration>
	// to customize your Truffle configuration!
	networks: {
        test: {
            network_id: "*",
            provider: TestRPC.provider({
                accounts: [10, 100, 10000, 1000000].map(function (v) {
                    return {balance: "" + v + ether};
                }),
                // time: new Date("2017-11-13T15:00:00Z")
                time: new Date("2017-11-13T15:00:00+0300")
            }),
            gas: 4000000
        }
    },
    network: 'test',
    solc: {
        optimizer: {
            enabled: true,
            runs: 200
        }
    }
};