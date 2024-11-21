package main

TERRITORIES_COUNT :: LANDS_COUNT + SEAS_COUNT

Game_State :: struct {
	current_turn: int,
	seed:         int,
	money:        [PLAYERS_COUNT]int,
	land_state:   [LANDS_COUNT]Land_State,
	sea_state:    [SEAS_COUNT]Sea_State,
}

Land_State :: struct {
	using territory_state: Territory_State,
	owner:                 int,
	factory_damage:        int,
	factory_max_damage:    int,
	bombard_max_damage:    int,
	land_units:            [len(LandUnitTypeEnum)]Unit_Counts,
}

Sea_State :: struct {
	using territory_state: Territory_State,
	sea_units:             [len(SeaUnitTypesEnum)]Unit_Counts,
}

Unit_Counts :: struct {
	active: [dynamic]int,
	idle:   [PLAYERS_COUNT]int,
}

Territory_State :: struct {
	builds_left:   int,
	combat_status: Combat_Status,
	skipped_moves: [TERRITORIES_COUNT]int,
	air_units:     [len(AirUnitTypeEnum)]Unit_Counts,
}

Combat_Status :: enum {
	NO_COMBAT  = 0,
	MID_COMBAT = 1,
	PRE_COMBAT = 2,
}
