package oaaa

Idle_Plane_For_Player :: [len(Idle_Plane)]int
Idle_Army_For_Player :: [len(Idle_Army)]int
Idle_Sea_For_Player :: [len(Idle_Ship)]int

Game_State :: struct {
	cur_player: int,
	seed:       int,
	money:      [PLAYERS_COUNT]int,
	land_state: #soa[len(LANDS_DATA)]Land_State,
	sea_state:  #soa[SEAS_COUNT]Sea_State,
}

Territory_State :: struct {
	idle_planes:   [PLAYERS_COUNT]Idle_Plane_For_Player,
	active_planes: [len(Active_Plane)]int,
	skipped_moves: [TERRITORIES_COUNT]bool,
	combat_status: Combat_Status,
	builds_left:   int,
}

Land_State :: struct {
	using territory_state: Territory_State,
	idle_armies:           [PLAYERS_COUNT]Idle_Army_For_Player,
	active_armies:         [len(Active_Army)]int,
	owner:                 int,
	factory_dmg:        int,
	factory_prod:    int,
	max_bombards:          int,
}

Sea_State :: struct {
	using territory_state: Territory_State,
	idle_ships:            [PLAYERS_COUNT]Idle_Sea_For_Player,
	active_ships:          [len(Active_Ship)]int,
}

Combat_Status :: enum {
	NO_COMBAT,
	MID_COMBAT,
	PRE_COMBAT,
	POST_COMBAT,
}
