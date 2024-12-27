package oaaa

import sa "core:container/small_array"

Idle_Army :: enum {
	INF,
	ARTY,
	TANK,
	AAGUN,
}

Active_Army :: enum {
	INF_UNMOVED,
	INF_0_MOVES,
	ARTY_UNMOVED,
	ARTY_0_MOVES,
	TANK_UNMOVED,
	TANK_1_MOVES,
	TANK_0_MOVES,
	AAGUN_UNMOVED,
	AAGUN_0_MOVES,
}

Army_Names := [?]string {
	Active_Army.INF_UNMOVED = "INF_UNMOVED",
	Active_Army.INF_0_MOVES = "INF_0_MOVES",
	Active_Army.ARTY_UNMOVED = "ARTY_UNMOVED",
	Active_Army.ARTY_0_MOVES = "ARTY_0_MOVES",
	Active_Army.TANK_UNMOVED = TANK_UNMOVED_NAME,
	Active_Army.TANK_1_MOVES = TANK_1_MOVES_NAME,
	Active_Army.TANK_0_MOVES = "TANK_0_MOVES",
	Active_Army.AAGUN_UNMOVED = "AAGUN_UNMOVED",
	Active_Army.AAGUN_0_MOVES = "AAGUN_0_MOVES",
}

Active_Army_To_Idle := [?]Idle_Army {
	Active_Army.INF_UNMOVED = .INF,
	Active_Army.ARTY_UNMOVED = .ARTY,
	Active_Army.TANK_UNMOVED = .TANK,
	Active_Army.AAGUN_UNMOVED = .AAGUN,
}

move_army :: proc(
	dst_land: ^Land,
	dst_unit: Active_Army,
	player: ^Player,
	src_unit: Active_Army,
	src_land: ^Land,
) {
	dst_land.active_armies[dst_unit] += 1
	dst_land.idle_armies[player.index][Active_Army_To_Idle[dst_unit]] += 1
	dst_land.teams_unit_count[player.team.index] += 1
	src_land.active_armies[src_unit] -= 1
	src_land.idle_armies[player.index][Active_Army_To_Idle[dst_unit]] -= 1
	src_land.teams_unit_count[player.team.index] -= 1
}

add_valid_large_army_moves :: proc(gc: ^Game_Cache, src_land: ^Land) {
	for dst_land in sa.slice(&src_land.adjacent_lands) {
		if (src_land.skipped_moves[dst_land.territory_index]) do continue
		sa.push(&gc.valid_moves, dst_land.territory_index)
	}
	// check for moving from land to sea (one move away)
	for dst_sea in sa.slice(&src_land.adjacent_seas) {
		idle_ships := dst_sea.idle_ships[gc.current_turn.index]
		if (idle_ships[Idle_Ship.TRANS_EMPTY] == 0 &&
			   idle_ships[Idle_Ship.TRANS_1I] == 0) { 	// large
			continue
		}
		if (!src_land.skipped_moves[dst_sea.territory_index]) {
			sa.push(&gc.valid_moves, dst_sea.territory_index)
		}
	}
}
