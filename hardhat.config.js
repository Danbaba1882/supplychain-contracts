require("@nomiclabs/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");
require("@nomiclabs/hardhat-etherscan");
require('dotenv').config()

module.exports = {
  solidity: "0.8.4",
  networks: {
    mumbai: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      accounts: ["0cef0c137c64172ed1f9acf5aaae51b8c78663a094a7c80a930564235e934ebf"]
    },
  //   polygon: {
  //     url: process.env.BLOCKCHAINSERV,
  //     accounts: [process.env.PRIVATE_KEY]
  // },
  },
  etherscan: {
    apiKey: "RXASATC5GEMWRHARSDNFF5Y6E8JWGJUCUV",
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 20000
  }
};