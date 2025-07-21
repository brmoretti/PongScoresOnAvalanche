// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "./playershelper.sol";

contract PlayersActions is PlayersHelper {

	event ChangedName(uint16 playerId, string newName);
	event PlayerWon(uint16 playerId, uint16 winCount);
	event PlayerLost(uint16 playerId, uint16 lossCount);

	function changePlayerName(uint16 playerId, string memory newName)
	checkPlayerExistence(playerId) internal {
		players[playerId].name = newName;
		emit ChangedName(playerId, newName);
	}

	function playerWon(uint16 playerId)
	checkPlayerExistence(playerId) internal {
		players[playerId].winCount++;
		emit PlayerWon(playerId, players[playerId].winCount);
	}

	function playerLost(uint16 playerId)
	checkPlayerExistence(playerId) internal {
		players[playerId].lossCount++;
		emit PlayerLost(playerId, players[playerId].lossCount);
	}

	function addMatchPlayed(uint16 playerId, uint16 matchId)
	checkPlayerExistence(playerId) internal {

	}

}
