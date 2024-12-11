package main
import sa "core:container/small_array"
import "core:mem"

TERRITORIES_COUNT :: LANDS_COUNT + SEAS_COUNT
MAX_TERRITORY_TO_LAND_CONNECTIONS :: 6
SA_Adjacent_Lands :: sa.Small_Array(MAX_TERRITORY_TO_LAND_CONNECTIONS, ^Land_Cache)

Territory_Cache :: struct {
	//air_distances:              [TERRITORIES_COUNT]uint,
	name:                       string,
	territory_within_6_moves:   SA_Territory_Pointers,
	territory_within_5_moves:   SA_Territory_Pointers,
	territory_within_4_moves:   SA_Territory_Pointers,
	territory_within_3_moves:   SA_Territory_Pointers,
	territory_within_2_moves:   SA_Territory_Pointers,
	airs_1_to_4_moves_away:     SA_Territory_Pointers,
	airs_2_to_4_moves_away:     SA_Territory_Pointers,
	airs_3_to_4_moves_away:     SA_Territory_Pointers,
	airs_4_moves_away:          SA_Territory_Pointers,
	land_within_6_moves:        SA_Land_Pointers,
	land_within_5_moves:        SA_Land_Pointers,
	land_within_4_moves:        SA_Land_Pointers,
	land_within_3_moves:        SA_Land_Pointers,
	land_within_2_moves:        SA_Land_Pointers,
	adjacent_lands:             SA_Adjacent_Lands,
	teams_unit_count:           [TEAMS_COUNT]uint,
	territory_index:            int,
	enemy_fighters_total:       uint,
	can_fighter_land_here:      bool,
	can_fighter_land_in_1_move: bool,
	can_bomber_land_here:       bool,
	can_bomber_land_in_1_move:  bool,
	can_bomber_land_in_2_moves: bool,
}

Coastal_Connection_String :: struct {
	land: string,
	sea:  string,
}

COASTAL_CONNECTIONS := [?]Coastal_Connection_String {
	{land = "Washington", sea = "Pacific"},
	{land = "Washington", sea = "Atlantic"},
	{land = "London", sea = "Atlantic"},
	{land = "London", sea = "Baltic"},
	{land = "Berlin", sea = "Atlantic"},
	{land = "Berlin", sea = "Baltic"},
	{land = "Moscow", sea = "Baltic"},
	{land = "Tokyo", sea = "Pacific"},
}

initialize_territories :: proc(lands: ^Lands, seas: ^Seas, territories: ^Territory_Pointers) {
	for &land, land_idx in lands {
		land.land_index = land_idx
		land.territory_index = land_idx
		territories[land.territory_index] = &land.territory
	}
	for &sea, sea_idx in seas {
		sea.sea_index = sea_idx
		sea.territory_index = sea_idx + LANDS_COUNT
		territories[sea.territory_index] = &sea.territory
	}
}

initialize_costal_connections :: proc(lands: ^Lands, seas: ^Seas) -> (ok: bool) {
	for connection in COASTAL_CONNECTIONS {
		land_idx := get_land_idx_from_string(connection.land) or_return
		sea_idx := get_sea_idx_from_string(connection.sea) or_return
		sa.append(&lands[land_idx].adjacent_seas, &seas[sea_idx])
		sa.append(&seas[sea_idx].adjacent_lands, &lands[land_idx])
	}
	return true
}

initialize_air_dist :: proc(lands: ^Lands, seas: ^Seas, territories: ^Territory_Pointers) {
	distances: [TERRITORIES_COUNT][TERRITORIES_COUNT]uint
	INFINITY :: 255
	mem.set(&distances, INFINITY, len(distances))
	for &territory, territory_index in territories {
		// Ensure that the distance from a land to itself is 0
		distances[territory_index][territory_index] = 0
		// Set initial distances based on adjacent lands
		for adjacent_land in sa.slice(&territory.adjacent_lands) {
			distances[territory_index][adjacent_land.territory_index] = 1
		}
	}
	for &land in lands {
		for adjacent_sea in sa.slice(&land.adjacent_seas) {
			distances[land.territory_index][adjacent_sea.territory_index] = 1
		}
	}
	for &sea in seas {
		for adjacent_sea in sa.slice(&sea.canal_paths[CANAL_STATES - 1].adjacent_seas) {
			distances[sea.territory_index][adjacent_sea.territory_index] = 1
		}
	}
	for mid_idx in 0 ..< TERRITORIES_COUNT {
		for start_idx in 0 ..< TERRITORIES_COUNT {
			for end_idx in 0 ..< TERRITORIES_COUNT {
				new_dist := distances[start_idx][mid_idx] + distances[mid_idx][end_idx]
				if new_dist < distances[start_idx][end_idx] {
					distances[start_idx][end_idx] = new_dist
				}
			}
		}
	}
}
