package main

Game_Cache :: struct {
	player_cache:       [PLAYERS_COUNT]Player_Cache,
	land_cache:         [LANDS_COUNT]Land_Cache,
	sea_cache:          [SEAS_COUNT]Sea_Cache,
	valid_moves:        [dynamic]int,
	canal_state:        int,
	step_id:            int,
	answers_remaining:  int,
	selected_action:    int,
	unlucky_player_idx: int,
	max_loops:          int,
	actually_print:     bool,
}

Player_Cache :: struct {
	factory_locations:  [dynamic]int,
	income_per_turn:    int,
	total_player_units: int,
}

Territory_Cache :: struct {
	enemy_fighters_total:  int,
	sea_path_blocked:      int,
	sub_path_blocked:      int,
	canFighterLandHere:    bool,
	canFighterLandIn1Move: bool,
	canBomberLandHere:     bool,
	canBomberLandIn1Move:  bool,
	canBomberLandIn2Moves: bool,
	teams_unit_count:      [TEAMS_COUNT]int,
}

Land_Cache :: struct {
	using territory_cache: Territory_Cache,
	land_path_blocked:     int,
    land_connections:      [dynamic]int,
	land_dist:             [TERRITORIES_COUNT]int,
}


Sea_Cache :: struct {
	using territory_cache:             Territory_Cache,
	enemy_destroyers_total:            int,
	enemy_submarines_total:            int,
	enemy_blockade_total:              int,
	allied_carriers:                   int,
	transports_with_large_cargo_space: int,
	transports_with_small_cargo_space: int,
}
