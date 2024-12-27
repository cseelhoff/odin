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
	move_unmoved_fighters(gc) // move before carriers for more options
	move_unmoved_bombers(gc)
	move_dest_crus_bs(gc)
	move_subs(gc)
	move_carriers(gc)
	stage_transport_units(gc)
	move_tanks_2(gc)
	move_tanks_1(gc)
	move_artillery(gc)
	move_infantry(gc)
	skip_empty_transports(gc)
	move_transports(gc)
	resolve_sea_battles(gc)
	unload_transports(gc)
	resolve_land_battles(gc)
	move_aa_guns(gc)
	land_fighter_units(gc)
	land_bomber_units(gc)
	buy_units(gc)
	crash_air_units(gc)
	reset_units_fully(gc)
	buy_factory(gc)
	collect_money(gc)
	rotate_turns(gc)
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

reset_valid_moves :: proc(gc: ^Game_Cache, territory: ^Territory, clear_needed: ^bool) -> (dst_air_idx:int) {
	dst_air_idx = territory.territory_index
	sa.resize(&gc.valid_moves, 1)
	sa.set(&gc.valid_moves, 0, dst_air_idx)
	clear_needed = true
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
		return true
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

resolve_sea_battles::proc(gc: ^Game_Cache) -> (ok: bool) {}
resolve_land_battles::proc(gc: ^Game_Cache) -> (ok: bool) {}
move_aa_guns::proc(gc: ^Game_Cache) -> (ok: bool) {}
buy_units::proc(gc: ^Game_Cache) -> (ok: bool) {}
reset_units_fully::proc(gc: ^Game_Cache) -> (ok: bool) {}
buy_factory::proc(gc: ^Game_Cache) -> (ok: bool) {}
collect_money::proc(gc: ^Game_Cache) -> (ok: bool) {}
rotate_turns::proc(gc: ^Game_Cache) -> (ok: bool) {}