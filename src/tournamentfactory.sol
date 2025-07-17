// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "./playersfactory.sol";
import "./playersactions.sol";

contract TournamentFactory is PlayersFactory, PlayersActions {

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

	function _fullListOfPlayers(uint[] memory playersIds) private returns (uint[] memory newPlayerIds) {
		uint numberOfPlayers = _defineNumberOfPlayers(playersIds.length);
		uint numberOfAiPlayers = numberOfPlayers - playersIds.length;

		uint[] fullList = new uint[](numberOfPlayers);
		for (uint i = 0; i < playersIds.length; i++) {
			fullList[i] = playersIds[i];
		}

		if (numberOfAiPlayers > 0) {
			uint[] memory aiPlayersList = listAiPlayers();
			uint i = 0;
			while (aiPlayersList.length + i < numberOfAiPlayers) {
				createPlayer("", true);
				i++;
			}
			if (i > 0) {
				aiPlayersList = listAiPlayers();
			}
			for (i = 0; i < numberOfAiPlayers; i++) {
				uint randIndex = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, i))) % aiPlayersList.length;
				fullList[playersIds.length + i] = aiPlayersList[randIndex];
			}
		}

		return fullList;
	}

	function _createMatches(uint[] memory playersIds) private pure returns (Match[] memory) {
		

		Match[] memory matches = new Match[](numberOfPlayers / 2);

		return matches;
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
