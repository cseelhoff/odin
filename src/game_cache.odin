package main

import sa "core:container/small_array"
import "core:fmt"
import "core:mem"
import "core:strings"

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
MAX_AIR_TO_AIR_CONNECTIONS :: 7
ACTION_COUNT :: max(TERRITORIES_COUNT, len(Active_Sea_Unit_Type) + 1)
MAX_U8 :: 255
MAX_FACTORY_LOCATIONS :: 5
MAX_ADJACENT_TERRITORIES :: 6
MAX_ADJACENT_LANDS :: 6
MAX_ADJACENT_SEAS :: 6
MAX_VALID_MOVES :: 20

Game_Cache :: struct {
	teams:             [TEAMS_COUNT]Team_Cache,
	seas:              [SEAS_COUNT]Sea_Cache,
	lands:             [LANDS_COUNT]Land_Cache,
	players:           [PLAYERS_COUNT]Player_Cache,
	canal_paths:       [CANAL_STATES]Canal_Path,
	territories:       [TERRITORIES_COUNT]^Territory_Cache,
	valid_moves:       sa.Small_Array(MAX_VALID_MOVES, uint),
	unlucky_player:    ^Player_Cache,
	canal_state:       ^Canal_Path,
	step_id:           uint,
	answers_remaining: uint,
	selected_action:   uint,
	max_loops:         uint,
	actually_print:    bool,
}

Team_Cache :: struct {
	players:       sa.Small_Array(PLAYERS_COUNT, ^Player_Cache),
	enemy_players: sa.Small_Array(PLAYERS_COUNT, ^Player_Cache),
	enemy_team:    ^Team_Cache,
	is_allied:     [PLAYERS_COUNT]bool,
}

Player_Cache :: struct {
	factory_locations:  sa.Small_Array(MAX_FACTORY_LOCATIONS, ^Land_Cache),
	captial_index:      ^Land_Cache,
	team:               ^Team_Cache,
	income_per_turn:    uint,
	total_player_units: uint,
	index:              int,
}
Territory_Cache :: struct {
	air_distances:              [TERRITORIES_COUNT]^Territory_Cache,
	territory_within_6_moves:   sa.Small_Array(TERRITORIES_COUNT, ^Territory_Cache),
	territory_within_5_moves:   sa.Small_Array(TERRITORIES_COUNT, ^Territory_Cache),
	territory_within_4_moves:   sa.Small_Array(TERRITORIES_COUNT, ^Territory_Cache),
	territory_within_3_moves:   sa.Small_Array(TERRITORIES_COUNT, ^Territory_Cache),
	territory_within_2_moves:   sa.Small_Array(TERRITORIES_COUNT, ^Territory_Cache),
	airs_1_to_4_moves_away:     sa.Small_Array(TERRITORIES_COUNT, ^Territory_Cache),
	airs_2_to_4_moves_away:     sa.Small_Array(TERRITORIES_COUNT, ^Territory_Cache),
	airs_3_to_4_moves_away:     sa.Small_Array(TERRITORIES_COUNT, ^Territory_Cache),
	airs_4_moves_away:          sa.Small_Array(TERRITORIES_COUNT, ^Territory_Cache),
	land_within_6_moves:        sa.Small_Array(LANDS_COUNT, ^Land_Cache),
	land_within_5_moves:        sa.Small_Array(LANDS_COUNT, ^Land_Cache),
	land_within_4_moves:        sa.Small_Array(LANDS_COUNT, ^Land_Cache),
	land_within_3_moves:        sa.Small_Array(LANDS_COUNT, ^Land_Cache),
	land_within_2_moves:        sa.Small_Array(LANDS_COUNT, ^Land_Cache),
	adjacent_lands:             sa.Small_Array(MAX_ADJACENT_LANDS, ^Land_Cache),
	teams_unit_count:           [TEAMS_COUNT]uint,
	enemy_fighters_total:       uint,
	territory_index:            uint,
	can_fighter_land_here:      bool,
	can_fighter_land_in_1_move: bool,
	can_bomber_land_here:       bool,
	can_bomber_land_in_1_move:  bool,
	can_bomber_land_in_2_moves: bool,
}
Land_Cache :: struct {
	using territory_cache: Territory_Cache,
	//land_distances:        [LANDS_COUNT]uint,
	lands_within_2_moves:  sa.Small_Array(LANDS_COUNT, Land_2_Destination),
	seas_within_2_moves:   sa.Small_Array(SEAS_COUNT, Sea_2_Destination),
	adjacent_seas:              sa.Small_Array(MAX_ADJACENT_SEAS, ^Sea_Cache),
	//land_path_blocked:     [LANDS_COUNT]bool,
	original_owner:        ^Player_Cache,
	value:                 uint,
	land_index:            uint,
}
Sea_Cache :: struct {
	using territory_cache:             Territory_Cache,
	enemy_destroyers_total:            uint,
	enemy_submarines_total:            uint,
	enemy_blockade_total:              uint,
	allied_carriers:                   uint,
	transports_with_large_cargo_space: uint,
	transports_with_small_cargo_space: uint,
	sea_index:                         uint,
	sea_path_blocked:                  bool,
	sub_path_blocked:                  bool,
}

