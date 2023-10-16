require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require('@openzeppelin/hardhat-upgrades');

require("dotenv").config();


module.exports = {
  solidity: {
    version: "0.9.0", // Choose the appropriate version for your contract
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    mumbai: {
      url: "https://rpc-mumbai.maticvigil.com/v1/cbf49a46f64f11243f0d05507ecb0be9484fdcb6", // Replace with your Mumbai testnet RPC URL
      accounts: [process.env.PRIVATE_KEY], // Add your private key as an environment variable for security
    },
  },
 

  etherscan: {
    apiKey: {
      polygonMumbai:"C1YKEWTCTFS3TS4U1PNCCHZ5FNHI9XV6UB"
    }
  }
};
