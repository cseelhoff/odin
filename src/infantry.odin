package oaaa
import sa "core:container/small_array"

move_infantry :: proc(gc: ^Game_Cache) -> (ok: bool) {
	debug_checks(gc)
	team := gc.current_turn.team
	enemy_team_idx := team.enemy_team.index
	clear_needed := false
	defer if (clear_needed) {clear_move_history(gc)}
	for &src_land, src_land_idx in gc.lands {
		if (src_land.active_land_units[Active_Land_Unit.INFANTRY_UNMOVED] == 0) do continue
		clear_needed = true
		sa.resize(&gc.valid_moves, 1)
		dst_air_idx := src_land.territory_index
		sa.set(&gc.valid_moves, 0, dst_air_idx)
		add_valid_infantry_moves(gc, &src_land)
		for src_land.active_land_units[Active_Land_Unit.INFANTRY_UNMOVED] > 0 {
			if (gc.valid_moves.len > 1) {
				if (gc.answers_remaining == 0) do return true
				dst_air_idx = get_move_input(
					gc,
					Land_Unit_Names[Active_Land_Unit.INFANTRY_UNMOVED],
					&src_land.territory,
				)
			}
			update_move_history(gc, &src_land.territory, dst_air_idx)
			if (dst_air_idx >= LANDS_COUNT) {
				dst_sea := &gc.seas[dst_air_idx - LANDS_COUNT]
				load_small_transport(gc, .INFANTRY_UNMOVED, &src_land, dst_sea)
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
				src_land.active_land_units[Active_Land_Unit.INFANTRY_0_MOVES_LEFT] +=
					src_land.active_land_units[Active_Land_Unit.INFANTRY_UNMOVED]
				src_land.active_land_units[Active_Land_Unit.INFANTRY_UNMOVED] = 0
				break
			}
			move_land_unit(
				&dst_land,
				.INFANTRY_0_MOVES_LEFT,
				gc.current_turn,
				.INFANTRY_UNMOVED,
				&src_land,
			)
		}
	}
	return true
}

add_valid_infantry_moves :: proc(gc: ^Game_Cache, src_land: ^Land) {
	for dst_land in sa.slice(&src_land.adjacent_lands) {
		if (src_land.skipped_moves[dst_land.territory_index]) do continue
		sa.push(&gc.valid_moves, dst_land.territory_index)
	}
	// check for moving from land to sea (one move away)
	for dst_sea in sa.slice(&src_land.adjacent_seas) {
		idle_sea_units := dst_sea.idle_sea_units[gc.current_turn.index]
		if (idle_sea_units[Idle_Sea_Unit.TRANS_EMPTY] == 0 &&
			   idle_sea_units[Idle_Sea_Unit.TRANS_1I] == 0 &&
			   idle_sea_units[Idle_Sea_Unit.TRANS_1A] == 0 &&
			   idle_sea_units[Idle_Sea_Unit.TRANS_1T] == 0) { 	// small
			continue
		}
		if (!src_land.skipped_moves[dst_sea.territory_index]) {
			sa.push(&gc.valid_moves, dst_sea.territory_index)
		}
	}
}
