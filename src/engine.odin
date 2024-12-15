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
	move_air_units(gc)
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

move_air_units :: proc(gc: ^Game_Cache) -> (ok: bool) {
	debug_checks(gc)
	refresh_occured: bool = false
	for src_air in gc.territories {
		unit := Active_Air_Unit_Type.FIGHTERS_AIR_UNMOVED
		if (src_air.active_air_units[unit] == 0) {
			continue
		}
		if (!refresh_occured) {
			refresh_can_planes_land_here(gc, unit)
			refresh_occured = true
		}
		sa.resize(&gc.valid_moves, 1)
		gc.valid_moves.data[0] = src_air.territory_index
		add_valid_air_moves(gc, src_air, unit)
		for src_air.active_air_units[unit] > 0 {
			dst_air_idx := gc.valid_moves.data[0]
			if (gc.valid_moves.len > 1) {
				if (gc.answers_remaining == 0) {
					return true
				}
				dst_air_idx = get_user_move_input(gc, unit, src_air)
			}
			dst_air := &gc.territories[dst_air_idx]
			if (unit in Is_Fighter) { 	// todo bombers
				update_move_history_4air(state, src_air, dst_air)
			}
			if (src_air == dst_air) {
        // this is a rare case where an enemy ship is purchased under a unit
        if (unit_type == FIGHTERS_AIR && team_units_count_enemy.at(dst_air) > 0) {
          combat_status[dst_air] = Combat_Status.PRE_COMBAT;
          continue;
        }
				src_air.active_air_units[Active_Air_Unit_Type.FIGHTERS_AIR_0_MOVES_LEFT] +=
					src_air.active_air_units[unit]
				src_air.active_air_units[unit] = 0
			}
			airDistance: uint = AIR_DIST[src_air][dst_air_idx]
			if (team_units_count_enemy.at(dst_air_idx) > 0 ||
				   (unit == BOMBERS_AIR &&
						   factory_dmg[dst_air_idx] < factory_max[dst_air_idx] * 2 &&
						   !canBomberLandHere[dst_air_idx])) {
				combat_status[dst_air_idx] = PRE_COMBAT
			} else {
				airDistance = max_move_air
			}
			get_active_air_units(state, dst_air_idx, unit).at(max_move_air - airDistance) += 1
			get_idle_air_units(state, player_idx, dst_air_idx, unit) += 1
			total_player_units_player.at(dst_air_idx) += 1
			team_units_count_team.at(dst_air_idx) += 1
			src_air.active_air_units[unit] -= 1
			get_idle_air_units(state, player_idx, src_air, unit) -= 1
			total_player_units_player.at(src_air) -= 1
			team_units_count_team.at(src_air) -= 1
		}
	}
	if (refresh_occured) {
		clear_move_history(state)
	}

	return false
}
refresh_can_planes_land_here :: proc(gc: ^Game_Cache, unit_type: Active_Air_Unit_Type) {
	if unit_type in Is_Fighter {
		refresh_can_fighters_land_here(gc)
	} else {
		refresh_can_bombers_land_here(gc)
	}
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
			for adj_sea in sa.slice(&sea.adjacent_seas) {
				fighter_can_land_here(adj_sea)
			}
			for sea_2_moves_away in sa.slice(&sea.seas_2_moves_away) {
				fighter_can_land_here(sea_2_moves_away)
			}
		}
	}
}

bomber_can_land_here :: proc(territory: ^Territory) {
	territory.can_bomber_land_here = true
	for air in territory.adjacent_airs {
		air.can_bomber_land_in_1_move = true
	}
	for air in territory.airs_2_moves_away {
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
	for land in gc.lands {
		// is allied owned and not recently conquered?
		if gc.current_turn.team == land.owner.team &&
		   land.combat_status == CombatStatus.NO_COMBAT {
			bomber_can_land_here(land)
		}
	}
}

add_valid_air_moves :: proc(
	gc: ^Game_Cache,
	src_air: ^Territory,
	unit_type: Active_Air_Unit_Type,
) {
	if unit_type in Is_Fighter {
		add_valid_fighter_moves(state, src_air)
	} else {
		add_valid_bomber_moves(state, src_air)
	}
}
