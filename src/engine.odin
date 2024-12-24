package oaaa
import sa "core:container/small_array"
import "core:fmt"
import "core:mem"
import "core:slice"

NDEBUG :: false
when NDEBUG {
	debug_checks :: proc(gc: ^Game_Cache) {
		// No-op
	}
} else {
	debug_checks :: proc(gc: ^Game_Cache) {
		// Add your debug checks here
	}
}
play_full_turn :: proc(gc: ^Game_Cache) -> (ok: bool) {
	move_unmoved_fighters(gc)
	move_unmoved_bombers(gc)
	stage_transport_units(gc)
	move_tanks_2(gc)
	// move_land_unit_type(state, ARTILLERY)
	// move_land_unit_type(state, INFANTRY)
	// move_subs_battleships(state)
	// resolve_sea_battles(state)
	// unload_transports(state)
	// resolve_land_battles(state)
	// move_land_unit_type(state, AAGUNS)
	// land_fighter_units(state)
	// land_bomber_units(state)
	// buy_units(state)
	// crash_air_units(state)
	// reset_units_fully(state)
	// buy_factory(state)
	// collect_money(state)
	// rotate_turns(state)
	return true
}

add_move_if_not_skipped :: proc(gc: ^Game_Cache, src_air: ^Territory, dst_air: ^Territory) {
	if !src_air.skipped_moves[dst_air.territory_index] {
		sa.push(&gc.valid_moves, dst_air.territory_index)
	}
}

update_move_history :: proc(gc: ^Game_Cache, src_air: ^Territory, dst_air_idx: int) {
	// get a list of newly skipped valid_actions
	assert(gc.valid_moves.len > 0)
	valid_action := gc.valid_moves.data[gc.valid_moves.len - 1]
	for {
		if (valid_action == dst_air_idx) do break
		src_air.skipped_moves[valid_action] = true
		apply_skip(gc, src_air, gc.territories[valid_action])
		valid_action = sa.pop_back(&gc.valid_moves)
	}
}

apply_skip :: proc(gc: ^Game_Cache, src_air: ^Territory, dst_air: ^Territory) {
	for skipped_move, src_air_idx in dst_air.skipped_moves {
		if skipped_move {
			src_air.skipped_moves[src_air_idx] = true
		}
	}
}

clear_move_history :: proc(gc: ^Game_Cache) {
	for territory in gc.territories {
		mem.zero_slice(territory.skipped_moves[:])
	}
}

move_tanks_2 :: proc(gc: ^Game_Cache) -> (ok: bool) {
	debug_checks(gc)
	player_idx := gc.current_turn.index
	team := gc.current_turn.team
	enemy_team_idx := gc.current_turn.team.enemy_team.index
	clear_needed := false
	defer if (clear_needed) {clear_move_history(gc)}
	for &src_land, src_land_idx in gc.lands {
		if (src_land.active_land_units[Active_Land_Unit_Type.TANKS_UNMOVED] == 0) do continue
		clear_needed = true
		sa.resize(&gc.valid_moves, 1)
		dst_air_idx := src_land.territory_index
		gc.valid_moves.data[0] = dst_air_idx
		add_valid_tank_2_moves(gc, &src_land)
		for src_land.active_land_units[Active_Land_Unit_Type.TANKS_UNMOVED] > 0 {
			if (gc.valid_moves.len > 1) {
				if (gc.answers_remaining == 0) do return true
				dst_air_idx = get_user_land_move_input(
					gc,
					Active_Land_Unit_Type.TANKS_UNMOVED,
					&src_land,
				)
			}
			update_move_history(gc, &src_land.territory, dst_air_idx)

			if (dst_air_idx >= LANDS_COUNT) {
				load_transport(gc, .TANKS_UNMOVED, src_land, gc.seas[dst_air_idx - LANDS_COUNT])
				// recalculate valid moves since transport cargo has changed
				sa.resize(&gc.valid_moves, 1)
				add_valid_tank_2_moves(gc, &src_land)
				continue
			}
			dst_land := gc.lands[dst_air_idx]
			landDistance := src_land.land_distances[dst_air_idx]
			if (dst_land.teams_unit_count) { 	//combat ends turn
				dst_land.combat_status = CombatStatus.PRE_COMBAT
				landDistance = 2
			} else if (is_allied[land_owners[dst_air]]) { 	//simple relocate ends turn
				landDistance = 2
			} else {
				if dst_land.factory_max_damage > 0 {
					landDistance = 2
				}
				for enemy_player_idx in sa.slice(&team.enemy_team.players) {
					if dst_land.idle_land_units[enemy_player_idx][Idle_Land_Unit_Type.ARTILLERY] >
					   0 {
						landDistance = 2
						break
					}
				}
				conquer_land(state, dst_air)
			}
			switch (landDistance) {
			case 0:
				src_land.active_land_units[Active_Land_Unit_Type.TANKS_0_MOVES_LEFT] +=
					src_land.active_land_units[Active_Land_Unit_Type.TANKS_UNMOVED]
				src_land.active_land_units[Active_Land_Unit_Type.TANKS_UNMOVED] = 0
				break
			case 1:
				dst_land.active_land_units[Active_Land_Unit_Type.TANKS_1_MOVE_LEFT] += 1
			case 2:
				dst_land.active_land_units[Active_Land_Unit_Type.TANKS_0_MOVES_LEFT] += 1
			}
			dst_land.idle_land_units[player_idx][Idle_Land_Unit_Type.TANKS] += 1
			dst_land.teams_unit_count[team_idx] += 1
			src_land.active_land_units[Active_Land_Unit_Type.TANKS_UNMOVED] -= 1
			src_land.idle_land_units[player_idx][Idle_Land_Unit_Type.TANKS] -= 1
			src_land.teams_unit_count[team_idx] -= 1
			src_land.active_land_units[Active_Land_Unit_Type.TANKS_UNMOVED] -= 1
		}
	}
	return true
}

