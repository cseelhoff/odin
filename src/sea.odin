package main
import sa "core:container/small_array"
import "core:fmt"
import "core:mem"
import "core:slice"
import "core:strings"

MAX_SEA_TO_LAND_CONNECTIONS :: 6
MAX_SEA_TO_SEA_CONNECTIONS :: 7
SEAS_COUNT :: len(SEAS_STRINGS)
Seas :: [SEAS_COUNT]Sea_Cache
CANALS_COUNT :: len(CANALS)
CANAL_STATES :: 1 << CANALS_COUNT
MAX_PATHS_TO_SEA :: 2
SA_Adjacent_S2S :: sa.Small_Array(MAX_SEA_TO_SEA_CONNECTIONS, ^Sea_Cache)
Canal_Paths :: [CANAL_STATES]Sea_Distances
Seas_2_Moves_Away :: sa.Small_Array(SEAS_COUNT, Sea_2_Moves_Away)

Sea_Cache :: struct {
	using territory:                   Territory_Cache,
	canal_paths:                       Canal_Paths,
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

Canal_Strings :: struct {
	lands: [2]string,
	seas:  [2]string,
}
Sea_Distances :: struct {
	seas_2_moves_away: Seas_2_Moves_Away,
	adjacent_seas:     SA_Adjacent_S2S,
}

Sea_2_Moves_Away :: struct {
	sea:      ^Sea_Cache,
	mid_seas: sa.Small_Array(MAX_PATHS_TO_SEA, ^Sea_Cache),
}

SEAS_STRINGS :: [?]string{"Pacific", "Atlantic", "Baltic"}
SEA_CONNECTIONS :: [?][2]string{{"Pacific", "Atlantic"}, {"Atlantic", "Baltic"}}
CANALS :: [?]Canal_Strings{{lands = {"Moscow", "Moscow"}, seas = {"Pacific", "Baltic"}}}
Canal_Lands: [CANALS_COUNT][2]^Land_Cache

get_sea_idx_from_string :: proc(sea_name: string) -> (sea_idx: int, ok: bool) {
	for sea_string, sea_idx in SEAS_STRINGS {
		if strings.compare(sea_string, sea_name) == 0 {
			return sea_idx, true
		}
	}
	fmt.eprintln("Error: Sea not found: %s\n", sea_name)
	return 0, false
}
initialize_sea_connections :: proc(seas: ^Seas) -> (ok: bool) {
	for connection in SEA_CONNECTIONS {
		sea1_idx := get_sea_idx_from_string(connection[0]) or_return
		sea2_idx := get_sea_idx_from_string(connection[1]) or_return
		for &canal_path, canal_path_idx in seas[sea1_idx].canal_paths {
			sa.append(&canal_path.adjacent_seas, &seas[sea2_idx])
		}
		for &canal_path, canal_path_idx in seas[sea2_idx].canal_paths {
			sa.append(&canal_path.adjacent_seas, &seas[sea1_idx])
		}
	}
	for canal, canal_idx in CANALS {
		for canal_path_idx in 0 ..< CANAL_STATES {
			if (canal_path_idx & (1 << uint(canal_idx))) == 0 {
				continue
			}
			sea1_idx := get_sea_idx_from_string(canal.seas[0]) or_return
			sea2_idx := get_sea_idx_from_string(canal.seas[1]) or_return
			sa.append(&seas[sea1_idx].canal_paths[canal_path_idx].adjacent_seas, &seas[sea2_idx])
			sa.append(&seas[sea2_idx].canal_paths[canal_path_idx].adjacent_seas, &seas[sea1_idx])
		}
	}
	return true
}

initialize_seas_2_moves_away :: proc(seas: ^Seas) {
	for canal_state in 0 ..< CANAL_STATES {
		// Floyd-Warshall algorithm
		// Initialize distances array to Infinity
		distances: [SEAS_COUNT][SEAS_COUNT]uint
		INFINITY :: 255
		mem.set(&distances, INFINITY, len(distances))
		for &sea, sea_idx in seas {
			// Ensure that the distance from a sea to itself is 0
			distances[sea_idx][sea_idx] = 0
			// Set initial distances based on adjacent seas
			for adjacent_sea in sa.slice(&sea.canal_paths[canal_state].adjacent_seas) {
				distances[sea_idx][adjacent_sea.sea_index] = 1
			}
		}
		for mid_idx in 0 ..< SEAS_COUNT {
			for start_idx in 0 ..< SEAS_COUNT {
				for end_idx in 0 ..< SEAS_COUNT {
					new_dist := distances[start_idx][mid_idx] + distances[mid_idx][end_idx]
					if new_dist < distances[start_idx][end_idx] {
						distances[start_idx][end_idx] = new_dist
					}
				}
			}
		}
		// Initialize the seas_2_moves_away array
		for &sea, sea_idx in seas {
			src_canal_path := &sea.canal_paths[canal_state]
			adjacent_seas := sa.slice(&src_canal_path.adjacent_seas)
			for distance, dest_sea_idx in distances[sea_idx] {
				dest_sea := &seas[dest_sea_idx]
				if distance == 2 {
					dest := Sea_2_Moves_Away {
						sea = dest_sea,
					}
					dest_adj_seas := sa.slice(&dest_sea.canal_paths[canal_state].adjacent_seas)
					for dest_adj_sea in sa.slice(
						&dest_sea.canal_paths[canal_state].adjacent_seas,
					) {
						_ = slice.linear_search(adjacent_seas, dest_adj_sea) or_continue
						sa.push(&dest.mid_seas, dest_adj_sea)
					}
					sa.push(&sea.canal_paths[canal_state].seas_2_moves_away, dest)
				}
			}
		}
	}
}
