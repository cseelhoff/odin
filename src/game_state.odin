package oaaa

Idle_Plane_For_Player :: [len(Idle_Plane)]uint
Idle_Army_For_Player :: [len(Idle_Army)]uint
Idle_Sea_For_Player :: [len(Idle_Ship)]uint

Game_State :: struct {
	current_turn: uint,
	seed:         uint,
	money:        [PLAYERS_COUNT]uint,
	land_state:   #soa[LANDS_COUNT]Land_State,
	sea_state:    #soa[SEAS_COUNT]Sea_State,
}

Territory_State :: struct {
	Idle_Plane_units:   [PLAYERS_COUNT]Idle_Plane_For_Player,
	Active_Planes: [len(Active_Plane)]uint,
	skipped_moves:    [TERRITORIES_COUNT]bool,
	combat_status:    Combat_Status,
	builds_left:      uint,
}

Land_State :: struct {
	using territory_state: Territory_State,
	Idle_Armys:       [PLAYERS_COUNT]Idle_Army_For_Player,
	Active_Armys:     [len(Active_Army)]uint,
	owner:                 int,
	factory_damage:        uint,
	factory_max_damage:    uint,
	bombard_max_damage:    uint,
}

Sea_State :: struct {
	using territory_state: Territory_State,
	Idle_Ships:        [PLAYERS_COUNT]Idle_Sea_For_Player,
	Active_Ships:      [len(Active_Ship)]uint,
}

Combat_Status :: enum {
	NO_COMBAT  = 0,
	MID_COMBAT = 1,
	PRE_COMBAT = 2,
}
