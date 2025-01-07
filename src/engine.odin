package oaaa
import sa "core:container/small_array"
import "core:fmt"
import "core:mem"
import "core:slice"

when ODIN_DEBUG {
	debug_checks :: proc(gc: ^Game_Cache) {
		// No-op
	}
} else {
	debug_checks :: proc(gc: ^Game_Cache) {
		// Add your debug checks here
	}
}
play_full_turn :: proc(gc: ^Game_Cache) -> (ok: bool) {
	move_unmoved_planes(gc) or_return // move before carriers for more options
	move_combat_ships(gc) or_return
	stage_transports(gc) or_return
	move_armies(gc) or_return
	move_transports(gc) or_return
	resolve_sea_battles(gc) or_return
	unload_transports(gc) or_return
	resolve_land_battles(gc) or_return
	move_aa_guns(gc) or_return
	land_fighter_units(gc) or_return
	land_bomber_units(gc) or_return
	buy_units(gc) or_return
	crash_air_units(gc) or_return
	reset_units_fully(gc) or_return
	buy_factory(gc) or_return
	collect_money(gc) or_return
	rotate_turns(gc) or_return
	return true
}

add_move_if_not_skipped :: proc(gc: ^Game_Cache, src_air: ^Territory, dst_air: ^Territory) {
	if !src_air.skipped_moves[dst_air.territory_index] {
		sa.push(&gc.valid_moves, int(dst_air.territory_index))
	}
}

add_buy_if_not_skipped :: proc(gc: ^Game_Cache, src_air: ^Territory, action: Buy_Action) {
	if !src_air.skipped_buys[int(action)] {
		sa.push(&gc.valid_moves, buy_to_action_idx(action))
	}
}

update_move_history :: proc(gc: ^Game_Cache, src_air: ^Territory, dst_air_idx: Air_ID) {
	// get a list of newly skipped valid_actions
	assert(gc.valid_moves.len > 0)
	valid_action := gc.valid_moves.data[gc.valid_moves.len - 1]
	for {
		if (Air_ID(valid_action) == dst_air_idx) do break
		src_air.skipped_moves[valid_action] = true
		//apply_skip(gc, src_air, gc.territories[valid_action])
		valid_action = sa.pop_back(&gc.valid_moves)
	}
	gc.clear_needed = true
}

// apply_skip :: proc(gc: ^Game_Cache, src_air: ^Territory, dst_air: ^Territory) {
// 	for skipped_move, src_air_idx in dst_air.skipped_moves {
// 		if skipped_move {
// 			src_air.skipped_moves[src_air_idx] = true
// 		}
// 	}
// }

clear_move_history :: proc(gc: ^Game_Cache) {
	for territory in gc.territories {
		mem.zero_slice(territory.skipped_moves[:])
	}
}

reset_valid_moves :: proc(gc: ^Game_Cache, territory: ^Territory) { 	// -> (dst_air_idx: int) {
	gc.valid_moves.len = 1
	gc.valid_moves.data[0] = int(territory.territory_index)
}

reset_units_fully :: proc(gc: ^Game_Cache) -> (ok: bool) {
	return false
}
buy_factory :: proc(gc: ^Game_Cache) -> (ok: bool) {
	return false
}
collect_money :: proc(gc: ^Game_Cache) -> (ok: bool) {
	return false
}
rotate_turns :: proc(gc: ^Game_Cache) -> (ok: bool) {
	return false
}
