package oaaa

import sa "core:container/small_array"

SUB_UNMOVED_NAME :: "SUB_UNMOVED"
SUB_ATTACK :: 2
SUB_DEFENSE :: 1

move_subs :: proc(gc: ^Game_Cache) -> (ok: bool) {
	debug_checks(gc)
	gc.clear_needed = false
	for &src_sea in gc.seas {
		if src_sea.active_ships[Active_Ship.SUB_UNMOVED] == 0 do continue
		dst_air_idx := reset_valid_moves(gc, &src_sea)
		add_valid_sub_moves(gc, &src_sea)
		for src_sea.active_ships[Active_Ship.SUB_UNMOVED] > 0 {
			dst_air_idx = get_move_input(gc, SUB_UNMOVED_NAME, &src_sea) or_return
			check_for_enemy(gc, dst_air_idx)
			dst_sea := gc.seas[dst_air_idx - len(LANDS_DATA)]
			skip_ship(&src_sea, &dst_sea, Active_Ship.SUB_UNMOVED) or_break
			move_ship(
				&dst_sea,
				Active_Ship.SUB_0_MOVES,
				gc.cur_player,
				Active_Ship.SUB_UNMOVED,
				&src_sea,
			)
		}
	}
	if gc.clear_needed do clear_move_history(gc)
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
			if (mid_sea.enemy_destroyer_total == 0) {
				sa.push(&gc.valid_moves, dst_sea_2_away.sea.territory_index)
				break
			}
		}
	}
}
