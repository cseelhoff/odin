package oaaa
import sa "core:container/small_array"
import "core:fmt"
import "core:mem"
import "core:slice"

Transports_Needing_Staging := [?]Active_Sea_Unit {
	.TRANS_EMPTY_UNMOVED,
	.TRANS_1I_UNMOVED,
	.TRANS_1A_UNMOVED,
	.TRANS_1T_UNMOVED,
}

Transports_After_Prestage_0_Moves := [?]Active_Sea_Unit {
	Active_Sea_Unit.TRANS_EMPTY_UNMOVED = .TRANS_EMPTY_2_MOVES_LEFT,
	Active_Sea_Unit.TRANS_1I_UNMOVED    = .TRANS_1I_2_MOVES_LEFT,
	Active_Sea_Unit.TRANS_1A_UNMOVED    = .TRANS_1A_2_MOVES_LEFT,
	Active_Sea_Unit.TRANS_1T_UNMOVED    = .TRANS_1T_2_MOVES_LEFT,
}

Transports_After_Prestage_1_Move := [?]Active_Sea_Unit {
	Active_Sea_Unit.TRANS_EMPTY_UNMOVED = .TRANS_EMPTY_1_MOVE_LEFT,
	Active_Sea_Unit.TRANS_1I_UNMOVED    = .TRANS_1I_1_MOVE_LEFT,
	Active_Sea_Unit.TRANS_1A_UNMOVED    = .TRANS_1A_1_MOVE_LEFT,
	Active_Sea_Unit.TRANS_1T_UNMOVED    = .TRANS_1T_1_MOVE_LEFT,
}

Transports_After_Prestage_2_Moves := [?]Active_Sea_Unit {
	Active_Sea_Unit.TRANS_EMPTY_UNMOVED = .TRANS_EMPTY_0_MOVES_LEFT,
	Active_Sea_Unit.TRANS_1I_UNMOVED    = .TRANS_1I_0_MOVES_LEFT,
	Active_Sea_Unit.TRANS_1A_UNMOVED    = .TRANS_1A_0_MOVES_LEFT,
	Active_Sea_Unit.TRANS_1T_UNMOVED    = .TRANS_1T_0_MOVES_LEFT,
}

Transports_With_Large_Cargo_Space := [?]bool {
	Active_Sea_Unit.TRANS_EMPTY_UNMOVED = true,
	Active_Sea_Unit.TRANS_1I_UNMOVED    = true,
	Active_Sea_Unit.TRANS_1A_UNMOVED    = false,
	Active_Sea_Unit.TRANS_1T_UNMOVED    = false,
}

Transport_Load_Unit := [len(Idle_Land_Unit)][len(Active_Sea_Unit)]Active_Sea_Unit {
	Idle_Land_Unit.INFANTRY = {
		Active_Sea_Unit.TRANS_1T_2_MOVES_LEFT = .TRANS_1I_1T_2_MOVES_LEFT,
		Active_Sea_Unit.TRANS_1A_2_MOVES_LEFT = .TRANS_1I_1A_2_MOVES_LEFT,
		Active_Sea_Unit.TRANS_1I_2_MOVES_LEFT = .TRANS_2I_2_MOVES_LEFT,
		Active_Sea_Unit.TRANS_EMPTY_2_MOVES_LEFT = .TRANS_1I_2_MOVES_LEFT,
		Active_Sea_Unit.TRANS_1T_1_MOVE_LEFT = .TRANS_1I_1T_1_MOVE_LEFT,
		Active_Sea_Unit.TRANS_1A_1_MOVE_LEFT = .TRANS_1I_1A_1_MOVE_LEFT,
		Active_Sea_Unit.TRANS_1I_1_MOVE_LEFT = .TRANS_2I_1_MOVE_LEFT,
		Active_Sea_Unit.TRANS_EMPTY_1_MOVE_LEFT = .TRANS_1I_1_MOVE_LEFT,
		Active_Sea_Unit.TRANS_1T_0_MOVES_LEFT = .TRANS_1I_1T_0_MOVES_LEFT,
		Active_Sea_Unit.TRANS_1A_0_MOVES_LEFT = .TRANS_1I_1A_0_MOVES_LEFT,
		Active_Sea_Unit.TRANS_1I_0_MOVES_LEFT = .TRANS_2I_0_MOVES_LEFT,
		Active_Sea_Unit.TRANS_EMPTY_0_MOVES_LEFT = .TRANS_1I_0_MOVES_LEFT,
	},
	Idle_Land_Unit.ARTILLERY = {
		Active_Sea_Unit.TRANS_1I_2_MOVES_LEFT = .TRANS_1I_1A_2_MOVES_LEFT,
		Active_Sea_Unit.TRANS_EMPTY_2_MOVES_LEFT = .TRANS_1A_2_MOVES_LEFT,
		Active_Sea_Unit.TRANS_1I_1_MOVE_LEFT = .TRANS_1I_1A_1_MOVE_LEFT,
		Active_Sea_Unit.TRANS_EMPTY_1_MOVE_LEFT = .TRANS_1A_1_MOVE_LEFT,
		Active_Sea_Unit.TRANS_1I_0_MOVES_LEFT = .TRANS_1I_1A_0_MOVES_LEFT,
		Active_Sea_Unit.TRANS_EMPTY_0_MOVES_LEFT = .TRANS_1A_0_MOVES_LEFT,
	},
	Idle_Land_Unit.TANKS = {
		Active_Sea_Unit.TRANS_1I_2_MOVES_LEFT = .TRANS_1I_1T_2_MOVES_LEFT,
		Active_Sea_Unit.TRANS_EMPTY_2_MOVES_LEFT = .TRANS_1T_2_MOVES_LEFT,
		Active_Sea_Unit.TRANS_1I_1_MOVE_LEFT = .TRANS_1I_1T_1_MOVE_LEFT,
		Active_Sea_Unit.TRANS_EMPTY_1_MOVE_LEFT = .TRANS_1T_1_MOVE_LEFT,
		Active_Sea_Unit.TRANS_1I_0_MOVES_LEFT = .TRANS_1I_1T_0_MOVES_LEFT,
		Active_Sea_Unit.TRANS_EMPTY_0_MOVES_LEFT = .TRANS_1T_0_MOVES_LEFT,
	},
}

