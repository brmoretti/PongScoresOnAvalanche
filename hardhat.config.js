/** @type import('hardhat/config').HardhatUserConfig */
require("@nomicfoundation/hardhat-toolbox");

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
	paths: {
		sources: "./src",
		tests: "./test",
		cache: "./cache",
		artifacts: "./artifacts"
	}
};