Canal_Path :: struct {
	starting_sea: [SEAS_COUNT]Sea_Distances,
	index:        uint,
}

Sea_Distances :: struct {
	//seas_within_1_move:  [MAX_ADJACENT_TERRITORIES]int,
	//sea_distances:       [SEAS_COUNT]uint,
	seas_within_2_moves: sa.Small_Array(SEAS_COUNT, Sea_2_Destination),
	adjacent_seas:       sa.Small_Array(MAX_ADJACENT_SEAS, ^Sea_Cache),
}

Land_2_Destination :: struct {
	destination_land:     ^Land_Cache,
	next_hop_to_land_pri: ^Land_Cache,
	next_hop_to_land_alt: ^Land_Cache,
}

Sea_2_Destination :: struct {
	destination_sea:     ^Sea_Cache,
	next_hop_to_sea_pri: ^Sea_Cache,
	next_hop_to_sea_alt: ^Sea_Cache,
}

initialize_map_constants :: proc(game_cache: ^Game_Cache) {
	initialize_teams(&game_cache.teams, &game_cache.players)
	initialize_land_dist(&game_cache.lands)
	land_dist_floyd_warshall(&game_cache.lands)
	initialize_sea_dist(&game_cache.seas, &game_cache.canal_paths)
	initialize_canals(&game_cache.seas)
	sea_dist_floyd_warshall(&game_cache.seas)
	initialize_territory_pointers(game_cache)
	// initialize_air_dist()
	// initialize_land_path()
	// initialize_sea_path()
	// initialize_within_x_moves()
	// intialize_airs_x_to_4_moves_away()
	// initialize_skip_4air_precals()
}
initialize_teams :: proc(teams: ^[TEAMS_COUNT]Team_Cache, players: ^[PLAYERS_COUNT]Player_Cache) {
	for &team, team_idx in teams {
		for &other_team in teams {
			team.enemy_team = &other_team
		}
		for &player, player_idx in players {
			if strings.compare(PLAYERS[player_idx].team, TEAMS[team_idx]) == 0 {
				sa.append(&team.players, &player)
				team.is_allied[player_idx] = true
				player.team = &team
				player.index = player_idx
			} else {
				sa.append(&team.enemy_players, &player)
				team.is_allied[player_idx] = false
			}
		}
	}
}

get_land_idx_from_string :: proc(land_name: string) -> (land_idx: int, ok: bool) {
	for land, land_idx in LANDS {
		if strings.compare(land.name, land_name) == 0 {
			return land_idx, true
		}
	}
	// print error
	fmt.eprintln("Error: Land not found: %s\n", land_name)
	return 0, false
}

get_sea_idx_from_string :: proc(sea_name: string) -> (sea_idx: int, ok: bool) {
	for sea, sea_idx in SEAS {
		if strings.compare(sea.name, sea_name) == 0 {
			return sea_idx, true
		}
	}
	// print error
	fmt.eprintln("Error: Sea not found: %s\n", sea_name)
	return 0, false
}

