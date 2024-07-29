require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();


/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.0",
  networks: {
    matic: {

      url: `https://rpc.ankr.com/polygon_amoy	`, 
      accounts: [`0x${process.env.PRIVATE_KEY}`] // Private key from your .env file
    },
  },
};
