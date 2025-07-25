// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "./tournamenthelper.sol";

contract TournamentActions is TournamentHelper {

	event MatchEnded(uint16 matchId);
	event TournamentEnded(uint16 tournamentId);

	function _scoreRegister(
		uint16 matchId,
		uint8 player1Score,
		uint8 player2Score)
		checkMatchExistence(matchId) private {
		matches[matchId].player1Score = player1Score;
		matches[matchId].player2Score = player2Score;
	}

	function endMatch (uint16 matchId,
		uint8 player1Score,
		uint8 player2Score)
		checkMatchExistence(matchId) public {
		_scoreRegister(matchId, player1Score, player2Score);
		uint16 tournamentId = matches[matchId].tournamentId;
		Tournament storage tournament = tournaments[tournamentId];

		uint16 lastMatchCreatedId = tournament.matchesIds[tournament.matchesIds.length - 1];

		if (lastMatchCreatedId == matchId) {
			tournament.ended = true;
			emit MatchEnded(matchId);
			emit TournamentEnded(tournamentId);
			return;
		}

		uint8 level = matches[matchId].level;
		uint8 tournamentCurrentLevel = matches[lastMatchCreatedId].level;

		if (level == tournamentCurrentLevel) {
			Match memory newMatch = Match({
				matchId: matchCount,
				tournamentId: tournamentId,
				player1Id: getMatchWinner(matchId),
				player2Id: 0xFFFF,
				player1Score: 0,
				player2Score: 0,
				level: level + 1
			});
			_addMatchToTournament(newMatch, tournamentId);
		} else if (level == tournamentCurrentLevel - 1) {
			matches[lastMatchCreatedId].player2Id = getMatchWinner(matchId);
		}
	}

}