Transport_Load_Large := [?]Active_Sea_Unit {
	Active_Sea_Unit.TRANS_1I_2_MOVES_LEFT,
	Active_Sea_Unit.TRANS_EMPTY_2_MOVES_LEFT,
	Active_Sea_Unit.TRANS_1I_1_MOVE_LEFT,
	Active_Sea_Unit.TRANS_EMPTY_1_MOVE_LEFT,
	Active_Sea_Unit.TRANS_1I_0_MOVES_LEFT,
	Active_Sea_Unit.TRANS_EMPTY_0_MOVES_LEFT,
}

Transport_Load_Small := [?]Active_Sea_Unit {
	Active_Sea_Unit.TRANS_1T_2_MOVES_LEFT,
	Active_Sea_Unit.TRANS_1A_2_MOVES_LEFT,
	Active_Sea_Unit.TRANS_1I_2_MOVES_LEFT,
	Active_Sea_Unit.TRANS_EMPTY_2_MOVES_LEFT,
	Active_Sea_Unit.TRANS_1T_1_MOVE_LEFT,
	Active_Sea_Unit.TRANS_1A_1_MOVE_LEFT,
	Active_Sea_Unit.TRANS_1I_1_MOVE_LEFT,
	Active_Sea_Unit.TRANS_EMPTY_1_MOVE_LEFT,
	Active_Sea_Unit.TRANS_1T_0_MOVES_LEFT,
	Active_Sea_Unit.TRANS_1A_0_MOVES_LEFT,
	Active_Sea_Unit.TRANS_1I_0_MOVES_LEFT,
	Active_Sea_Unit.TRANS_EMPTY_0_MOVES_LEFT,
}

TRANSPORT_MOVES_MAX :: 2
stage_transport_units :: proc(gc: ^Game_Cache) -> (ok: bool) {
	debug_checks(gc)
	player_idx := gc.current_turn.index
	team_idx := gc.current_turn.team.index
	for unit in Transports_Needing_Staging {
		clear_needed := false
		defer if (clear_needed) {clear_move_history(gc)}
		for &src_sea in gc.seas {
			if (src_sea.active_sea_units[unit] == 0) {
				continue
			}
			clear_needed = true
			sa.resize(&gc.valid_moves, 1)
			dst_air_idx := src_sea.territory_index
			gc.valid_moves.data[0] = dst_air_idx
			add_valid_sea_moves(gc, &src_sea, 2)
			for src_sea.active_sea_units[unit] > 0 {
				if (gc.valid_moves.len > 1) {
					if (gc.answers_remaining == 0) {
						return true
					}
					dst_air_idx = get_user_sea_move_input(gc, unit, &src_sea)
				}
				dst_air := gc.territories[dst_air_idx]
				update_move_history(gc, &src_sea.territory, dst_air_idx)
				dst_sea_idx := dst_air_idx - len(gc.lands)
				sea_distance := src_sea.canal_paths[gc.canal_state].sea_distance[dst_sea_idx]
				dst_sea := gc.seas[dst_sea_idx]
				if (dst_sea.enemy_blockade_total > 0) {
					dst_air.combat_sActive_Sea_Unit
					sea_distance = TRANSPORT_MOVES_MAX
				}
				unit_after_move: Active_Sea_Unit
				switch (sea_distance) {
				case 0:
					src_sea.active_sea_units[Transports_After_Prestage_0_Moves[unit]] +=
						src_sea.active_sea_units[unit]
					src_sea.active_sea_units[unit] = 0
					break
				case 1:
					unit_after_move = Transports_After_Prestage_1_Move[unit]
				case 2:
					unit_after_move = Transports_After_Prestage_2_Moves[unit]
				case:
					fmt.eprintln("Error: Invalid sea_distance: %d\n", sea_distance)
					return false
				}
				dst_sea.active_sea_units[unit_after_move] += 1
				dst_sea.idle_sea_units[player_idx][Idle_Sea_From_Active[unit_after_move]] += 1
				dst_sea.teams_unit_count[team_idx] += 1
				src_sea.active_sea_units[unit] -= 1
				src_sea.idle_sea_units[player_idx][Idle_Sea_From_Active[unit]] -= 1
				src_sea.teams_unit_count[team_idx] -= 1
			}
		}
	}
	return true
}
