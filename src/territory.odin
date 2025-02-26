package oaaa
import sa "core:container/small_array"
import "core:mem"

TERRITORIES_COUNT :: LANDS_COUNT + SEAS_COUNT
MAX_TERRITORY_TO_LAND_CONNECTIONS :: 6
MAX_AIR_TO_AIR_CONNECTIONS :: 7
SA_Adjacent_Lands :: sa.Small_Array(MAX_TERRITORY_TO_LAND_CONNECTIONS, ^Land)
SA_Adjacent_Airs :: sa.Small_Array(MAX_AIR_TO_AIR_CONNECTIONS, ^Territory)

Territory :: struct {
	name:                       string,
	idle_planes:                [PLAYERS_COUNT]Idle_Plane_For_Player,
	active_planes:              [len(Active_Plane)]int,
	air_distances:              [TERRITORIES_COUNT]u8,
	skipped_moves:              [TERRITORIES_COUNT]bool, // Maybe this should be a bitset at the gc level
	skipped_buys:               [len(Buy_Action)]bool,
	combat_status:              Combat_Status,
	//builds_left:                int,
	land_within_6_moves:        SA_Land_Pointers,
	land_within_5_moves:        SA_Land_Pointers,
	land_within_4_moves:        SA_Land_Pointers,
	land_within_3_moves:        SA_Land_Pointers,
	land_within_2_moves:        SA_Land_Pointers,
	adjacent_lands:             SA_Adjacent_Lands,
	adjacent_airs:              SA_Adjacent_Airs,
	airs_2_moves_away:          SA_Territory_Pointers,
	airs_3_moves_away:          SA_Territory_Pointers,
	airs_4_moves_away:          SA_Territory_Pointers,
	airs_5_moves_away:          SA_Territory_Pointers,
	airs_6_moves_away:          SA_Territory_Pointers,
	team_units:                 [TEAMS_COUNT]int,
	territory_index:            Air_ID,
	can_fighter_land_here:      bool, //bitset?
	can_fighter_land_in_1_move: bool,
	can_bomber_land_here:       bool,
	can_bomber_land_in_1_move:  bool,
	can_bomber_land_in_2_moves: bool,
}

Coastal_Connection_String :: struct {
	land: string,
	sea:  string,
}

Air_ID :: enum {
	Washington_Air,
	London_Air,
	Berlin_Air,
	Moscow_Air,
	Tokyo_Air,
	Pacific_Air,
	Atlantic_Air,
	Baltic_Air,
}

is_land :: proc(terr: ^Territory) -> bool {
	return int(terr.territory_index) < LANDS_COUNT
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
		land.land_index = Land_ID(land_idx)
		land.territory_index = Air_ID(land_idx)		
		territories[land.territory_index] = &land.territory
	}
	for &sea, sea_idx in seas {
		sea.sea_index = Sea_ID(sea_idx)
		sea.territory_index = Air_ID(sea_idx + LANDS_COUNT)
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
	for &terr, territory_index in territories {
		INFINITY :: 127 // must be less than half of u8
		mem.set(&terr.air_distances, INFINITY, size_of(terr.air_distances))
		// Ensure that the distance from a land to itself is 0
		terr.air_distances[territory_index] = 0
		// Set initial distances based on adjacent lands
		for adjacent_land in sa.slice(&terr.adjacent_lands) {
			terr.air_distances[adjacent_land.territory_index] = 1
			sa.push(&terr.adjacent_airs, adjacent_land)
		}
	}
	for &land in lands {
		for adjacent_sea in sa.slice(&land.adjacent_seas) {
			land.air_distances[adjacent_sea.territory_index] = 1
			sa.push(&land.adjacent_airs, adjacent_sea)
		}
	}
	for &sea in seas {
		for adjacent_sea in sa.slice(&sea.canal_paths[CANAL_STATES - 1].adjacent_seas) {
			sea.air_distances[adjacent_sea.territory_index] = 1
			sa.push(&sea.adjacent_airs, adjacent_sea)
		}
	}
	for mid_idx in 0 ..< TERRITORIES_COUNT {
		mid_air_dist := &territories[mid_idx].air_distances
		for start_idx in 0 ..< TERRITORIES_COUNT {
			start_air_dist := &territories[start_idx].air_distances
			for end_idx in 0 ..< TERRITORIES_COUNT {
				new_dist := mid_air_dist[start_idx] + mid_air_dist[end_idx]
				if new_dist < start_air_dist[end_idx] {
					start_air_dist[end_idx] = new_dist
				}
			}
		}
	}
	// Initialize the airs_2_moves_away array
	for &terr in territories {
		for distance, dest_air_idx in terr.air_distances {
			if distance == 2 {
				sa.push(&terr.airs_2_moves_away, territories[dest_air_idx])
			}
		}
	}
}
