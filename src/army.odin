package oaaa

import sa "core:container/small_array"
import "core:fmt"

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
	Active_Army.INF_UNMOVED   = "INF_UNMOVED",
	Active_Army.INF_0_MOVES   = "INF_0_MOVES",
	Active_Army.ARTY_UNMOVED  = "ARTY_UNMOVED",
	Active_Army.ARTY_0_MOVES  = "ARTY_0_MOVES",
	Active_Army.TANK_UNMOVED  = TANK_UNMOVED_NAME,
	Active_Army.TANK_1_MOVES  = TANK_1_MOVES_NAME,
	Active_Army.TANK_0_MOVES  = "TANK_0_MOVES",
	Active_Army.AAGUN_UNMOVED = "AAGUN_UNMOVED",
	Active_Army.AAGUN_0_MOVES = "AAGUN_0_MOVES",
}

Active_Army_To_Idle := [?]Idle_Army {
	Active_Army.INF_UNMOVED   = .INF,
	Active_Army.ARTY_UNMOVED  = .ARTY,
	Active_Army.TANK_UNMOVED  = .TANK,
	Active_Army.AAGUN_UNMOVED = .AAGUN,
}

Armies_Moved := [?]Active_Army {
	Active_Army.INF_UNMOVED   = .INF_0_MOVES,
	Active_Army.ARTY_UNMOVED  = .ARTY_0_MOVES,
	Active_Army.TANK_UNMOVED  = .TANK_0_MOVES,
	Active_Army.AAGUN_UNMOVED = .AAGUN_0_MOVES,
}

Unmoved_Armies := [?]Active_Army {
	Active_Army.INF_UNMOVED,
	Active_Army.ARTY_UNMOVED,
	Active_Army.TANK_UNMOVED,
	Active_Army.TANK_1_MOVES,
	//Active_Army.AAGUN_UNMOVED, //Moved in later phase
}

Army_Size := [?]int {
	Active_Army.INF_UNMOVED  = 2,
	Active_Army.ARTY_UNMOVED = 3,
	Active_Army.TANK_UNMOVED = 3,
	Active_Army.TANK_1_MOVES = 3,
	//Active_Army.AAGUN_UNMOVED = 3, //AAGUN Transports not implemented
}

move_armies :: proc(gc: ^Game_Cache) -> (ok: bool) {
	gc.clear_needed = false
	for army in Unmoved_Armies {
		move_army_lands(gc, army) or_return
		if gc.clear_needed do clear_move_history(gc)
	}
	return true
}

move_army_lands :: proc(gc: ^Game_Cache, army: Active_Army) -> (ok: bool) {
	debug_checks(gc)
	for &src_land in gc.lands {
		move_army_land(gc, army, &src_land) or_return
	}
	return true
}

move_army_land :: proc(gc: ^Game_Cache, army: Active_Army, src_land: ^Land) -> (ok: bool) {
	if src_land.active_armies[army] == 0 do return true
	reset_valid_moves(gc, src_land)
	add_valid_army_moves(gc, src_land, army)
	for src_land.active_armies[army] > 0 {
		move_next_army_in_land(gc, army, src_land) or_return
	}
	return true
}

move_next_army_in_land :: proc(gc: ^Game_Cache, army: Active_Army, src_land: ^Land) -> (ok: bool) {
	dst_air_idx := get_move_input(gc, Army_Names[army], src_land) or_return
	check_load_transport(gc, army, src_land, dst_air_idx) or_return
	dst_land := &gc.lands[dst_air_idx]
	skip_army(src_land, dst_land, army) or_return
	army_after_move := blitz_checks(gc, dst_air_idx, dst_land, army, src_land)
	move_single_army(dst_land, army_after_move, gc.cur_player, army, src_land)
	return true
}

blitz_checks :: proc(
	gc: ^Game_Cache,
	dst_air_idx: int,
	dst_land: ^Land,
	army: Active_Army,
	src_land: ^Land,
) -> Active_Army {
	if !check_for_enemy(gc, dst_air_idx) &&
	   check_for_conquer(gc, dst_land) &&
	   army == .TANK_UNMOVED &&
	   src_land.land_distances[dst_air_idx] == 1 &&
	   dst_land.factory_max_damage == 0 {
		return .TANK_1_MOVES //blitz!
	}
	return Armies_Moved[army]
}

