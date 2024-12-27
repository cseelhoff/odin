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

resolve_sea_battles::proc(gc: ^Game_Cache) -> (ok: bool) {}
resolve_land_battles::proc(gc: ^Game_Cache) -> (ok: bool) {}
buy_units::proc(gc: ^Game_Cache) -> (ok: bool) {}
reset_units_fully::proc(gc: ^Game_Cache) -> (ok: bool) {}
buy_factory::proc(gc: ^Game_Cache) -> (ok: bool) {}
collect_money::proc(gc: ^Game_Cache) -> (ok: bool) {}
rotate_turns::proc(gc: ^Game_Cache) -> (ok: bool) {}