package oaaa
import sa "core:container/small_array"
import "core:mem"
import "core:slice"

Transports_Needing_Staging := [?]Active_Sea_Unit_Type {
	.TRANS_EMPTY_UNMOVED,
	.TRANS_1I_UNMOVED,
	.TRANS_1A_UNMOVED,
	.TRANS_1T_UNMOVED,
}

Transports_After_Prestage_0_Moves := [?]Active_Sea_Unit_Type {
	Active_Sea_Unit_Type.TRANS_EMPTY_UNMOVED = .TRANS_EMPTY_2_MOVES_LEFT,
	Active_Sea_Unit_Type.TRANS_1I_UNMOVED    = .TRANS_1I_2_MOVES_LEFT,
	Active_Sea_Unit_Type.TRANS_1A_UNMOVED    = .TRANS_1A_2_MOVES_LEFT,
	Active_Sea_Unit_Type.TRANS_1T_UNMOVED    = .TRANS_1T_2_MOVES_LEFT,
}

Transports_After_Prestage_1_Move := [?]Active_Sea_Unit_Type {
	Active_Sea_Unit_Type.TRANS_EMPTY_UNMOVED = .TRANS_EMPTY_1_MOVE_LEFT,
	Active_Sea_Unit_Type.TRANS_1I_UNMOVED    = .TRANS_1I_1_MOVE_LEFT,
	Active_Sea_Unit_Type.TRANS_1A_UNMOVED    = .TRANS_1A_1_MOVE_LEFT,
	Active_Sea_Unit_Type.TRANS_1T_UNMOVED    = .TRANS_1T_1_MOVE_LEFT,
}

Transports_After_Prestage_2_Moves := [?]Active_Sea_Unit_Type {
	Active_Sea_Unit_Type.TRANS_EMPTY_UNMOVED = .TRANS_EMPTY_0_MOVES_LEFT,
	Active_Sea_Unit_Type.TRANS_1I_UNMOVED    = .TRANS_1I_0_MOVES_LEFT,
	Active_Sea_Unit_Type.TRANS_1A_UNMOVED    = .TRANS_1A_0_MOVES_LEFT,
	Active_Sea_Unit_Type.TRANS_1T_UNMOVED    = .TRANS_1T_0_MOVES_LEFT,
}

TRANSPORT_MOVES_MAX :: 2
stage_transport_units :: proc(gc: ^Game_Cache) -> (ok: bool) {
	debug_checks(gc)
	for unit in Transports_Needing_Staging {
		clear_needed := false
		for &src_sea in gc.seas {
			if (src_sea.active_sea_units[unit] == 0) {
				continue
			}
			clear_needed = true
			sa.resize(&gc.valid_moves, 1)
			gc.valid_moves.data[0] = src_sea.territory_index
			add_valid_transport_moves(gc, &src_sea, 2)
			for src_sea.active_sea_units[unit] > 0 {
				dst_air_idx := gc.valid_moves.data[0]
				if (gc.valid_moves.len > 1) {
					if (gc.answers_remaining == 0) {
						return true
					}
					dst_air_idx = get_user_sea_move_input(gc, unit, &src_sea)
				}
				dst_air := gc.territories[dst_air_idx]
				update_move_history_2sea(gc, &src_sea, dst_air)
				dst_sea_idx := dst_air_idx - len(gc.lands)
				sea_distance := src_sea.canal_paths[gc.canal_state].sea_distance[dst_sea_idx]
				dst_sea := gc.seas[dst_sea_idx]
				if (dst_sea.enemy_blockade_total > 0) {
					dst_air.combat_status = .PRE_COMBAT
					sea_distance = TRANSPORT_MOVES_MAX
				}
				if (src_sea == dst_sea) {
					src_sea.active_sea_units[unit] -= 1
					sea_units.at(done_staging) += unmoved_sea_units
					unmoved_sea_units = 0
					break
				}
				active_transports->at(dst_sea)[staging_state - 1 - sea_distance] += 1
				idle_sea_transports[dst_sea] += 1
				total_player_units.at(dst_air) += 1
				team_units_count_team.at(dst_air) += 1
				transports_with_small_cargo_space.at(dst_sea) += 1
				unmoved_sea_units -= 1
				idle_sea_transports[src_sea] -= 1
				total_player_units.at(src_air) -= 1
				team_units_count_team.at(src_air) -= 1
				transports_with_small_cargo_space[src_sea] -= 1
				if (unit <= TRANS1I) {
					transports_with_large_cargo_space[src_sea] -= 1
					transports_with_large_cargo_space[dst_sea] += 1
				}
			}
		}
		if (clear_needed) {
			clear_move_history(gc)
		}
		return false
	}
}
update_move_history_2sea :: proc(gc: ^Game_Cache, src_sea: ^Sea, dst_air: ^Territory) {
	return
}
add_valid_transport_moves :: proc(gc: ^Game_Cache, src_sea: ^Sea, max_distance: int) {}