add_valid_sea_moves :: proc(gc: ^Game_Cache, src_sea: ^Sea, max_distance: int) {
	for dst_sea in sa.slice(&src_sea.canal_paths[gc.canal_state].adjacent_seas) {
		if (src_sea.skipped_moves[dst_sea.territory_index]) {
			continue
		}
		sa.push(&gc.valid_moves, dst_sea.territory_index)
	}
	if max_distance == 1 do return
	for &dst_sea_2_away in sa.slice(&src_sea.canal_paths[gc.canal_state].seas_2_moves_away) {
		if (src_sea.skipped_moves[dst_sea_2_away.sea.territory_index]) {
			continue
		}
		for mid_sea in sa.slice(&dst_sea_2_away.mid_seas) {
			if (!mid_sea.sea_path_blocked) {
				sa.push(&gc.valid_moves, dst_sea_2_away.sea.territory_index)
				break
			}
		}
	}
}

add_valid_tank_2_moves :: proc(gc: ^Game_Cache, src_land: ^Land) {
	// check for moving from land to land (two moves away)
	for dst_land in sa.slice(&src_land.lands_2_moves_away) {
		if (src_land.skipped_moves[dst_land.territory_index]) do continue
		sa.push(&gc.valid_moves, dst_land.territory_index)
	}
	// check for moving from land to sea (two moves away)
	for (dst_sea in sa.slice(&src_land.seas_2_moves_away)) {
		idle_sea_units := dst_sea.sea.idle_sea_units[gc.current_turn.index]
		if (idle_sea_units[Idle_Sea_Unit_Type.TRANS_EMPTY] == 0 &&
			   idle_sea_units[Idle_Sea_Unit_Type.TRANS_1I] == 0) { 	// assume large, only tanks move 2
			continue
		}
		if (src_land.skipped_moves[dst_sea.territory_index]) do continue
		for mid_land in sa.slice(&dst_sea.mid_lands) {
			if (!mid_land.land_path_blocked) {
				sa.push(&gc.valid_moves, dst_sea.territory_index)
				break
			}
		}
	}
	add_valid_large_land_moves(gc, src_land)
}

add_valid_large_land_moves :: proc(gc: ^Game_Cache, src_land: ^Land) {
	for dst_land in sa.slice(&src_land.adjacent_lands) {
		if (src_land.skipped_moves[dst_land.territory_index]) do continue
		sa.push(&gc.valid_moves, dst_land.territory_index)
	}
	// check for moving from land to sea (one move away)
	for dst_sea in sa.slice(&src_land.adjacent_seas) {
		idle_sea_units := dst_sea.sea.idle_sea_units[gc.current_turn.index]
		if (idle_sea_units[Idle_Sea_Unit_Type.TRANS_EMPTY] == 0 &&
			   idle_sea_units[Idle_Sea_Unit_Type.TRANS_1I] == 0) { 	// large
			continue
		}
		if (!src_land.skipped_moves[dst_sea.territory_index]) {
			valid_moves.push_back(dst_air)
		}
	}
}

add_valid_infantry_moves :: proc(gc: ^Game_Cache, src_land: ^Land) {
	for dst_land in sa.slice(&src_land.adjacent_lands) {
		if (src_land.skipped_moves[dst_land.territory_index]) do continue
		sa.push(&gc.valid_moves, dst_land.territory_index)
	}
	// check for moving from land to sea (one move away)
	for dst_sea in sa.slice(&src_land.adjacent_seas) {
		idle_sea_units := dst_sea.sea.idle_sea_units[gc.current_turn.index]
		if (idle_sea_units[Idle_Sea_Unit_Type.TRANS_EMPTY] == 0 &&
			   idle_sea_units[Idle_Sea_Unit_Type.TRANS_1I] == 0 &&
			   idle_sea_units[Idle_Sea_Unit_Type.TRANS_1A] == 0 &&
			   idle_sea_units[Idle_Sea_Unit_Type.TRANS_1T] == 0) { 	// small
			continue
		}
		if (!src_land.skipped_moves[dst_sea.territory_index]) {
			valid_moves.push_back(dst_air)
		}
	}
}
