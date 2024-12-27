package oaaa

SUB_UNMOVED_NAME :: "SUB_UNMOVED"

move_subs :: proc(gc: ^Game_Cache) {
	debug_checks(gc)
	clear_needed := false
	defer if clear_needed do clear_move_history(gc)
	for src_sea in gc.seas {
		if src_sea.Active_Ships[Active_Ship.SUB_UNMOVED] == 0 do continue
		dst_air_idx := reset_valid_moves(gc, &src_air, &clear_needed)
		add_valid_sub_moves(gc, src_sea)
		for src_sea.Active_Ships[Active_Ship.SUB_UNMOVED] > 0 {
			get_move_input(gc, SUB_UNMOVED_NAME, &src_air, &dst_air_idx) or_return
			dst_sea := gc.seas[dst_sea_idx]
			if !dst_sea.teams_unit_count[gc.current_turn.team.index] > 0 {
				dst_sea.combat_status = .PRE_COMBAT
			}
			if src_sea == dst_sea {
				src_sea.Active_Ships[Active_Ship.SUB_0_MOVES] +=
					src_sea.Active_Ships[Active_Ship.SUB_UNMOVED]
				src_sea.Active_Ships[Active_Ship.SUB_UNMOVED] = 0
				break
			}
			move_ship(
				dst_sea,
				Active_Ship.SUB_0_MOVES,
				gc.current_turn,
				Active_Ship.SUB_UNMOVED,
				src_sea,
			)
		}
	}
	return true
}

add_valid_sub_moves :: proc(gc: ^Game_Cache, src_sea: ^Sea) {
	for dst_sea in sa.slice(&src_sea.canal_paths[gc.canal_state].adjacent_seas) {
		if (src_sea.skipped_moves[dst_sea.territory_index]) {
			continue
		}
		sa.push(&gc.valid_moves, dst_sea.territory_index)
	}
	for &dst_sea_2_away in sa.slice(&src_sea.canal_paths[gc.canal_state].seas_2_moves_away) {
		if (src_sea.skipped_moves[dst_sea_2_away.sea.territory_index]) {
			continue
		}
		for mid_sea in sa.slice(&dst_sea_2_away.mid_seas) {
			if (mid_sea.enemy_destroyers_total == 0) {
				sa.push(&gc.valid_moves, dst_sea_2_away.sea.territory_index)
				break
			}
		}
	}
}
