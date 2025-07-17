// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

contract PlayersFactory {

	event NewPlayer(string name, bool isAi, uint16 playerId);

	uint16 public playerCount = 0;

	struct Player {
		string	name;
		bool	isAi;
		uint16	playerId;
		uint16	winCount;
		uint16	lossCount;
	}

	Player[] public	players;

	function createPlayer(string memory name, bool isAi) public {
		Player memory	newPlayer = Player({
			name: name,
			isAi: isAi,
			playerId: playerCount,
			winCount: 0,
			lossCount: 0
		});
		players.push(newPlayer);
		playerCount++;
		emit NewPlayer(name, isAi, newPlayer.playerId);
	}

}
