package oaaa
import sa "core:container/small_array"
import "core:fmt"
import "core:mem"
import "core:slice"

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

Ship_Stage_0 := [?]Active_Ship {
	Active_Ship.TRANS_EMPTY_UNMOVED = .TRANS_EMPTY_2_MOVES,
	Active_Ship.TRANS_1I_UNMOVED    = .TRANS_1I_2_MOVES,
	Active_Ship.TRANS_1A_UNMOVED    = .TRANS_1A_2_MOVES,
	Active_Ship.TRANS_1T_UNMOVED    = .TRANS_1T_2_MOVES,
}

Ship_Stage_1 := [?]Active_Ship {
	Active_Ship.TRANS_EMPTY_UNMOVED = .TRANS_EMPTY_1_MOVES,
	Active_Ship.TRANS_1I_UNMOVED    = .TRANS_1I_1_MOVES,
	Active_Ship.TRANS_1A_UNMOVED    = .TRANS_1A_1_MOVES,
	Active_Ship.TRANS_1T_UNMOVED    = .TRANS_1T_1_MOVES,
}

Ship_Stage_2 := [?]Active_Ship {
	Active_Ship.TRANS_EMPTY_UNMOVED = .TRANS_EMPTY_0_MOVES,
	Active_Ship.TRANS_1I_UNMOVED    = .TRANS_1I_0_MOVES,
	Active_Ship.TRANS_1A_UNMOVED    = .TRANS_1A_0_MOVES,
	Active_Ship.TRANS_1T_UNMOVED    = .TRANS_1T_0_MOVES,
}

// Ship_Large_Space := [?]bool {
// 	Active_Ship.TRANS_EMPTY_UNMOVED = true,
// 	Active_Ship.TRANS_1I_UNMOVED    = true,
// 	Active_Ship.TRANS_1A_UNMOVED    = false,
// 	Active_Ship.TRANS_1T_UNMOVED    = false,
// }

