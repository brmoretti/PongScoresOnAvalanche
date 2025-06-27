// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "./playersactions.sol";

contract TournamentFactory is PlayersActions {

	event NewTournament();

	uint16 public tournamentCount = 0;

	struct Match {
		uint16	player1;
		uint16	player2;
	}

	struct Tournament {
		string	name;
		uint16	tournamentId;
		uint8	numberOfPlayers;
		Match[]	matches;
	}

	Tournament[] public tournaments;

	function _defineNumberOfPlayers(uint numberOfRegisteredPlayers) pure private returns(uint) {
		uint n = 2;
		while (n < numberOfRegisteredPlayers) {
			n *= 2;
		}
		return n;
	}

	function _createMatches(uint[] memory playersIds) private pure returns (Match[] memory) {
		uint numberOfPlayers = _defineNumberOfPlayers(playersIds.length);

	}

	function createTournament(string memory tournamentName, uint[] memory playersIds) public {
		require(playersIds.length <= 16, "Number of players exeeds the maximum allowed");
		Tournament memory newTournament = Tournament({
			name: tournamentName,
			tournamentId: tournamentCount
		});
		tournaments.push(newTournament);
	}

}
