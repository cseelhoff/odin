package oaaa
import sa "core:container/small_array"
import "core:fmt"
import "core:mem"
import "core:slice"

MAX_TRANSPORT_MOVES :: 2

Transports_With_Moves := [?]Active_Ship {
	.TRANS_1I_1_MOVES,
	.TRANS_1A_1_MOVES,
	.TRANS_1T_1_MOVES,
	.TRANS_2I_1_MOVES,
	.TRANS_1I_1A_1_MOVES,
	.TRANS_1I_1T_1_MOVES,
	.TRANS_1I_2_MOVES,
	.TRANS_1A_2_MOVES,
	.TRANS_1T_2_MOVES,
	.TRANS_2I_2_MOVES,
	.TRANS_1I_1A_2_MOVES,
	.TRANS_1I_1T_2_MOVES,
}

Transports_Needing_Staging := [?]Active_Ship {
	.TRANS_EMPTY_UNMOVED,
	.TRANS_1I_UNMOVED,
	.TRANS_1A_UNMOVED,
	.TRANS_1T_UNMOVED,
}

Ship_After_Staged := [?][MAX_TRANSPORT_MOVES + 1]Active_Ship {
	Active_Ship.TRANS_EMPTY_UNMOVED = {
		0 = .TRANS_EMPTY_2_MOVES,
		1 = .TRANS_EMPTY_1_MOVES,
		2 = .TRANS_EMPTY_0_MOVES,
	},
	Active_Ship.TRANS_1I_UNMOVED = {
		0 = .TRANS_1I_2_MOVES,
		1 = .TRANS_1I_1_MOVES,
		2 = .TRANS_1I_0_MOVES,
	},
	Active_Ship.TRANS_1A_UNMOVED = {
		0 = .TRANS_1A_2_MOVES,
		1 = .TRANS_1A_1_MOVES,
		2 = .TRANS_1A_0_MOVES,
	},
	Active_Ship.TRANS_1T_UNMOVED = {
		0 = .TRANS_1T_2_MOVES,
		1 = .TRANS_1T_1_MOVES,
		2 = .TRANS_1T_0_MOVES,
	},
}

// Ship_Large_Space := [?]bool {
// 	Active_Ship.TRANS_EMPTY_UNMOVED = true,
// 	Active_Ship.TRANS_1I_UNMOVED    = true,
// 	Active_Ship.TRANS_1A_UNMOVED    = false,
// 	Active_Ship.TRANS_1T_UNMOVED    = false,
// }

Transport_Load_Unit := [len(Idle_Army)][len(Active_Ship)]Active_Ship {
	Idle_Army.INF = {
		Active_Ship.TRANS_1T_2_MOVES = .TRANS_1I_1T_2_MOVES,
		Active_Ship.TRANS_1A_2_MOVES = .TRANS_1I_1A_2_MOVES,
		Active_Ship.TRANS_1I_2_MOVES = .TRANS_2I_2_MOVES,
		Active_Ship.TRANS_EMPTY_2_MOVES = .TRANS_1I_2_MOVES,
		Active_Ship.TRANS_1T_1_MOVES = .TRANS_1I_1T_1_MOVES,
		Active_Ship.TRANS_1A_1_MOVES = .TRANS_1I_1A_1_MOVES,
		Active_Ship.TRANS_1I_1_MOVES = .TRANS_2I_1_MOVES,
		Active_Ship.TRANS_EMPTY_1_MOVES = .TRANS_1I_1_MOVES,
		Active_Ship.TRANS_1T_0_MOVES = .TRANS_1I_1T_0_MOVES,
		Active_Ship.TRANS_1A_0_MOVES = .TRANS_1I_1A_0_MOVES,
		Active_Ship.TRANS_1I_0_MOVES = .TRANS_2I_0_MOVES,
		Active_Ship.TRANS_EMPTY_0_MOVES = .TRANS_1I_0_MOVES,
	},
	Idle_Army.ARTY = {
		Active_Ship.TRANS_1I_2_MOVES = .TRANS_1I_1A_2_MOVES,
		Active_Ship.TRANS_EMPTY_2_MOVES = .TRANS_1A_2_MOVES,
		Active_Ship.TRANS_1I_1_MOVES = .TRANS_1I_1A_1_MOVES,
		Active_Ship.TRANS_EMPTY_1_MOVES = .TRANS_1A_1_MOVES,
		Active_Ship.TRANS_1I_0_MOVES = .TRANS_1I_1A_0_MOVES,
		Active_Ship.TRANS_EMPTY_0_MOVES = .TRANS_1A_0_MOVES,
	},
	Idle_Army.TANK = {
		Active_Ship.TRANS_1I_2_MOVES = .TRANS_1I_1T_2_MOVES,
		Active_Ship.TRANS_EMPTY_2_MOVES = .TRANS_1T_2_MOVES,
		Active_Ship.TRANS_1I_1_MOVES = .TRANS_1I_1T_1_MOVES,
		Active_Ship.TRANS_EMPTY_1_MOVES = .TRANS_1T_1_MOVES,
		Active_Ship.TRANS_1I_0_MOVES = .TRANS_1I_1T_0_MOVES,
		Active_Ship.TRANS_EMPTY_0_MOVES = .TRANS_1T_0_MOVES,
	},
}

