// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "./playersfactory.sol";

contract PlayersHelper is PlayersFactory {

	modifier checkPlayerExistence(uint16 id) {
	require(id < playerCount, "Player does not exist");
	_;
	}

	function listAiPlayers() internal view returns (uint16[] memory ids) {
		uint16 aiCount = 0;
		for (uint16 i = 0; i < playerCount; i++) {
			if (players[i].isAi) {
				aiCount++;
			}
		}
		ids = new uint16[](aiCount);
		uint16 idx = 0;
		for (uint16 i = 0; i < playerCount; i++) {
			if (players[i].isAi) {
				ids[idx] = i;
				idx++;
			}
		}
		return ids;
	}

}
