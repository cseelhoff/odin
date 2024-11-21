package main

PLAYERS_COUNT :: 5
PLAYER_ALIGNMENT :: 64
TEAMS_COUNT :: 2

Player :: struct {
	team:                    int,
	player_name:             string,
	color:                   string,
	capital_territory_index: int,
	is_human:                bool,
	is_allied:               [PLAYERS_COUNT]bool, // alied with self
	allies:                  [dynamic]int,
	enemies:                 [dynamic]int,
	enemy_team:              int,
}

PLAYERS := [PLAYERS_COUNT]Player {
	{0, "Rus", "\033[1;31m", 3, false, {}, {}, {}, 0},
	{1, "Ger", "\033[1;34m", 2, false, {}, {}, {}, 0},
	{0, "Eng", "\033[1;95m", 1, false, {}, {}, {}, 0},
	{1, "Ger", "\033[1;34m", 2, false, {}, {}, {}, 0},
	{0, "USA", "\033[1;32m", 0, false, {}, {}, {}, 0},
}

//TEAMS: [TEAMS_COUNT][dynamic]int = [TEAMS_COUNT][dynamic]int{[dynamic]int{0,2,4}, [dynamic]int{1,3}}