Transport_Load_Unit := [len(Idle_Army)][len(Active_Ship)]Active_Ship {
	Idle_Army.INFANTRY = {
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
	Idle_Army.ARTILLERY = {
		Active_Ship.TRANS_1I_2_MOVES = .TRANS_1I_1A_2_MOVES,
		Active_Ship.TRANS_EMPTY_2_MOVES = .TRANS_1A_2_MOVES,
		Active_Ship.TRANS_1I_1_MOVES = .TRANS_1I_1A_1_MOVES,
		Active_Ship.TRANS_EMPTY_1_MOVES = .TRANS_1A_1_MOVES,
		Active_Ship.TRANS_1I_0_MOVES = .TRANS_1I_1A_0_MOVES,
		Active_Ship.TRANS_EMPTY_0_MOVES = .TRANS_1A_0_MOVES,
	},
	Idle_Army.TANKS = {
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
	Active_Ship.TRANS_1I_2_MOVES,
	Active_Ship.TRANS_EMPTY_2_MOVES,
	Active_Ship.TRANS_1T_1_MOVES,
	Active_Ship.TRANS_1A_1_MOVES,
	Active_Ship.TRANS_1I_1_MOVES,
	Active_Ship.TRANS_EMPTY_1_MOVES,
	Active_Ship.TRANS_1T_0_MOVES,
	Active_Ship.TRANS_1A_0_MOVES,
	Active_Ship.TRANS_1I_0_MOVES,
	Active_Ship.TRANS_EMPTY_0_MOVES,
}

stage_transport_units :: proc(gc: ^Game_Cache) -> (ok: bool) {
	debug_checks(gc)
	for ship in Transports_Needing_Staging {
		clear_needed := false
		defer if clear_needed do clear_move_history(gc)
		for &src_sea in gc.seas {
			if src_sea.Active_Ships[ship] == 0 do continue
			dst_air_idx := reset_valid_moves(gc, &src_air, &clear_needed)
			add_valid_transport_moves(gc, &src_sea, 2)
			for src_sea.Active_Ships[ship] > 0 {
				get_move_input(gc, Ship_Names[ship], &src_air, &dst_air_idx) or_return
				dst_sea_idx := dst_air_idx - len(LANDS_DATA)
				sea_distance := src_sea.canal_paths[gc.canal_state].sea_distance[dst_sea_idx]
				dst_sea := gc.seas[dst_sea_idx]
				if dst_sea.combat_status == .PRE_COMBAT {
					// only allow staging to sea with enemy blockade if other unit started combat
					sea_distance = 2
				}
				ship_after_move: Active_Ship
				switch sea_distance {
				case 0:
					src_sea.Active_Ships[Ship_Stage_0[ship]] += src_sea.Active_Ships[ship]
					src_sea.Active_Ships[ship] = 0
					break
				case 1:
					ship_after_move = Ship_Stage_1[ship]
				case 2:
					ship_after_move = Ship_Stage_2[ship]
				case:
					fmt.eprintln("Error: Invalid sea_distance: %d\n", sea_distance)
					return false
				}
				move_ship(dst_sea, ship_after_move, gc.current_turn, ship, src_sea)
			}
		}
	}
	return true
}

load_unit :: proc(
	src_land: ^Land,
	dst_sea: ^Sea,
	active_transport: Active_Ship,
	player_idx: int,
	active_army: active_army,
) {
	Idle_Army := Active_Army_To_Idle[active_army]
	new_active_transport := Transport_Load_Unit[Idle_Army][active_transport]
	dst_sea.Active_Ships[new_active_transport] += 1
	dst_sea.Idle_Ships[player_idx][Active_Ship_To_Idle[new_active_transport]] += 1
	src_land.Active_Armies[active_army] -= 1
	src_land.Idle_Armys[player_idx][Idle_Army] -= 1
}

load_large_transport :: proc(
	gc: ^Game_Cache,
	active_army: active_army,
	src_land: ^Land,
	dst_sea: ^Sea,
) {
	for transport in Transport_Can_Load_Large {
		if dst_sea.Active_Ships[transport] > 0 {
			load_unit(src_land, dst_sea, transport, gc.current_turn.index, active_army)
			return
		}
	}
}

load_small_transport :: proc(
	gc: ^Game_Cache,
	active_army: active_army,
	src_land: ^Land,
	dst_sea: ^Sea,
) {
	for transport in Transport_Can_Load_Small {
		if dst_sea.Active_Ships[transport] > 0 {
			load_unit(src_land, dst_sea, transport, gc.current_turn.index, active_army)
			return
		}
	}
}

skip_empty_transports :: proc(gc: ^Game_Cache) {
	for &src_sea in gc.seas {
		src_sea.Active_Ships[.TRANS_EMPTY_0_MOVES] +=
			src_sea.Active_Ships[.TRANS_EMPTY_1_MOVES] + src_sea.active[.TRANS_EMPTY_2_MOVES]
		src_sea.Active_Ships[.TRANS_EMPTY_1_MOVES] = 0
		src_sea.Active_Ships[.TRANS_EMPTY_2_MOVES] = 0
	}
}

move_transports :: proc(gc: ^Game_Cache) -> (ok: bool) {
	debug_checks(gc)
	for ship in Transports_With_Moves {
		clear_needed := false
		defer if clear_needed do clear_move_history(gc)
		for &src_sea in gc.seas {
			if src_sea.Active_Ships[ship] == 0 do continue
			dst_air_idx := reset_valid_moves(gc, &src_sea, &clear_needed)
			add_valid_transport_moves(gc, &src_sea, Ships_Moves[ship])
			for src_sea.Active_Ships[ship] > 0 {
				get_move_input(gc, Ship_Names[ship], &src_sea, &dst_air_idx) or_return
				dst_sea_idx := dst_air_idx - len(LANDS_DATA)
				dst_sea := &gc.seas[dst_sea_idx]
				if src_sea == dst_sea {
					src_sea.Active_Ships[Ships_Moved[ship]] += src_sea.Active_Ships[ship]
					src_sea.Active_Ships[ship] = 0
					break
				}
				move_ship(dst_sea, Ships_Moved[ship], gc.current_turn, ship, src_sea)
			}
		}
	}
	return true
}

add_valid_transport_moves :: proc(gc: ^Game_Cache, src_sea: ^Sea, max_distance: int) {
	for dst_sea in sa.slice(&src_sea.canal_paths[gc.canal_state].adjacent_seas) {
		if src_sea.skipped_moves[dst_sea.territory_index] ||
		   dst_sea.teams_unit_count[gc.current_turn.team.enemy_team.index] > 0 &&
			   dst_sea.combat_status != .PRE_COMBAT {
			continue
		}
		sa.push(&gc.valid_moves, dst_sea.territory_index)
	}
	if max_distance == 1 do return
	for &dst_sea_2_away in sa.slice(&src_sea.canal_paths[gc.canal_state].seas_2_moves_away) {
		if (src_sea.skipped_moves[dst_sea_2_away.sea.territory_index] ||
			   dst_sea.teams_unit_count[gc.current_turn.team.enemy_team.index] > 0 &&
				   dst_sea.combat_status != .PRE_COMBAT) {
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

unload_transports :: proc(gc: ^Game_Cache) -> (ok: bool) {}
