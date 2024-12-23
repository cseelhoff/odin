package oaaa
import sa "core:container/small_array"
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
	// move_land_unit_type(state, TANKS)
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

get_user_move_input :: proc(
	gc: ^Game_Cache,
	unit_type: Active_Air_Unit_Type,
	src_air: ^Territory,
) -> (
	dst_air: int,
) {
	// if (PLAYERS[state.current_turn].is_human) {
	//   std::ostringstream oss;
	//   oss << "Moving ";
	//   if (src_air < LANDS_COUNT) {
	//     oss << NAMES_UNIT_LAND[unit_type] << " From: " << LANDS[src_air].name;
	//   } else {
	//     oss << NAMES_UNIT_SEA[unit_type] << " From: " << SEAS[src_air - LANDS_COUNT].name;
	//   }
	//   oss << " Valid Moves: ";
	//   std::vector<uint>& valid_moves = state.cache.valid_moves;
	//   for (uint valid_move : valid_moves) {
	//     oss << valid_move << " ";
	//   }
	//   return getUserInput(state);
	// }
	// return getAIInput(state);
	return 0
}
get_user_sea_move_input :: proc(gc: ^Game_Cache, unit: Active_Sea_Unit_Type, src_sea: ^Sea) -> (dst_sea_idx: int) {
	return 0
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
		if (valid_action == dst_air_idx) {
			break
		}
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
