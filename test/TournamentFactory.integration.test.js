const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TournamentFactory Integration", function () {
	let TournamentActions;
	let factory;
	let owner;

	beforeEach(async function () {
		[owner] = await ethers.getSigners();
		// Deploy TournamentActions instead of TournamentHelper to access endMatch function
		TournamentActions = await ethers.getContractFactory("TournamentActions");
		factory = await TournamentActions.deploy();
		await factory.waitForDeployment();
	});

	it("Should create players and tournaments, then run complete tournament", async function () {
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

		// Create smaller tournaments first
		let playerIds = [0, 1, 2, 3];
		await createTournament(playerIds, "Test Tournament");

		// Create the bigger tournament that we'll complete
		playerIds = [0, 1, 2, 3, 4, 5];
		await createTournament(playerIds, "Bigger Tournament");

		await printTournaments();

		// Run the complete tournament (tournament ID 1 = "Bigger Tournament")
		await runCompleteTournament(1);
	});

	async function createTournament(playerIds, tournamentName) {
		await factory.createTournament(tournamentName, playerIds);
	}

	async function printTournaments() {
		const tournamentCount = await factory.tournamentCount();
		console.log("\nTournaments created:");
		for (let i = 0; i < tournamentCount; i++) {
			const tournament = await factory.tournaments(i);
			console.log(`Tournament ${i}: Name=${tournament.name}, ID=${tournament.tournamentId}, Ended=${tournament.ended}`);
			// Print matches
			const matches = await factory.getTournamentMatches(i);
			for (let j = 0; j < matches.length; j++) {
				const match = matches[j];
				console.log(`  Match ${j}: Player1=${match.player1Id}, Player2=${match.player2Id}, MatchID=${match.matchId}, Level=${match.level}, Score=${match.player1Score}-${match.player2Score}`);
			}
		}
	}

	async function runCompleteTournament(tournamentId) {
		console.log(`\n🏆 Starting Complete Tournament Run for Tournament ID: ${tournamentId}`);

		let matchCounter = 1;
		let tournamentEnded = false;

		while (!tournamentEnded) {
			// Get next match
			let nextMatchId;
			try {
				nextMatchId = await factory.getNextTournamentMatch(tournamentId);
			} catch (error) {
				console.log(`Error getting next match: ${error.message}`);
				break;
			}

			if (nextMatchId === 0xFFFF || nextMatchId === 65535) {
				console.log("No more matches to play!");
				break;
			}

			try {
				const match = await factory.matches(nextMatchId);
				console.log(`\n⚽ Match ${matchCounter}: Playing Match ID ${nextMatchId}`);
				console.log(`   Player ${match.player1Id} vs Player ${match.player2Id} (Level ${match.level})`);

				// Generate random scores (ensuring no tie)
				let player1Score, player2Score;
				do {
					player1Score = Math.floor(Math.random() * 5) + 1; // 1-5
					player2Score = Math.floor(Math.random() * 5) + 1; // 1-5
				} while (player1Score === player2Score); // Avoid ties

				console.log(`   Score: ${player1Score} - ${player2Score}`);

				// End the match
				const tx = await factory.endMatch(nextMatchId, player1Score, player2Score);
				const receipt = await tx.wait();

				// Check for events
				const matchEndedEvent = receipt.logs.find(log => {
					try {
						const parsed = factory.interface.parseLog(log);
						return parsed.name === "MatchEnded";
					} catch {
						return false;
					}
				});

				const tournamentEndedEvent = receipt.logs.find(log => {
					try {
						const parsed = factory.interface.parseLog(log);
						return parsed.name === "TournamentEnded";
					} catch {
						return false;
					}
				});

				if (matchEndedEvent) {
					const parsedEvent = factory.interface.parseLog(matchEndedEvent);
					console.log(`   ✅ Match ${parsedEvent.args.matchId} ended`);
				}

				if (tournamentEndedEvent) {
					const parsedEvent = factory.interface.parseLog(tournamentEndedEvent);
					console.log(`   🏆 Tournament ${parsedEvent.args.tournamentId} ended!`);
					tournamentEnded = true;
				}

				// Winner announcement
				const winner = player1Score > player2Score ? match.player1Id : match.player2Id;
				console.log(`   🏅 Winner: Player ${winner}`);

				matchCounter++;

				// Print current tournament state
				console.log("\n📊 Current Tournament State:");
				await printSingleTournament(tournamentId);

			} catch (error) {
				console.log(`❌ Error with match ${nextMatchId}: ${error.message}`);
				break;
			}

			// Safety check to avoid infinite loop
			if (matchCounter > 20) {
				console.log("Safety break - too many matches!");
				break;
			}
		}

		console.log("\n🎊 Tournament completed!");

		// Final tournament state
		console.log("\n📋 Final Tournament State:");
		await printSingleTournament(tournamentId);
	}

	async function printSingleTournament(tournamentId) {
		const tournament = await factory.tournaments(tournamentId);
		console.log(`Tournament ${tournamentId}: Name=${tournament[1]}, Ended=${tournament[0]}`);

		const matches = await factory.getTournamentMatches(tournamentId);
		for (let j = 0; j < matches.length; j++) {
			const match = matches[j];
			const status = (match.player1Score === 0 && match.player2Score === 0) ? "⏳ Pending" : "✅ Completed";
			console.log(`  Match ${j}: Player${match.player1Id} vs Player${match.player2Id} | ${match.player1Score}-${match.player2Score} | Level ${match.level} | ${status}`);
		}
	}
});
