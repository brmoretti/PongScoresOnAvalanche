// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "./playersfactory.sol";

contract PlayersHelper is PlayersFactory {

	modifier checkPlayerExistence(uint16 playerId) {
	require(playerId < playerCount, "Player does not exist");
	_;
	}

	function listAiPlayers() internal view returns (uint16[] memory aiIds) {
		uint16 aiCount = 0;
		for (uint16 i = 0; i < playerCount; i++) {
			if (players[i].isAi) {
				aiCount++;
			}
		}
		aiIds = new uint16[](aiCount);
		uint16 idx = 0;
		for (uint16 i = 0; i < playerCount; i++) {
			if (players[i].isAi) {
				aiIds[idx] = i;
				idx++;
			}
		}
		return aiIds;
	}

}
