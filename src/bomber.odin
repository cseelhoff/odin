package oaaa
import sa "core:container/small_array"
import "core:mem"
import "core:slice"

Bombers_Expended_Moves := [?]Active_Air_Unit_Type {
	.BOMBERS_AIR_5_MOVES_LEFT,
	.BOMBERS_AIR_4_MOVES_LEFT,
	.BOMBERS_AIR_3_MOVES_LEFT,
	.BOMBERS_AIR_2_MOVES_LEFT,
	.BOMBERS_AIR_1_MOVES_LEFT,
	.BOMBERS_AIR_0_MOVES_LEFT,
}
move_unmoved_bombers :: proc(gc: ^Game_Cache) -> (ok: bool) {
	debug_checks(gc)
	clear_needed := false
	defer if(clear_needed) { clear_move_history(gc) }
	for src_air in gc.territories {
		if (src_air.active_air_units[Active_Air_Unit_Type.BOMBERS_AIR_UNMOVED] == 0) {
			continue
		}
		if (!clear_needed) {
			refresh_can_bombers_land_here(gc)
			clear_needed = true
		}
		sa.resize(&gc.valid_moves, 1)
		dst_air_idx := src_air.territory_index
		gc.valid_moves.data[0] = dst_air_idx
		add_valid_bomber_moves(gc, src_air)
		for src_air.active_air_units[Active_Air_Unit_Type.BOMBERS_AIR_UNMOVED] > 0 {
			if (gc.valid_moves.len > 1) {
				if (gc.answers_remaining == 0) {
					return true
				}
				dst_air_idx = get_move_input(gc, .BOMBERS_AIR_UNMOVED, src_air)
			}
			dst_air := gc.territories[dst_air_idx]
			update_move_history(gc, src_air, dst_air_idx)
			airDistance := src_air.air_distances[dst_air_idx]
			if (dst_air.teams_unit_count[gc.current_turn.team.enemy_team.index] > 0) {
				dst_air.combat_status = .PRE_COMBAT
			} else {
				airDistance = 6 // Maximum move for bombers
			}
			dst_air.active_air_units[Bombers_Expended_Moves[airDistance]] += 1
			dst_air.idle_air_units[gc.current_turn.index][Idle_Air_Unit_Type.BOMBERS_AIR] += 1
			// total_player_units_player.at(dst_air_idx) += 1
			dst_air.teams_unit_count[gc.current_turn.team.index] += 1
			src_air.active_air_units[Active_Air_Unit_Type.BOMBERS_AIR_UNMOVED] -= 1
			src_air.idle_air_units[gc.current_turn.index][Idle_Air_Unit_Type.BOMBERS_AIR] -= 1
			// total_player_units_player.at(src_air) -= 1
			src_air.teams_unit_count[gc.current_turn.team.index] -= 1
		}
	}
	return true
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
		if gc.current_turn.team == land.owner.team && land.combat_status == .NO_COMBAT {
			bomber_can_land_here(&land)
		}
	}
}
add_valid_bomber_moves :: proc(gc: ^Game_Cache, src_air: ^Territory) {
	for dst_air in sa.slice(&src_air.adjacent_airs) {
		add_meaningful_bomber_move(gc, src_air, dst_air)
	}
	for dst_air in sa.slice(&src_air.airs_2_moves_away) {
		add_meaningful_bomber_move(gc, src_air, dst_air)
	}
	for dst_air in sa.slice(&src_air.airs_3_moves_away) {
		add_meaningful_bomber_move(gc, src_air, dst_air)
	}
	for dst_air in sa.slice(&src_air.airs_4_moves_away) {
		if dst_air.can_bomber_land_in_2_moves {
			add_meaningful_bomber_move(gc, src_air, dst_air)
		}
	}
	for dst_air in sa.slice(&src_air.airs_5_moves_away) {
		if dst_air.can_bomber_land_in_1_move {
			add_meaningful_bomber_move(gc, src_air, dst_air)
		}
	}
	for dst_air in sa.slice(&src_air.airs_6_moves_away) {
		if dst_air.can_bomber_land_here {
			add_move_if_not_skipped(gc, src_air, dst_air)
		}
	}
}
add_meaningful_bomber_move :: proc(gc: ^Game_Cache, src_air: ^Territory, dst_air: ^Territory) {
	if dst_air.can_bomber_land_here ||
	   dst_air.teams_unit_count[gc.current_turn.team.enemy_team.index] != 0 ||
	   dst_air.territory_index < len(gc.lands) &&
		   gc.lands[dst_air.territory_index].factory_damage <
			   gc.lands[dst_air.territory_index].factory_max_damage * 2 {
		add_move_if_not_skipped(gc, src_air, dst_air)
	}
}
