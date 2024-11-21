package main

FIGHTER_MOVES_MAX :: 4
MIN_AIR_HOPS :: 2
MAX_AIR_HOPS :: 6
MIN_SEA_HOPS :: 1
MAX_SEA_HOPS :: 2
MIN_LAND_HOPS :: 1
MAX_LAND_HOPS :: 2
AIR_MOVE_SIZE :: 1 + MAX_AIR_HOPS - MIN_AIR_HOPS
SEA_MOVE_SIZE :: 1 + MAX_SEA_HOPS - MIN_SEA_HOPS
LAND_MOVE_SIZE :: 1 + MAX_LAND_HOPS - MIN_LAND_HOPS
PLAYERS_COUNT_P1 :: PLAYERS_COUNT + 1
AIRS_COUNT :: LANDS_COUNT + SEAS_COUNT
MAX_AIR_TO_AIR_CONNECTIONS :: 7
ACTION_COUNT :: max(AIRS_COUNT, len(SeaUnitTypesEnum) + 1)
MAX_INT: int : 1000

Game_Cache :: struct {
	player_caches:      #soa[PLAYERS_COUNT]Player_Cache,
	land_caches:        #soa[LANDS_COUNT]Land_Cache,
	sea_caches:         #soa[SEAS_COUNT]Sea_Cache,
	canals_pathing:     #soa[CANAL_STATES]Canal_Pathing,
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
	enemy_fighters_total:       int,
	can_fighter_land_here:      bool,
	can_fighter_land_in_1_move: bool,
	can_bomber_land_here:       bool,
	can_bomber_land_in_1_move:  bool,
	can_bomber_land_in_2_moves: bool,
	adjacent_territories:       [dynamic]int,
	teams_unit_count:           [TEAMS_COUNT]int,
	air_distances:              [TERRITORIES_COUNT]int,
	territory_within_x_moves:   [MAX_AIR_HOPS][dynamic]int,
	land_within_x_moves:        [MAX_AIR_HOPS][dynamic]int,
	airs_x_to_4_moves_away:     [FIGHTER_MOVES_MAX][dynamic]int,
}
Land_Cache :: struct {
	using territory_cache: Territory_Cache,
	land_path_blocked:     int,
	value:                 int,
	adjacent_lands:        [dynamic]int,
	adjacent_seas:         [dynamic]int,
	land_distances:        [LANDS_COUNT]int,
}
Sea_Cache :: struct {
	using territory_cache:             Territory_Cache,
	enemy_destroyers_total:            int,
	enemy_submarines_total:            int,
	enemy_blockade_total:              int,
	allied_carriers:                   int,
	transports_with_large_cargo_space: int,
	transports_with_small_cargo_space: int,
	sea_path_blocked:                  int,
	sub_path_blocked:                  int,
}
Canal_Pathing :: struct {
	seas_pathing: #soa[SEAS_COUNT]Sea_Pathing,
}
Sea_Pathing :: struct {
	seas_within_1_move:  [dynamic]int,
	seas_within_2_moves: [dynamic]int,
	adjacent_lands:      [dynamic]int,
	adjacent_seas:       [dynamic]int,
	sea_distances:       [SEAS_COUNT]int,
	next_hop_to_sea_pri: [SEAS_COUNT]int,
	next_hop_to_sea_alt: [SEAS_COUNT]int,
}
initialize_map_constants :: proc(game_cache: ^Game_Cache) {
	initialize_enemies()
	initialize_land_dist(&game_cache.land_caches)
	land_dist_floyd_warshall(&game_cache.land_caches)
	initialize_sea_dist(game_cache)
	// initialize_air_dist()
	// initialize_land_path()
	// initialize_sea_path()
	// initialize_within_x_moves()
	// intialize_airs_x_to_4_moves_away()
	// initialize_skip_4air_precals()
}
initialize_enemies :: proc() {
	for &player in PLAYERS {
		player.enemy_team = 1 - player.team
		for other_player, j in PLAYERS {
			if (player.team == other_player.team) {
				player.is_allied[j] = true
				append(&player.allies, j)
			} else {
				append(&player.enemies, j)
			}
		}
	}
}
initialize_land_dist :: proc(land_caches: ^#soa[LANDS_COUNT]Land_Cache) {
	for &land_cache in land_caches {
		for &land_distance in land_cache.land_distances {
			land_distance = MAX_INT
		}
		for adjacent_territory in land_cache.adjacent_territories {
			if adjacent_territory < LANDS_COUNT {
				append(&land_cache.adjacent_lands, adjacent_territory)
				land_cache.land_distances[adjacent_territory] = 1
			} else {
				append(&land_cache.adjacent_seas, adjacent_territory)
			}
		}
	}
}
land_dist_floyd_warshall :: proc(land_caches: ^#soa[LANDS_COUNT]Land_Cache) {
	for land1, land_idx1 in land_caches {
		for &land2 in land_caches {
			for land_idx3 in 0 ..< LANDS_COUNT {
				new_dist := land2.land_distances[land_idx1] + land1.land_distances[land_idx3]
				if new_dist < land2.land_distances[land_idx3] {
					land2.land_distances[land_idx3] = new_dist
				}
			}
		}
	}
}
initialize_sea_dist :: proc(game_cache: ^Game_Cache) {
	for &canal_pathing, canal_state in game_cache.canals_pathing {
		for sea_cache, sea_idx in game_cache.sea_caches {
			sea_pathing := canal_pathing.seas_pathing[sea_idx]
			sea_distances := sea_pathing.sea_distances
			for &sea_distance in sea_distances {
				sea_distance = MAX_INT
			}
			for adjacent_territory in sea_cache.adjacent_territories {
				if adjacent_territory < LANDS_COUNT {
					append(&sea_pathing.adjacent_lands, adjacent_territory)
				} else {
					append(&sea_pathing.adjacent_seas, adjacent_territory)
					sea_distances[adjacent_territory] = 1
				}
			}
		}
		// convert canal_state to a bitmask and loop through CANALS for those
		// enabled for example if canal_state is 0, do not process any items in
		// CANALS, if canal_state is 1, process the first item in CANALS, if
		// canal_state is 2, process the second item in CANALS, if canal_state is
		// 3, process the first and second items in CANALS, etc.
		for canal, canal_idx in CANALS {
			if (canal_state & (1 << uint(canal_idx))) == 0 {
				continue
			}
			append(&canal_pathing.seas_pathing[canal.sea1].adjacent_seas, canal.sea2)
			canal_pathing.seas_pathing[canal.sea1].sea_distances[canal.sea2] = 1
			append(&canal_pathing.seas_pathing[canal.sea2].adjacent_seas, canal.sea1)
			canal_pathing.seas_pathing[canal.sea2].sea_distances[canal.sea1] = 1
		}
		sea_dist_floyd_warshall(&canal_pathing.seas_pathing);
	}
}
sea_dist_floyd_warshall :: proc(seas_pathing: ^#soa[SEAS_COUNT]Sea_Pathing) {
	for sea1, sea_idx1 in seas_pathing {
		for &sea2 in seas_pathing {
			for sea_idx3 in 0 ..< SEAS_COUNT {
				new_dist := sea2.sea_distances[sea_idx1] + sea1.sea_distances[sea_idx3]
				if new_dist < sea2.sea_distances[sea_idx3] {
					sea2.sea_distances[sea_idx3] = new_dist
				}
			}
		}
	}
}