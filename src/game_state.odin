package oaaa

Idle_Air_For_Player :: [len(Idle_Air_Unit)]uint
Idle_Land_For_Player :: [len(Idle_Land_Unit)]uint
Idle_Sea_For_Player :: [len(Idle_Sea_Unit)]uint

Game_State :: struct {
	current_turn: uint,
	seed:         uint,
	money:        [PLAYERS_COUNT]uint,
	land_state:   #soa[LANDS_COUNT]Land_State,
	sea_state:    #soa[SEAS_COUNT]Sea_State,
}

Territory_State :: struct {
	idle_air_units:   [PLAYERS_COUNT]Idle_Air_For_Player,
	active_air_units: [len(Active_Air_Unit)]uint,
	skipped_moves:    [TERRITORIES_COUNT]bool,
	combat_status:    Combat_Status,
	builds_left:      uint,
}

Land_State :: struct {
	using territory_state: Territory_State,
	idle_land_units:       [PLAYERS_COUNT]Idle_Land_For_Player,
	active_land_units:     [len(Active_Land_Unit)]uint,
	owner:                 int,
	factory_damage:        uint,
	factory_max_damage:    uint,
	bombard_max_damage:    uint,
}

Sea_State :: struct {
	using territory_state: Territory_State,
	idle_sea_units:        [PLAYERS_COUNT]Idle_Sea_For_Player,
	active_sea_units:      [len(Active_Sea_Unit)]uint,
}

Combat_Status :: enum {
	NO_COMBAT  = 0,
	MID_COMBAT = 1,
	PRE_COMBAT = 2,
}