Transport_Can_Load_Large := [?]Active_Ship {
	Active_Ship.TRANS_1I_2_MOVES,
	Active_Ship.TRANS_EMPTY_2_MOVES,
	Active_Ship.TRANS_1I_1_MOVES,
	Active_Ship.TRANS_EMPTY_1_MOVES,
	Active_Ship.TRANS_1I_0_MOVES,
	Active_Ship.TRANS_EMPTY_0_MOVES,
}

Transport_Can_Load_Small := [?]Active_Ship {
	Active_Ship.TRANS_1T_2_MOVES,
	Active_Ship.TRANS_1A_2_MOVES,
	Active_Ship.TRANS_1T_1_MOVES,
	Active_Ship.TRANS_1A_1_MOVES,
	Active_Ship.TRANS_1T_0_MOVES,
	Active_Ship.TRANS_1A_0_MOVES,
}

stage_transport_units :: proc(gc: ^Game_Cache) -> (ok: bool) {
	debug_checks(gc)
	for ship in Transports_Needing_Staging {
		ship_after := Ship_After_Staged[ship]
		gc.clear_needed = false
		for &src_sea in gc.seas {
			if src_sea.active_ships[ship] == 0 do continue
			dst_air_idx := reset_valid_moves(gc, &src_sea)
			add_valid_transport_moves(gc, &src_sea, 2)
			for src_sea.active_ships[ship] > 0 {
				dst_air_idx = get_move_input(gc, Ship_Names[ship], &src_sea) or_return
				dst_sea_idx := dst_air_idx - len(LANDS_DATA)
				sea_distance := src_sea.canal_paths[gc.canal_state].sea_distance[dst_sea_idx]
				dst_sea := &gc.seas[dst_sea_idx]
				if dst_sea.combat_status == .PRE_COMBAT {
					// only allow staging to sea with enemy blockade if other unit started combat
					sea_distance = 2
				}
				ship_after_staged := ship_after[sea_distance]
				if sea_distance == 0 {
					src_sea.active_ships[ship_after_staged] += src_sea.active_ships[ship]
					src_sea.active_ships[ship] = 0
					break
				}
				move_ship(dst_sea, ship_after_staged, gc.cur_player, ship, &src_sea)
			}
		}
		if gc.clear_needed do clear_move_history(gc)
	}
	return true
}

skip_empty_transports :: proc(gc: ^Game_Cache) {
	for &src_sea in gc.seas {
		src_sea.active_ships[Active_Ship.TRANS_EMPTY_0_MOVES] +=
			src_sea.active_ships[Active_Ship.TRANS_EMPTY_1_MOVES] +
			src_sea.active_ships[Active_Ship.TRANS_EMPTY_2_MOVES]
		src_sea.active_ships[Active_Ship.TRANS_EMPTY_1_MOVES] = 0
		src_sea.active_ships[Active_Ship.TRANS_EMPTY_2_MOVES] = 0
	}
}

move_transports :: proc(gc: ^Game_Cache) -> (ok: bool) {
	debug_checks(gc)
	skip_empty_transports(gc)
	for ship in Transports_With_Moves {
		gc.clear_needed = false
		for &src_sea in gc.seas {
			if src_sea.active_ships[ship] == 0 do continue
			dst_air_idx := reset_valid_moves(gc, &src_sea)
			add_valid_transport_moves(gc, &src_sea, Ships_Moves[ship])
			for src_sea.active_ships[ship] > 0 {
				dst_air_idx = get_move_input(gc, Ship_Names[ship], &src_sea) or_return
				dst_sea_idx := dst_air_idx - len(LANDS_DATA)
				dst_sea := &gc.seas[dst_sea_idx]
				if &src_sea == dst_sea {
					src_sea.active_ships[Ships_Moved[ship]] += src_sea.active_ships[ship]
					src_sea.active_ships[ship] = 0
					break
				}
				move_ship(dst_sea, Ships_Moved[ship], gc.cur_player, ship, &src_sea)
			}
		}
		if gc.clear_needed do clear_move_history(gc)
	}
	return true
}

add_valid_transport_moves :: proc(gc: ^Game_Cache, src_sea: ^Sea, max_distance: int) {
	for dst_sea in sa.slice(&src_sea.canal_paths[gc.canal_state].adjacent_seas) {
		if src_sea.skipped_moves[dst_sea.territory_index] ||
		   dst_sea.team_units[gc.cur_player.team.enemy_team.index] > 0 &&
			   dst_sea.combat_status != .PRE_COMBAT {
			continue
		}
		sa.push(&gc.valid_moves, dst_sea.territory_index)
	}
	if max_distance == 1 do return
	for &dst_sea_2_away in sa.slice(&src_sea.canal_paths[gc.canal_state].seas_2_moves_away) {
		if (src_sea.skipped_moves[dst_sea_2_away.sea.territory_index] ||
			   dst_sea_2_away.sea.team_units[gc.cur_player.team.enemy_team.index] > 0 &&
				   dst_sea_2_away.sea.combat_status != .PRE_COMBAT) {
			continue
		}
		for mid_sea in sa.slice(&dst_sea_2_away.mid_seas) {
			if (!mid_sea.sea_path_blocked) {
				sa.push(&gc.valid_moves, dst_sea_2_away.sea.territory_index)
				break
			}
		}
	}
}

unload_transports :: proc(gc: ^Game_Cache) -> (ok: bool) {
	return false
}
