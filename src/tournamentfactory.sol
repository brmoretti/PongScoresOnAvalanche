// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "./playersfactory.sol";
import "./playersactions.sol";

contract TournamentFactory is PlayersFactory, PlayersActions {
	event NewTournament();

	uint16 public tournamentCount = 0;
	uint16 public matchCount = 0;

	struct Match {
		uint16 player1;
		uint16 player2;
		uint16 matchId;
		uint8 level;
	}

	struct Tournament {
		string name;
		uint16 tournamentId;
		Match[] matches;
	}

	Tournament[] public tournaments;

	function _defineNumberOfPlayers(uint8 numberOfRegisteredPlayers)
	private pure returns (uint8) {
		uint8 n = 2;
		while (n < numberOfRegisteredPlayers) {
			n *= 2;
		}
		return n;
	}

	function _fullListOfPlayers(uint16[] memory playersIds, uint8 numberOfRegisteredPlayers)
	private returns (uint16[] memory newPlayerIds) {
		uint8 numberOfPlayers = _defineNumberOfPlayers(numberOfRegisteredPlayers);
		uint8 numberOfAiPlayers = numberOfPlayers - numberOfRegisteredPlayers;

		uint16[] memory fullList = new uint16[](numberOfPlayers);
		for (uint i = 0; i < playersIds.length; i++) {
			fullList[i] = playersIds[i];
		}

		if (numberOfAiPlayers > 0) {
			uint16[] memory aiPlayersList = listAiPlayers();
			uint i = 0;
			while (aiPlayersList.length + i < numberOfAiPlayers) {
				createPlayer("", true);
				i++;
			}
			if (i > 0) {
				aiPlayersList = listAiPlayers();
			}
			for (i = 0; i < numberOfAiPlayers; i++) {
				uint randIndex = uint(
					keccak256(
						abi.encodePacked(block.timestamp, block.prevrandao, i)
					)
				) % aiPlayersList.length;
				fullList[playersIds.length + i] = aiPlayersList[randIndex];
			}
		}

		return fullList;
	}

	function _createMatches(uint16[] memory playersIds) private returns (Match[] memory) {
		uint8 numberOfRegisteredPlayers = uint8(playersIds.length);
		uint16[] memory fullListOfPlayers = _fullListOfPlayers(
			playersIds,
			numberOfRegisteredPlayers
		);
		Match[] memory matches = new Match[](numberOfRegisteredPlayers / 2);
		Match[] memory matchesRef = matches;

		for (uint8 i = 0; i < numberOfRegisteredPlayers; i += 2) {
			matchesRef[i / 2] = Match({
				player1: fullListOfPlayers[i],
				player2: fullListOfPlayers[i + 1],
				matchId: matchCount,
				level: 0
			});
			matchCount++;
		}

		return matches;
	}

	function createTournament(string memory tournamentName, uint16[] memory playersIds) public {
		require(
			playersIds.length <= 16,
			"Number of players exeeds the maximum allowed"
		);

		for (uint i = 0; i < playersIds.length; i++) {
			for (uint j = i + 1; j < playersIds.length; j++) {
				require(playersIds[i] != playersIds[j], "Duplicate player ID found");
			}
		}

		Tournament memory newTournament = Tournament({
			name: tournamentName,
			tournamentId: tournamentCount,
			matches: _createMatches(playersIds)
		});

		tournaments.push(newTournament);
	}
}
