package oaaa

Idle_Ship :: enum {
	TRANS_EMPTY,
	TRANS_1I,
	TRANS_1A,
	TRANS_1T,
	TRANS_2I,
	TRANS_1I_1A,
	TRANS_1I_1T,
	SUBMARINES,
	DESTROYERS,
	CARRIERS,
	CRUISERS,
	BATTLESHIPS,
	BS_DAMAGED,
}

Active_Ship :: enum {
	TRANS_EMPTY_UNMOVED,
	TRANS_EMPTY_2_MOVES,
	TRANS_EMPTY_1_MOVES,
	TRANS_EMPTY_0_MOVES,
	TRANS_1I_UNMOVED,
	TRANS_1I_2_MOVES,
	TRANS_1I_1_MOVES,
	TRANS_1I_0_MOVES,
	TRANS_1I_UNLOADED,
	TRANS_1A_UNMOVED,
	TRANS_1A_2_MOVES,
	TRANS_1A_1_MOVES,
	TRANS_1A_0_MOVES,
	TRANS_1A_UNLOADED,
	TRANS_1T_UNMOVED,
	TRANS_1T_2_MOVES,
	TRANS_1T_1_MOVES,
	TRANS_1T_0_MOVES,
	TRANS_1T_UNLOADED,
	TRANS_2I_2_MOVES,
	TRANS_2I_1_MOVES,
	TRANS_2I_0_MOVES,
	TRANS_2I_UNLOADED,
	TRANS_1I_1A_2_MOVES,
	TRANS_1I_1A_1_MOVES,
	TRANS_1I_1A_0_MOVES,
	TRANS_1I_1A_UNLOADED,
	TRANS_1I_1T_2_MOVES,
	TRANS_1I_1T_1_MOVES,
	TRANS_1I_1T_0_MOVES,
	TRANS_1I_1T_UNLOADED,
	SUBMARINES_UNMOVED,
	SUBMARINES_0_MOVES,
	DESTROYERS_UNMOVED,
	DESTROYERS_0_MOVES,
	CARRIERS_UNMOVED,
	CARRIERS_0_MOVES,
	CRUISERS_UNMOVED,
	CRUISERS_0_MOVES,
	CRUISERS_BOMBARDED,
	BATTLESHIPS_UNMOVED,
	BATTLESHIPS_0_MOVES,
	BATTLESHIPS_BOMBARDED,
	BS_DAMAGED_UNMOVED,
	BS_DAMAGED_0_MOVES,
	BS_DAMAGED_BOMBARDED,
}

Ship_Names := [?]string {
	Active_Ship.TRANS_EMPTY_UNMOVED   = "TRANS_EMPTY_UNMOVED",
	Active_Ship.TRANS_EMPTY_2_MOVES   = "TRANS_EMPTY_2_MOVES",
	Active_Ship.TRANS_EMPTY_1_MOVES   = "TRANS_EMPTY_1_MOVES",
	Active_Ship.TRANS_EMPTY_0_MOVES   = "TRANS_EMPTY_0_MOVES",
	Active_Ship.TRANS_1I_UNMOVED      = "TRANS_1I_UNMOVED",
	Active_Ship.TRANS_1I_2_MOVES      = "TRANS_1I_2_MOVES",
	Active_Ship.TRANS_1I_1_MOVES      = "TRANS_1I_1_MOVES",
	Active_Ship.TRANS_1I_0_MOVES      = "TRANS_1I_0_MOVES",
	Active_Ship.TRANS_1I_UNLOADED     = "TRANS_1I_UNLOADED",
	Active_Ship.TRANS_1A_UNMOVED      = "TRANS_1A_UNMOVED",
	Active_Ship.TRANS_1A_2_MOVES      = "TRANS_1A_2_MOVES",
	Active_Ship.TRANS_1A_1_MOVES      = "TRANS_1A_1_MOVES",
	Active_Ship.TRANS_1A_0_MOVES      = "TRANS_1A_0_MOVES",
	Active_Ship.TRANS_1A_UNLOADED     = "TRANS_1A_UNLOADED",
	Active_Ship.TRANS_1T_UNMOVED      = "TRANS_1T_UNMOVED",
	Active_Ship.TRANS_1T_2_MOVES      = "TRANS_1T_2_MOVES",
	Active_Ship.TRANS_1T_1_MOVES      = "TRANS_1T_1_MOVES",
	Active_Ship.TRANS_1T_0_MOVES      = "TRANS_1T_0_MOVES",
	Active_Ship.TRANS_1T_UNLOADED     = "TRANS_1T_UNLOADED",
	Active_Ship.TRANS_2I_2_MOVES      = "TRANS_2I_2_MOVES",
	Active_Ship.TRANS_2I_1_MOVES      = "TRANS_2I_1_MOVES",
	Active_Ship.TRANS_2I_0_MOVES      = "TRANS_2I_0_MOVES",
	Active_Ship.TRANS_2I_UNLOADED     = "TRANS_2I_UNLOADED",
	Active_Ship.TRANS_1I_1A_2_MOVES   = "TRANS_1I_1A_2_MOVES",
	Active_Ship.TRANS_1I_1A_1_MOVES   = "TRANS_1I_1A_1_MOVES",
	Active_Ship.TRANS_1I_1A_0_MOVES   = "TRANS_1I_1A_0_MOVES",
	Active_Ship.TRANS_1I_1A_UNLOADED  = "TRANS_1I_1A_UNLOADED",
	Active_Ship.TRANS_1I_1T_2_MOVES   = "TRANS_1I_1T_2_MOVES",
	Active_Ship.TRANS_1I_1T_1_MOVES   = "TRANS_1I_1T_1_MOVES",
	Active_Ship.TRANS_1I_1T_0_MOVES   = "TRANS_1I_1T_0_MOVES",
	Active_Ship.TRANS_1I_1T_UNLOADED  = "TRANS_1I_1T_UNLOADED",
	Active_Ship.SUBMARINES_UNMOVED    = "SUBMARINES_UNMOVED",
	Active_Ship.SUBMARINES_0_MOVES    = "SUBMARINES_0_MOVES",
	Active_Ship.DESTROYERS_UNMOVED    = "DESTROYERS_UNMOVED",
	Active_Ship.DESTROYERS_0_MOVES    = "DESTROYERS_0_MOVES",
	Active_Ship.CARRIERS_UNMOVED      = "CARRIERS_UNMOVED",
	Active_Ship.CARRIERS_0_MOVES      = "CARRIERS_0_MOVES",
	Active_Ship.CRUISERS_UNMOVED      = "CRUISERS_UNMOVED",
	Active_Ship.CRUISERS_0_MOVES      = "CRUISERS_0_MOVES",
	Active_Ship.CRUISERS_BOMBARDED    = "CRUISERS_BOMBARDED",
	Active_Ship.BATTLESHIPS_UNMOVED   = "BATTLESHIPS_UNMOVED",
	Active_Ship.BATTLESHIPS_0_MOVES   = "BATTLESHIPS_0_MOVES",
	Active_Ship.BATTLESHIPS_BOMBARDED = "BATTLESHIPS_BOMBARDED",
	Active_Ship.BS_DAMAGED_UNMOVED    = "BS_DAMAGED_UNMOVED",
	Active_Ship.BS_DAMAGED_0_MOVES    = "BS_DAMAGED_0_MOVES",
	Active_Ship.BS_DAMAGED_BOMBARDED  = "BS_DAMAGED_BOMBARDED",
}

