// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "./tournamentfactory.sol";

contract TournamentHelper is TournamentFactory {

	modifier checkTournamentExistence(uint16 tournamentId) {
	require(tournamentId < tournamentCount, "Tournament does not exist");
	_;
	}

	modifier checkMatchExistence(uint16 matchId) {
	require(matchId < tournamentCount, "Match does not exist");
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
	checkMatchExistence(matchId) internal view returns (uint16 playerId) {
		Match memory _match = matches[matchId];
		playerId = _match.player1Score > _match.player2Score ?
				_match.player1Id :
				_match.player2Id;
		return playerId;
	}
}
