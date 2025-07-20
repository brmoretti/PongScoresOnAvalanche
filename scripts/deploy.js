// Deploy TournamentHelper contract
require('dotenv').config();
const fs = require('fs');
const path = require('path');
const { ethers } = require('ethers');

const CONTRACT_JSON = path.resolve(__dirname, '../contracts/TournamentHelper.json');
const contractJson = JSON.parse(fs.readFileSync(CONTRACT_JSON));

async function main() {
	const provider = new ethers.JsonRpcProvider(process.env.AVALANCHE_RPC_URL);
	const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

	console.log('Deploying TournamentHelper contract...');
	console.log('Deployer address:', wallet.address);

	const factory = new ethers.ContractFactory(contractJson.abi, contractJson.bytecode, wallet);

	try {
		const contract = await factory.deploy();
		await contract.waitForDeployment();

		const contractAddress = await contract.getAddress();
		console.log('✅ TournamentHelper deployed at:', contractAddress);

		// Save deployment info
		const deploymentInfo = {
			address: contractAddress,
			deployer: wallet.address,
			timestamp: new Date().toISOString(),
			network: process.env.AVALANCHE_RPC_URL
		};

		fs.writeFileSync(
			path.resolve(__dirname, '../deployment.json'),
			JSON.stringify(deploymentInfo, null, 2)
		);

		console.log('Deployment info saved to deployment.json');
		console.log('Run tests with: npm run test', contractAddress);

	} catch (error) {
		console.error('Deployment failed:', error.message);
		process.exit(1);
	}
}

main().catch(console.error);
