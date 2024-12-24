package oaaa
import sa "core:container/small_array"
import "core:mem"
import "core:slice"

Fighters_Expended_Moves := [?]Active_Air_Unit {
	.FIGHTERS_AIR_4_MOVES_LEFT,
	.FIGHTERS_AIR_3_MOVES_LEFT,
	.FIGHTERS_AIR_2_MOVES_LEFT,
	.FIGHTERS_AIR_1_MOVES_LEFT,
	.FIGHTERS_AIR_0_MOVES_LEFT,
}
 
move_unmoved_fighters :: proc(gc: ^Game_Cache) -> (ok: bool) {
	debug_checks(gc)
	clear_needed := false
	defer if(clear_needed) { clear_move_history(gc) }
	for src_air in gc.territories {
		if (src_air.active_air_units[Active_Air_Unit.Active_Air_Unit] == 0) {
			continue
		}
		if (!clear_needed) {
			refresh_can_fighters_land_here(gc)
			clear_needed = true
		}
		sa.resize(&gc.valid_moves, 1)
		dst_air_idx = src_air.territory_index
		gc.valid_moves.data[0] = dst_air_idx
		add_valid_fighter_moves(gc, src_air)
		for src_air.active_air_units[Active_Air_Unit.Active_Air_Unit] > 0 {
			if (gc.valid_moves.len > 1) {
				if (gc.answers_remaining == 0) {
					return true
				}
				dst_air_idx = get_move_input(gc, .FIGHTERS_AIR_UNMOVED, src_air)
			}
			dst_air := gc.territories[dst_air_idx]
			update_move_history(gc, src_air, dst_air_idx)
			airDistance := src_air.air_distances[dst_air_idx]
			if (dst_air.teams_unit_count[gc.current_turn.team.enemy_team.index] > 0) {
				dst_air.combat_status = .PRE_COMBAT
			} else {
				airDistance = 4 // Maximum move for fighters
			}
			dst_air.active_air_units[Fighters_Expended_Moves[airDistance]] += 1
			dst_air.idle_air_units[gc.current_turn.index][Idle_Air_Unit.Idle_Air_Unit] += 1
			// total_player_units_player.at(dst_air_idx) += 1
			dst_air.teams_unit_count[gc.current_turn.team.index] += 1
			src_air.active_air_units[Active_Air_Unit.Active_Air_Unit] -= 1
			src_air.idle_air_units[gc.current_turn.index][Idle_Air_Unit.Idle_Air_Unit] -= 1
			// total_player_units_player.at(src_air) -= 1
			src_air.teams_unit_count[gc.current_turn.team.index] -= 1
		}
	}
	return true
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
		if sea.active_sea_units[Active_Sea_Unit.Active_Sea_Unit] > 0 {
			for adj_sea in sa.slice(&sea.canal_paths[gc.canal_state].adjacent_seas) {
				fighter_can_land_here(adj_sea)
			}
			for sea_2_moves_away in sa.slice(&sea.canal_paths[gc.canal_state].seas_2_moves_away) {
				fighter_can_land_here(sea_2_moves_away.sea)
			}
		}
	}
}

add_valid_fighter_moves :: proc(gc: ^Game_Cache, src_air: ^Territory) {
	for dst_air in sa.slice(&src_air.adjacent_airs) {
		add_meaningful_fighter_move(gc, src_air, dst_air)
	}
	for dst_air in sa.slice(&src_air.airs_2_moves_away) {
		add_meaningful_fighter_move(gc, src_air, dst_air)
	}
	for dst_air in sa.slice(&src_air.airs_3_moves_away) {
		if dst_air.can_fighter_land_in_1_move {
			add_meaningful_fighter_move(gc, src_air, dst_air)
		}
	}
	for dst_air in sa.slice(&src_air.airs_4_moves_away) {
		if dst_air.can_fighter_land_here {
			add_move_if_not_skipped(gc, src_air, dst_air)
		}
	}
}

add_meaningful_fighter_move :: proc(gc: ^Game_Cache, src_air: ^Territory, dst_air: ^Territory) {
	if dst_air.can_fighter_land_here ||
	   dst_air.teams_unit_count[gc.current_turn.team.enemy_team.index] != 0 {
		add_move_if_not_skipped(gc, src_air, dst_air)
	}
}
