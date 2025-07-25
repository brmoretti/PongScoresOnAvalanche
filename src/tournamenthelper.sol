// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "./tournamentfactory.sol";

contract TournamentHelper is TournamentFactory {

	modifier checkTournamentExistence(uint16 tournamentId) {
		require(tournamentId < tournamentCount, "Tournament does not exist");
		_;
	}

	modifier checkMatchExistence(uint16 matchId) {
		require(matchId < matchCount, "Match does not exist");
		_;
	}

	modifier checkTournamentIsEnded(uint16 tournamentId) {
		require(!tournaments[tournamentId].ended, "Tournament is ended");
		_;
	}

	function getTournamentMatches(
		uint tournamentId
	) public view returns (Match[] memory) {
		uint16[] storage matchIds = tournaments[tournamentId].matchesIds;
		Match[] memory tournamentMatches = new Match[](matchIds.length);
		for (uint i = 0; i < matchIds.length; i++) {
			tournamentMatches[i] = matches[matchIds[i]];
		}
		return tournamentMatches;
	}

	function getMatchWinner(uint16 matchId)
	checkMatchExistence(matchId) public view returns (uint16 playerId) {
		Match memory _match = matches[matchId];
		playerId = _match.player1Score > _match.player2Score ?
				_match.player1Id :
				_match.player2Id;
		return playerId;
	}

	function getNextTournamentMatch(uint16 tournamentId)
	checkTournamentIsEnded(tournamentId) public view  returns (uint16 matchId) {
		Tournament storage tournament = tournaments[tournamentId];
		for (uint16 i = 0; i < tournament.matchesIds.length; i++) {
			Match storage _match = matches[tournament.matchesIds[i]];
			if (_match.player1Score == 0 && _match.player2Score == 0) {
				return tournament.matchesIds[i];
			}
		}
		return 0xFFFF;
	}
}
