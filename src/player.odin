package oaaa

import sa "core:container/small_array"
import "core:fmt"
import "core:strings"

PLAYERS_COUNT :: len(PLAYER_STRINGS)

Player_Strings :: struct {
	name:    string,
	team:    string,
	color:   string,
	capital: string,
}

PLAYER_STRINGS := [?]Player_Strings {
	{team = "Allies", name = "Rus", color = "\033[1;31m", capital = "Moscow"},
	{team = "Axis", name = "Ger", color = "\033[1;34m", capital = "Berlin"},
	{team = "Allies", name = "Eng", color = "\033[1;95m", capital = "London"},
	{team = "Axis", name = "Jap", color = "\033[1;33m", capital = "Tokyo"},
	{team = "Allies", name = "USA", color = "\033[1;32m", capital = "Washington"},
}

Players :: [PLAYERS_COUNT]Player
Player :: struct {
	factory_locations:  sa.Small_Array(LANDS_COUNT, ^Land),
	captial_index:      ^Land,
	team:               ^Team,
	money:              uint,
	income_per_turn:    uint,
	total_player_units: uint,
	index:              int,
}

TEAM_STRINGS := [?]string{"Allies", "Axis"}
TEAMS_COUNT :: len(TEAM_STRINGS)

Teams :: [TEAMS_COUNT]Team
Team :: struct {
	index:				 int,
	players:       SA_Player_Pointers,
	enemy_players: SA_Player_Pointers,
	enemy_team:    ^Team, // not an array, since assumption is 2 teams
	is_allied:     [PLAYERS_COUNT]bool,
}

get_player_idx_from_string :: proc(player_name: string) -> (player_idx: int, ok: bool) {
	for player, player_idx in PLAYER_STRINGS {
		if strings.compare(player.name, player_name) == 0 {
			return player_idx, true
		}
	}
	fmt.eprintln("Error: Player not found: %s\n", player_name)
	return 0, false
}

initialize_teams :: proc(teams: ^Teams, players: ^Players) {
	for &team, team_idx in teams {
		team.index = team_idx
		for &other_team in teams {
			if &team != &other_team {
				team.enemy_team = &other_team
				break
			}
		}
		for &player, player_idx in players {
			if strings.compare(PLAYER_STRINGS[player_idx].team, TEAM_STRINGS[team_idx]) == 0 {
				sa.push(&team.players, &player)
				team.is_allied[player_idx] = true
				player.team = &team
				player.index = player_idx
			} else {
				sa.push(&team.enemy_players, &player)
				team.is_allied[player_idx] = false
			}
		}
	}
}
