// Compile TournamentHelper contract using solcjs
const path = require('path');
const fs = require('fs');
const solc = require('solc');

// Contract paths
const contractsDir = path.resolve(__dirname, '../src');
const outputDir = path.resolve(__dirname, '../contracts');

// Ensure output directory exists
if (!fs.existsSync(outputDir)) {
	fs.mkdirSync(outputDir, { recursive: true });
}

// Read all contract files
const contracts = {
	'playersfactory.sol': fs.readFileSync(path.join(contractsDir, 'playersfactory.sol'), 'utf8'),
	'playershelper.sol': fs.readFileSync(path.join(contractsDir, 'playershelper.sol'), 'utf8'),
	'playersactions.sol': fs.readFileSync(path.join(contractsDir, 'playersactions.sol'), 'utf8'),
	'tournamentfactory.sol': fs.readFileSync(path.join(contractsDir, 'tournamentfactory.sol'), 'utf8'),
	'tournamenthelper.sol': fs.readFileSync(path.join(contractsDir, 'tournamenthelper.sol'), 'utf8')
};

const input = {
	language: 'Solidity',
	sources: {},
	settings: {
		viaIR: true,
		optimizer: {
			enabled: true,
			runs: 200
		},
		outputSelection: {
			'*': {
				'*': ['*'],
			},
		},
	},
};

// Add all contracts to input
Object.keys(contracts).forEach(filename => {
	input.sources[filename] = {
		content: contracts[filename],
	};
});

console.log('Compiling contracts...');
const output = JSON.parse(solc.compile(JSON.stringify(input)));

if (output.errors) {
	output.errors.forEach((err) => {
		if (err.severity === 'error') {
			console.error('❌ Error:', err.formattedMessage);
		} else {
			console.warn('⚠️  Warning:', err.formattedMessage);
		}
	});

	// Check if there are any errors (not just warnings)
	const hasErrors = output.errors.some(err => err.severity === 'error');
	if (hasErrors) {
		console.error('Compilation failed due to errors.');
		process.exit(1);
	}
}

// Write compiled contracts
Object.keys(output.contracts).forEach(filename => {
	Object.keys(output.contracts[filename]).forEach(contractName => {
		const contract = output.contracts[filename][contractName];
		const outputPath = path.join(outputDir, `${contractName}.json`);

		fs.writeFileSync(outputPath, JSON.stringify({
			abi: contract.abi,
			bytecode: contract.evm.bytecode.object,
			metadata: contract.metadata
		}, null, 2));

		console.log(`✅ Compiled ${contractName} -> ${outputPath}`);
	});
});

console.log('Compilation completed successfully!');
