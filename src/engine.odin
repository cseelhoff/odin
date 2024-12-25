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
	stage_transport_units(gc)
	move_tanks_2(gc)
	move_tanks_1(gc)
	move_artillery(gc)
	move_infantry(gc)
	move_unmoved_fighters(gc) // move before carriers for more options
	move_unmoved_bombers(gc) // move after land for aa capture
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

move_land_unit :: proc(
	dst_land: ^Land,
	dst_unit: Active_Land_Unit,
	player: ^Player,
	src_unit: Active_Land_Unit,
	src_land: ^Land,
) {
	dst_land.active_land_units[dst_unit] += 1
	dst_land.idle_land_units[player.index][Idle_Land_From_Active[dst_unit]] += 1
	dst_land.teams_unit_count[player.team.index] += 1
	src_land.active_land_units[src_unit] -= 1
	src_land.idle_land_units[player.index][Idle_Land_From_Active[dst_unit]] -= 1
	src_land.teams_unit_count[player.team.index] -= 1
	src_land.active_land_units[src_unit] -= 1
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

add_valid_large_land_moves :: proc(gc: ^Game_Cache, src_land: ^Land) {
	for dst_land in sa.slice(&src_land.adjacent_lands) {
		if (src_land.skipped_moves[dst_land.territory_index]) do continue
		sa.push(&gc.valid_moves, dst_land.territory_index)
	}
	// check for moving from land to sea (one move away)
	for dst_sea in sa.slice(&src_land.adjacent_seas) {
		idle_sea_units := dst_sea.idle_sea_units[gc.current_turn.index]
		if (idle_sea_units[Idle_Sea_Unit.TRANS_EMPTY] == 0 &&
			   idle_sea_units[Idle_Sea_Unit.TRANS_1I] == 0) { 	// large
			continue
		}
		if (!src_land.skipped_moves[dst_sea.territory_index]) {
			sa.push(&gc.valid_moves, dst_sea.territory_index)
		}
	}
}

conquer_land :: proc(gc: ^Game_Cache, dst_land: ^Land) -> (ok: bool) {
	player_idx := gc.current_turn.index
	team := gc.current_turn.team
	enemy_team_idx := gc.current_turn.team.enemy_team.index
	old_owner := dst_land.owner
	if old_owner.captial.territory_index == dst_land.territory_index {
		gc.current_turn.money += old_owner.money
		old_owner.money = 0
	}
	old_owner.income_per_turn -= dst_land.value
	new_owner := gc.current_turn
	if team.is_allied[dst_land.original_owner.index] {
		new_owner = dst_land.original_owner
	}
	dst_land.owner = new_owner
	new_owner.income_per_turn += dst_land.value
	if dst_land.factory_max_damage == 0 {
		return
	}
	sa.push(&new_owner.factory_locations, dst_land)
	index, found := slice.linear_search(sa.slice(&old_owner.factory_locations), dst_land)
	if !found {
		fmt.eprint("factory conquered, but not found in owned factory locations")
		return false
	}
	sa.unordered_remove(&old_owner.factory_locations, index)
	return true
}
