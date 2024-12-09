package main

PLAYERS_COUNT :: len(PLAYERS)

Player_Strings :: struct {
	team:        string,
	player_name: string,
	color:       string,
	capital:     string,
}

TEAMS := [?]string {"Allies", "Axis"}
TEAMS_COUNT :: len(TEAMS)

PLAYERS := [?]Player_Strings {
	{team = "Allies", player_name = "Rus", color = "\033[1;31m", capital = "Moscow"},
	{team = "Axis", player_name = "Ger", color = "\033[1;34m", capital = "Berlin"},
	{team = "Allies", player_name = "Eng", color = "\033[1;95m", capital = "London"},
	{team = "Axis", player_name = "Jap", color = "\033[1;33m", capital = "Tokyo"},
	{team = "Allies", player_name = "USA", color = "\033[1;32m", capital = "Washington"},
}
