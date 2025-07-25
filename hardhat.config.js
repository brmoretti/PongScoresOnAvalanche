/** @type import('hardhat/config').HardhatUserConfig */
require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
	solidity: {
		version: "0.8.30",
		settings: {
			viaIR: true,
			optimizer: {
				enabled: true,
				runs: 200
			}
		}
	},
	networks: {
		// Local development
		hardhat: {
			chainId: 31337
		},
		// Avalanche Mainnet
		avalanche: {
			url: "https://api.avax.network/ext/bc/C/rpc",
			gasPrice: 225000000000,
			chainId: 43114,
			accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : []
		},
		// Avalanche Fuji Testnet (recommended for testing)
		fuji: {
			url: "https://api.avax-test.network/ext/bc/C/rpc",
			gasPrice: 225000000000,
			chainId: 43113,
			accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : []
		}
	},
	paths: {
		sources: "./src",
		tests: "./test",
		cache: "./cache",
		artifacts: "./artifacts"
	}
};