Ships_With_2_MOVES := [?]Active_Ship {
	.TRANS_1I_2_MOVES,
	.TRANS_1A_2_MOVES,
	.TRANS_1T_2_MOVES,
	.TRANS_2I_2_MOVES,
	.TRANS_1I_1A_2_MOVES,
	.TRANS_1I_1T_2_MOVES,
	//	.SUBMARINES_UNMOVED,
	.DESTROYERS_UNMOVED,
	//	.CARRIERS_UNMOVED,
	.CRUISERS_UNMOVED,
	.BATTLESHIPS_UNMOVED,
	.BS_DAMAGED_UNMOVED,
}

Active_Ship_To_Idle := [?]Idle_Ship {
	Active_Ship.TRANS_EMPTY_UNMOVED = .TRANS_EMPTY,
	Active_Ship.TRANS_1I_UNMOVED    = .TRANS_1I,
	Active_Ship.TRANS_1A_UNMOVED    = .TRANS_1A,
	Active_Ship.TRANS_1T_UNMOVED    = .TRANS_1T,
}

Unmoved_Blockade_Ships := [?]Active_Ship {
	Active_Ship.DESTROYERS_UNMOVED,
	Active_Ship.CRUISERS_UNMOVED,
	Active_Ship.BATTLESHIPS_UNMOVED,
	Active_Ship.BS_DAMAGED_UNMOVED,
}

Ships_Moved := [?]Active_Ship {
	Active_Ship.DESTROYERS_UNMOVED  = .DESTROYERS_0_MOVES,
	Active_Ship.CRUISERS_UNMOVED    = .CRUISERS_0_MOVES,
	Active_Ship.BATTLESHIPS_UNMOVED = .BATTLESHIPS_0_MOVES,
	Active_Ship.BS_DAMAGED_UNMOVED  = .BS_DAMAGED_0_MOVES,
}

move_dest_crus_bs :: proc(gc: ^Game_Cache) -> (ok: bool) {
	debug_checks(gc)
	for ship in Unmoved_Blockade_Ships {
		clear_needed := false
		defer if clear_needed do clear_move_history(gc)
		for src_sea in gc.seas {
			if src_sea.Active_Ships[ship] == 0 do continue
			dst_air_idx := reset_valid_moves(gc, &src_air, &clear_needed)
			add_valid_ship_moves(gc, src_sea)
			for src_sea.Active_Ships[ship] > 0 {
				get_move_input(gc, Ship_Names[ship], &src_air, &dst_air_idx) or_return
				sea_dist := src_sea.canal_paths[gc.canal_state].sea_distance[dst_sea_idx]
				dst_sea := gc.seas[dst_sea_idx]
				if !dst_sea.teams_unit_count[gc.current_turn.team.index] > 0 {
					dst_sea.combat_status = .PRE_COMBAT
				}
				move_ship(dst_sea, Ships_Moved[ship], gc.current_turn, ship, src_sea)
			}
		}
	}
	return true
}

add_valid_ship_moves :: proc(gc: ^Game_Cache, src_sea: ^Sea, max_distance: int) {
	for dst_sea in sa.slice(&src_sea.canal_paths[gc.canal_state].adjacent_seas) {
		if (src_sea.skipped_moves[dst_sea.territory_index]) {
			continue
		}
		sa.push(&gc.valid_moves, dst_sea.territory_index)
	}
	if max_distance == 1 do return
	for &dst_sea_2_away in sa.slice(&src_sea.canal_paths[gc.canal_state].seas_2_moves_away) {
		if (src_sea.skipped_moves[dst_sea_2_away.sea.territory_index]) {
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
