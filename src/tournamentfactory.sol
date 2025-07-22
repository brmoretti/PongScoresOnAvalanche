// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "./playersactions.sol";

contract TournamentFactory is PlayersFactory, PlayersActions {

	event NewTournament(uint16 tounamentId, string tournamentName);

	uint16 public tournamentCount = 0;
	uint16 public matchCount = 0;

	struct Match {
		uint16	matchId;
		uint16	tournamentId;
		uint16	player1Id;
		uint16	player2Id;
		uint8	player1Score;
		uint8	player2Score;
		uint8	level;
	}

	struct Tournament {
		string		name;
		uint16		tournamentId;
		uint16[]	matchesIds;
	}

	Tournament[] public	tournaments;
	Match[] public		matches;

	function _defineNumberOfPlayers(
		uint8 numberOfRegisteredPlayers
	) private pure returns (uint8) {
		uint8 n = 2;
		while (n < numberOfRegisteredPlayers) {
			n *= 2;
		}
		return n;
	}

	function _fullListOfPlayers(
		uint16[] memory playersIds,
		uint8 numberOfRegisteredPlayers
	) private returns (uint16[] memory newPlayerIds) {
		uint8 numberOfPlayers = _defineNumberOfPlayers(
			numberOfRegisteredPlayers
		);
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
			bool[] memory used = new bool[](aiPlayersList.length);
			for (i = 0; i < numberOfAiPlayers; i++) {
				uint randIndex = uint(
					keccak256(
						abi.encodePacked(block.timestamp, block.prevrandao, i)
					)
				) % aiPlayersList.length;
				uint attempts = 0;
				while (used[randIndex] && attempts < aiPlayersList.length) {
					randIndex = (randIndex + 1) % aiPlayersList.length;
					attempts++;
				}
				used[randIndex] = true;
				fullList[playersIds.length + i] = aiPlayersList[randIndex];
			}
		}

		return fullList;
	}

	function _addMatchToTournament(Match memory matchToAdd, uint16 tournamentId) internal {
		matches.push(matchToAdd);
		tournaments[tournamentId].matchesIds.push(matchToAdd.matchId);
		matchCount++;
	}

	function _createInitialMatches(uint16[] memory playersIds, uint16 tournamentId) private {
		uint8 numberOfRegisteredPlayers = uint8(playersIds.length);
		uint16[] memory fullListOfPlayers = _fullListOfPlayers(
			playersIds,
			numberOfRegisteredPlayers
		);
		uint8 totalPlayers = uint8(fullListOfPlayers.length);

		for (uint8 i = 0; i < totalPlayers; i += 2) {
			Match memory newMatch = Match({
				matchId: matchCount,
				tournamentId: tournamentId,
				player1Id: fullListOfPlayers[i],
				player2Id: fullListOfPlayers[i + 1],
				player1Score: 0,
				player2Score: 0,
				level: 0
			});
			_addMatchToTournament(newMatch, tournamentId);
		}
	}

	function createTournament(
		string memory tournamentName,
		uint16[] memory playersIds
	) public {
		require(
			playersIds.length <= 16,
			"Number of players exeeds the maximum allowed"
		);

		for (uint i = 0; i < playersIds.length; i++) {
			for (uint j = i + 1; j < playersIds.length; j++) {
				require(
					playersIds[i] != playersIds[j],
					"Duplicate player ID found"
				);
			}
		}

		Tournament memory newTournament = Tournament({
			name: tournamentName,
			tournamentId: tournamentCount,
			matchesIds: new uint16[](0)
		});
		tournaments.push(newTournament);
		_createInitialMatches(playersIds, tournamentCount);
		tournamentCount++;
		emit NewTournament(newTournament.tournamentId, newTournament.name);
	}

}