initialize_land_dist :: proc(lands: ^[LANDS_COUNT]Land_Cache) -> (ok: bool) {
	for &land, land_idx in lands {
		mem.set(&land.land_distances, MAX_U8, len(land.land_distances))
		land.land_distances[land_idx] = 0
		for adjacent_land in LANDS[land_idx].land_conns {
			land_idx_match, ok := get_land_idx_from_string(adjacent_land)
			if !ok {
				return false
			}
			sa.append(&land.adjacent_lands, &lands[land_idx_match])
			land.land_distances[land_idx_match] = 1
			lands[land_idx_match].land_distances[land_idx] = 1
		}
		for adjacent_sea in LANDS[land_idx].sea_conns {
			sea_idx_match, ok := get_sea_idx_from_string(adjacent_sea)
			if !ok {
				return false
			}
			sa.append(&land.adjacent_seas, &seas[sea_idx_match])
			land.land_distances[sea_idx_match] = 1
			seas[sea_idx_match].land_distances[land_idx] = 1
		}
	}
}
land_dist_floyd_warshall :: proc(lands: ^[LANDS_COUNT]Land_Cache) {
	for land1, land_idx1 in lands {
		for &land2 in lands {
			for land_idx3 in 0 ..< LANDS_COUNT {
				new_dist := land2.land_distances[land_idx1] + land1.land_distances[land_idx3]
				if new_dist < land2.land_distances[land_idx3] {
					land2.land_distances[land_idx3] = new_dist
				}
			}
		}
	}
}
initialize_sea_dist :: proc(
	seas: ^[SEAS_COUNT]Sea_Cache,
	canal_pathing: ^[MAX_CANAL_PATHS]Canal_Path,
) {
	for &canal_path in canal_pathing {
		for &starting_sea, sea_idx in canal_path.starting_sea {
			mem.set(&starting_sea.sea_distances, MAX_UINT, len(starting_sea.sea_distances))
			starting_sea.sea_distances[sea_idx] = 0
			for adjacent_sea in starting_sea.adjacent_territories {
				if adjacent_territory < LANDS_COUNT {
					append(&canal_path.adjacent_lands, adjacent_territory)
				} else {
					append(&canal_path.adjacent_seas, adjacent_territory)
					canal_path.sea_distances[adjacent_territory] = 1
				}
			}
		}
	}

	sea_dist_floyd_warshall(&canal_pathing.seas_pathing)
}
initialize_canals :: proc(seas: ^[SEAS_COUNT]Sea_Cache) {
	// convert canal_state to a bitmask and loop through CANALS for those
	// enabled for example if canal_state is 0, do not process any items in
	// CANALS, if canal_state is 1, process the first item in CANALS, if
	// canal_state is 2, process the second item in CANALS, if canal_state is
	// 3, process the first and second items in CANALS, etc.
	for canal_state in 0 ..< CANAL_STATES {
		adjacent_seas := canal[canal_state].adjacent_seas
		sea_distances := canal[canal_state].sea_distances
		for canal, canal_idx in CANALS {
			sea1 := canal.sea1
			sea2 := canal.sea2
			if (canal_state & (1 << uint(canal_idx))) == 0 {
				continue
			}
			append(&seas[sea1], adjacent_seas, sea2)
			seas[sea1], sea_distances[sea2] = 1
			append(&seas[sea2], adjacent_seas, sea1)
			seas[sea2], sea_distances[sea1] = 1
		}
	}
}
sea_dist_floyd_warshall :: proc(seas: ^[SEAS_COUNT]Sea_Cache) {
	for canal_state in 0 ..< CANAL_STATES {
		for sea1, sea_idx1 in seas {
			for &sea2 in seas {
				for sea_idx3 in 0 ..< SEAS_COUNT {
					new_dist :=
						sea2.canal_paths[canal_state].sea_distances[sea_idx1] +
						sea1.canal_paths[canal_state].sea_distances[sea_idx3]
					if new_dist < sea2.sea_distances[sea_idx3] {
						sea2.sea_distances[sea_idx3] = new_dist
					}
				}
			}
		}
	}
}
initialize_territory_pointers :: proc(game_cache: ^Game_Cache) {
	for &land, land_idx in game_cache.lands {
		game_cache.territories[land_idx] = &land.territory_cache
	}
	for &sea, sea_idx in game_cache.seas {
		game_cache.territories[sea_idx + LANDS_COUNT] = &sea.territory_cache
	}
}
initialize_air_dist :: proc(territories: [TERRITORIES_COUNT]^Territory_Cache) {
	for &territory, territory_idx in territories {
		for &air_distance in territory.air_distances {
			air_distance = MAX_INT
		}
		for adjacent_territory in territory.adjacent_territories {
			territory.air_distances[adjacent_territory] = 1
		}
		territory.air_distances[territory_idx] = 0
	}
	air_dist_floyd_warshall()
}
