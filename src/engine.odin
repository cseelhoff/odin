package oaaa
import sa "core:container/small_array"
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
	// move_unmoved_bombers
	// stage_transport_units(state)
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

update_move_history_4air :: proc(gc: ^Game_Cache, src_air: ^Territory, dst_air: ^Territory) {
	// std::vector<uint>& valid_moves = state.cache.valid_moves;
	// // get a list of newly skipped valid_actions
	// while (true) {
	//   uint valid_action = valid_moves.back();
	//   if (valid_action == dst_air) {
	//     break;
	//   }
	//   assert(valid_moves.size() > 0);
	//   state.skipped_moves[src_air][valid_action] = true;
	//   apply_skip(state, src_air, valid_action);
	//   valid_moves.pop_back();
	// }
}

clear_move_history ::proc(gc: ^Game_Cache) {
}

move_unmoved_fighters :: proc(gc: ^Game_Cache) -> (ok: bool) {
	debug_checks(gc)
	refresh_occured: bool = false
	enemy_team_idx: int = gc.current_turn.team.enemy_team.index
	for src_air in gc.territories {
		if (src_air.active_air_units[Active_Air_Unit_Type.FIGHTERS_AIR_UNMOVED] == 0) {
			continue
		}
		if (!refresh_occured) {
			refresh_can_fighters_land_here(gc)
			refresh_occured = true
		}
		sa.resize(&gc.valid_moves, 1)
		gc.valid_moves.data[0] = src_air.territory_index
		add_valid_fighter_moves(gc, src_air)
		for src_air.active_air_units[Active_Air_Unit_Type.FIGHTERS_AIR_UNMOVED] > 0 {
			dst_air_idx := gc.valid_moves.data[0]
			if (gc.valid_moves.len > 1) {
				if (gc.answers_remaining == 0) {
					return true
				}
				dst_air_idx = get_user_move_input(gc, .FIGHTERS_AIR_UNMOVED, src_air)
			}
			dst_air := gc.territories[dst_air_idx]
			update_move_history_4air(gc, src_air, dst_air)
			airDistance: uint = src_air.air_distances[dst_air_idx]
			if (dst_air.teams_unit_count[enemy_team_idx] > 0) {
				dst_air.combat_status = .PRE_COMBAT
			} else {
				airDistance = 4 // Maximum move for fighters
			}
			dst_air.active_air_units[Fighters_Expended_Moves[airDistance]] += 1
			dst_air.idle_air_units[gc.current_turn.index][Idle_Air_Unit_Type.FIGHTERS_AIR] += 1
			// total_player_units_player.at(dst_air_idx) += 1
			dst_air.teams_unit_count[gc.current_turn.team.index] += 1
			src_air.active_air_units[Active_Air_Unit_Type.FIGHTERS_AIR_UNMOVED] -= 1
			src_air.idle_air_units[gc.current_turn.index][Idle_Air_Unit_Type.FIGHTERS_AIR] -= 1
			// total_player_units_player.at(src_air) -= 1
			src_air.teams_unit_count[gc.current_turn.team.index] -= 1
		}
	}
	if (refresh_occured) {
		clear_move_history(gc)
	}
	return false
}
fighter_can_land_here :: proc(territory: ^Territory) {
	territory.can_fighter_land_here = true
	for air in sa.slice(&territory.adjacent_airs) {
		air.can_fighter_land_in_1_move = true
	}
}

refresh_can_fighters_land_here :: proc(gc: ^Game_Cache) {
	// initialize all to false
	for territory in gc.territories {
		territory.can_fighter_land_here = false
		territory.can_fighter_land_in_1_move = false
	}
	for &land in gc.lands {
		// is allied owned and not recently conquered?
		if gc.current_turn.team == land.owner.team &&
		   land.combat_status == Combat_Status.NO_COMBAT {
			fighter_can_land_here(&land.territory)
		}
		// check for possiblity to build carrier under fighter
		if (land.owner == gc.current_turn && land.factory_max_damage > 0) {
			for &sea in sa.slice(&land.adjacent_seas) {
				fighter_can_land_here(&sea.territory)
			}
		}
	}
	for &sea in gc.seas {
		if sea.allied_carriers > 0 {
			fighter_can_land_here(&sea.territory)
		}
		// if player owns a carrier, then landing area is 2 spaces away
		if sea.active_sea_units[Active_Sea_Unit_Type.CARRIERS_UNMOVED] > 0 {
			for adj_sea in sa.slice(&sea.canal_paths[gc.canal_state].adjacent_seas) {
				fighter_can_land_here(adj_sea)
			}
			for sea_2_moves_away in sa.slice(&sea.canal_paths[gc.canal_state].seas_2_moves_away) {
				fighter_can_land_here(sea_2_moves_away.sea)
			}
		}
	}
}

bomber_can_land_here :: proc(territory: ^Territory) {
	territory.can_bomber_land_here = true
	for air in sa.slice(&territory.adjacent_airs) {
		air.can_bomber_land_in_1_move = true
	}
	for air in sa.slice(&territory.airs_2_moves_away) {
		air.can_bomber_land_in_2_moves = true
	}
}

refresh_can_bombers_land_here :: proc(gc: ^Game_Cache) {
	// initialize all to false
	for territory in gc.territories {
		territory.can_bomber_land_here = false
		territory.can_bomber_land_in_1_move = false
		territory.can_bomber_land_in_2_moves = false
	}
	// check if any bombers have full moves remaining
	for &land in gc.lands {
		// is allied owned and not recently conquered?
		if gc.current_turn.team == land.owner.team &&
		   land.combat_status == .NO_COMBAT {
			bomber_can_land_here(&land)
		}
	}
}

add_valid_fighter_moves :: proc(gc: ^Game_Cache, territory: ^Territory) {
}