move_single_army :: proc(
	dst_land: ^Land,
	dst_unit: Active_Army,
	player: ^Player,
	src_unit: Active_Army,
	src_land: ^Land,
) {
	dst_land.active_armies[dst_unit] += 1
	dst_land.idle_armies[player.index][Active_Army_To_Idle[dst_unit]] += 1
	dst_land.team_units[player.team.index] += 1
	src_land.active_armies[src_unit] -= 1
	src_land.idle_armies[player.index][Active_Army_To_Idle[dst_unit]] -= 1
	src_land.team_units[player.team.index] -= 1
}

add_valid_army_moves :: proc(gc: ^Game_Cache, src_land: ^Land, army: Active_Army) {
	for dst_land in sa.slice(&src_land.adjacent_lands) {
		if (src_land.skipped_moves[dst_land.territory_index]) do continue
		sa.push(&gc.valid_moves, dst_land.territory_index)
	}
	// check for moving from land to sea (one move away)
	for dst_sea in sa.slice(&src_land.adjacent_seas) {
		idle_ships := &dst_sea.idle_ships[gc.cur_player.index]
		if Army_Size[army] == 3 {
			if idle_ships[Idle_Ship.TRANS_EMPTY] == 0 && idle_ships[Idle_Ship.TRANS_1I] == 0 {
				continue
			}
		} else { 	// assume small army
			if idle_ships[Idle_Ship.TRANS_EMPTY] == 0 &&
			   idle_ships[Idle_Ship.TRANS_1I] == 0 &&
			   idle_ships[Idle_Ship.TRANS_1A] == 0 &&
			   idle_ships[Idle_Ship.TRANS_1T] == 0 {
				continue
			}
		}
		if (!src_land.skipped_moves[dst_sea.territory_index]) {
			sa.push(&gc.valid_moves, dst_sea.territory_index)
		}
	}
}

skip_army :: proc(src_land: ^Land, dst_land: ^Land, army: Active_Army) -> (ok: bool) {
	if src_land != dst_land do return true
	src_land.active_armies[Armies_Moved[army]] += src_land.active_armies[army]
	src_land.active_armies[army] = 0
	return false
}

check_load_transport :: proc(
	gc: ^Game_Cache,
	army: Active_Army,
	src_land: ^Land,
	dst_air_idx: int,
) -> (
	ok: bool,
) {
	if dst_air_idx < len(LANDS_DATA) do return true
	dst_sea := &gc.seas[dst_air_idx - len(LANDS_DATA)]
	load_available_transport(army, src_land, dst_sea, gc.cur_player.index)
	sa.resize(&gc.valid_moves, 1) // reset valid moves since transport cargo has changed
	add_valid_army_moves(gc, src_land, army) //reset valid moves since transport cargo has changed
	return false
}

load_available_transport :: proc(
	army: Active_Army,
	src_land: ^Land,
	dst_sea: ^Sea,
	player_idx: int,
) {
	if Army_Size[army] == 2 {
		for transport in Transport_Can_Load_Small {
			if dst_sea.active_ships[transport] > 0 {
				load_specific_transport(src_land, dst_sea, transport, army, player_idx)
				return
			}
		}
	}
	for transport in Transport_Can_Load_Large {
		if dst_sea.active_ships[transport] > 0 {
			load_specific_transport(src_land, dst_sea, transport, army, player_idx)
			return
		}
	}
	fmt.eprintln("Error: No large transport available to load\n")
}

load_specific_transport :: proc(
	src_land: ^Land,
	dst_sea: ^Sea,
	ship: Active_Ship,
	army: Active_Army,
	player_idx: int,
) {
	idle_army := Active_Army_To_Idle[army]
	new_ship := Transport_Load_Unit[idle_army][ship]
	dst_sea.active_ships[new_ship] += 1
	dst_sea.idle_ships[player_idx][Active_Ship_To_Idle[new_ship]] += 1
	src_land.active_armies[army] -= 1
	src_land.idle_armies[player_idx][idle_army] -= 1
}
