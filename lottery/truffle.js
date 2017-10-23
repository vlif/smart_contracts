module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*"
    },
    test: {
      host: "localhost",
      port: 8545,
      network_id: "*",
      from: "0x1b3bAeE0841ea8f9649A9Ee277ceD5379874d5E6"
    },
    ropsten: {
      host: "localhost",
      port: 8545,
      network_id: "*",
      from: "0x70535d2fff3bb7e800dd140c0bffac12689a248d"
    },
    valenki: {
      host: "valenki.team",
      port: 8545,
      network_id: "*",
      from: "0x09d3521bc88e27e6e0ae0469a17b4f914ec914ab"
    },
    docker: {
      host: "dockerhost",
      port: 8545,
      network_id: "*",
      from: "0x09d3521bc88e27e6e0ae0469a17b4f914ec914ab"
    },
  }
};
