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
	idle_air_units:   [PLAYERS_COUNT][len(Idle_Air_Unit_Type)]int,
	active_air_units: [len(Active_Air_Unit_Type)]int,
	skipped_moves:    [TERRITORIES_COUNT]int,
	combat_status:    Combat_Status,
	builds_left:      int,
}

Land_State :: struct {
	using territory_state: Territory_State,
	idle_land_units:       [PLAYERS_COUNT][len(Idle_Land_Unit_Type)]int,
	active_land_units:     [len(Active_Land_Unit_Type)]int,
	owner:                 int,
	factory_damage:        int,
	factory_max_damage:    int,
	bombard_max_damage:    int,
}

Sea_State :: struct {
	using territory_state: Territory_State,
	idle_sea_units:        [PLAYERS_COUNT][len(Idle_Sea_Unit_Type)]int,
	active_sea_units:      [len(Active_Sea_Unit_Type)]int,
}

Combat_Status :: enum {
	NO_COMBAT  = 0,
	MID_COMBAT = 1,
	PRE_COMBAT = 2,
}
