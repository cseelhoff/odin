package main

TERRITORIES_COUNT :: LANDS_COUNT + SEAS_COUNT

Game_State :: struct {
	current_turn: int,
	seed:         int,
	money:        [PLAYERS_COUNT]int,
	land_state:   #soa[LANDS_COUNT]Land_State,
	sea_state:    #soa[SEAS_COUNT]Sea_State,
}

Territory_State :: struct {
	builds_left:   int,
	combat_status: Combat_Status,
	skipped_moves: [TERRITORIES_COUNT]int,
	air_units:     #soa[len(AirUnitTypeEnum)]Unit_Counts,
}

Land_State :: struct {
	using territory_state: Territory_State,
	owner:                 int,
	factory_damage:        int,
	factory_max_damage:    int,
	bombard_max_damage:    int,
	land_units:            #soa[len(LandUnitTypeEnum)]Unit_Counts,
}

Sea_State :: struct {
	using territory_state: Territory_State,
	sea_units:             #soa[len(SeaUnitTypesEnum)]Unit_Counts,
}

Unit_Counts :: struct {
	active: [dynamic]int,
	idle:   [PLAYERS_COUNT]int,
}

Combat_Status :: enum {
	NO_COMBAT  = 0,
	MID_COMBAT = 1,
	PRE_COMBAT = 2,
}
