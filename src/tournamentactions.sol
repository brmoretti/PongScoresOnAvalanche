// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "./tournamenthelper.sol";

contract TournamentActions is TournamentHelper {

	function _scoreRegister(
		uint16 tournamentId,
		uint16 matchId,
		uint8 player1Score,
		uint8 player2Score) private {
		tournaments[tournamentId].matches[matchId].player1Score = player1Score;
		tournaments[tournamentId].matches[matchId].player2Score = player2Score;
	}

	function _addMatch(
		uint16 tournamentId,
		Match memory matchToAdd)
		checkTournamentExistence(tournamentId) private {
		tournaments[tournamentId].matches.push(matchToAdd);
		matchCount++;
	}

	function endMatch (uint16 tournamentId,
		uint16 matchId,
		uint8 player1Score,
		uint8 player2Score)
		checkTournamentExistence(tournamentId)
		checkMatchExistence(matchId) public {
		_scoreRegister(tournamentId, matchId, player1Score, player2Score);
		Tournament storage tournament = tournaments[tournamentId];

		uint16 winner = player1Score > player2Score ?
				tournament.matches[matchId].player1Id :
				tournament.matches[matchId].player2Id;

		uint8 level = tournament.matches[matchId].level;

		if (level == tournament.matches[tournament.matches.length - 1].level) {
			Match memory newMatch = Match({
				matchId: matchCount,
				player1Id: winner,
				player2Id: 0xFFFF,
				player1Score: 0,
				player2Score: 0,
				level: level + 1
			});
			_addMatch(tournamentId, newMatch);
		} else if (level == tournament.matches[tournament.matches.length - 1].level - 1) {
			tournament.matches[tournament.matches.length - 1].player2Id = winner;
		}
	}

}
