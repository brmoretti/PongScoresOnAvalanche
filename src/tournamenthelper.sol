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

	function getMatchWinner(uint16 matchId)
	checkMatchExistence(matchId) internal view returns (uint16 playerId) {
		
	}
}
