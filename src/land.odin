package main

MAX_LAND_TO_SEA_CONNECTIONS :: 4
MAX_LAND_TO_LAND_CONNECTIONS :: 6

Land_Strings :: struct {
	name:       string,
	owner:      string,
	value:      uint,
	land_conns: [dynamic]string,
	sea_conns:  [dynamic]string,
}

//  PACIFIC | USA | ATLANTIC | ENG | BALTIC | GER | RUS | JAP | PAC
LANDS := [?]Land_Strings {
	{name = "Washington", owner = "USA", value = 10, sea_conns = {"Pacific", "Atlantic"}},
	{name = "London", owner = "Eng", value = 8, sea_conns = {"Atlantic", "Baltic"}},
	{name = "Berlin", owner = "Ger", value = 10, sea_conns = {"Baltic"}, land_conns = {"Moscow"}},
	{name = "Moscow", owner = "Rus", value = 8, sea_conns = {"Pacific"}, land_conns = {"Berlin"}},
	{name = "Tokyo", owner = "Jap", value = 8, sea_conns = {"Pacific"}},
}

LANDS_COUNT::len(LANDS)