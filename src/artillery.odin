package oaaa
import sa "core:container/small_array"

move_artillery :: proc(gc: ^Game_Cache) -> (ok: bool) {
	debug_checks(gc)
	team := gc.current_turn.team
	enemy_team_idx := team.enemy_team.index
	clear_needed := false
	defer if (clear_needed) {clear_move_history(gc)}
	for &src_land, src_land_idx in gc.lands {
		if (src_land.Active_Armies[Active_Army.ARTILLERY_UNMOVED] == 0) do continue
		clear_needed = true
		sa.resize(&gc.valid_moves, 1)
		dst_air_idx := src_land.territory_index
		sa.set(&gc.valid_moves, 0, dst_air_idx)
		add_valid_large_land_moves(gc, &src_land)
		for src_land.Active_Armies[Active_Army.ARTILLERY_UNMOVED] > 0 {
			if (gc.valid_moves.len > 1) {
				if (gc.answers_remaining == 0) do return true
				dst_air_idx = get_move_input(
					gc,
					Army_Names[Active_Army.ARTILLERY_UNMOVED],
					&src_land.territory,
				)
			}
			update_move_history(gc, &src_land.territory, dst_air_idx)
			if (dst_air_idx >= len(LANDS_DATA)) {
				dst_sea := &gc.seas[dst_air_idx - len(LANDS_DATA)]
				load_large_transport(gc, .ARTILLERY_UNMOVED, &src_land, dst_sea)
				// recalculate valid moves since transport cargo has changed
				sa.resize(&gc.valid_moves, 1)
				add_valid_large_land_moves(gc, &src_land)
				continue
			}
			dst_land := gc.lands[dst_air_idx]
			landDistance := src_land.land_distances[dst_air_idx]
			if dst_land.teams_unit_count[enemy_team_idx] > 0 { 	//combat ends turn
				dst_land.combat_status = Combat_Status.PRE_COMBAT
			} else if (!team.is_allied[dst_land.owner.index]) { 	//simple relocate ends turn
				conquer_land(gc, &dst_land)
			}
			if landDistance == 0 {
				src_land.Active_Armies[Active_Army.ARTILLERY_0_MOVES] +=
					src_land.Active_Armies[Active_Army.ARTILLERY_UNMOVED]
				src_land.Active_Armies[Active_Army.ARTILLERY_UNMOVED] = 0
				break
			}
			move_army(
				&dst_land,
				.ARTILLERY_0_MOVES,
				gc.current_turn,
				.ARTILLERY_UNMOVED,
				&src_land,
			)
		}
	}
	return true
}
