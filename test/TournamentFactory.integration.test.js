const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TournamentFactory Integration", function () {
	let TournamentFactory;
	let factory;
	let owner;

	beforeEach(async function () {
		[owner] = await ethers.getSigners();
		TournamentFactory = await ethers.getContractFactory("TournamentFactory");
		factory = await TournamentFactory.deploy();
		await factory.waitForDeployment();
	});

	it("Should create players and a tournament, then print all players and tournaments", async function () {
		// Create players
		const names = ["Alice", "Bob", "Charlie", "Diana", "Olaf", "Peter"];
		for (let i = 0; i < names.length; i++) {
			await factory.createPlayer(names[i], false);
		}
		const playerCount = await factory.playerCount();
		console.log("Players created:");
		for (let i = 0; i < playerCount; i++) {
			const player = await factory.players(i);
			console.log(`Player ${i}: Name=${player.name}, isAi=${player.isAi}, ID=${player.playerId}, Wins=${player.winCount}, Losses=${player.lossCount}`);
		}

		// Create tournament using helper function
		let playerIds = [0, 1, 2, 3];
		await createTournament(playerIds, "Test Tournament");
		playerIds = [3, 1, 0];
		await createTournament(playerIds, "With AI");
		playerIds = [3, 2, 1];
		await createTournament(playerIds, "Reutilizing AI");
		playerIds = [0, 1, 2, 3, 4, 5];
		await createTournament(playerIds, "Bigger Tournament");
		await printTournaments();
	});

	async function createTournament(playerIds, tournamentName) {
		await factory.createTournament(tournamentName, playerIds);
	}

	async function printTournaments() {
		const tournamentCount = await factory.tournamentCount();
		console.log("\nTournaments created:");
		for (let i = 0; i < tournamentCount; i++) {
			const tournament = await factory.tournaments(i);
			console.log(`Tournament ${i}: Name=${tournament.name}, ID=${tournament.tournamentId}`);
			// Print matches
			const matches = await factory.getTournamentMatches(i);
			for (let j = 0; j < matches.length; j++) {
				const match = matches[j];
				console.log(`  Match ${j}: Player1=${match.player1Id}, Player2=${match.player2Id}, MatchID=${match.matchId}`);
			}
		}
	}
});
