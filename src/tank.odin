package oaaa
import sa "core:container/small_array"

move_tanks_2 :: proc(gc: ^Game_Cache) -> (ok: bool) {
	debug_checks(gc)
	team := gc.current_turn.team
	enemy_team_idx := team.enemy_team.index
	clear_needed := false
	defer if clear_needed do clear_move_history(gc)
	for &src_land in gc.lands {
		if src_land.Active_Armys[Active_Army.TANKS_UNMOVED] == 0 do continue
		dst_air_idx := reset_valid_moves(gc, &src_sea, &clear_needed)
		add_valid_tank_2_moves(gc, &src_land)
		for src_land.Active_Armys[Active_Army.TANKS_UNMOVED] > 0 {
			if gc.valid_moves.len > 1 {
				if gc.answers_remaining == 0 do return true
				dst_air_idx = get_move_input(
					gc,
					Army_Names[Active_Army.TANKS_UNMOVED],
					&src_land.territory,
				)
			}
			update_move_history(gc, &src_land.territory, dst_air_idx)
			if (dst_air_idx >= LANDS_COUNT) {
				dst_sea := &gc.seas[dst_air_idx - LANDS_COUNT]
				load_large_transport(gc, .TANKS_UNMOVED, &src_land, dst_sea)
				// recalculate valid moves since transport cargo has changed
				sa.resize(&gc.valid_moves, 1)
				add_valid_tank_2_moves(gc, &src_land)
				continue
			}
			dst_land := gc.lands[dst_air_idx]
			landDistance := src_land.land_distances[dst_air_idx]
			if (dst_land.teams_unit_count[enemy_team_idx] > 0) { 	//combat ends turn
				dst_land.combat_status = Combat_Status.PRE_COMBAT
				landDistance = 2
			} else if (team.is_allied[dst_land.owner.index]) { 	//simple relocate ends turn
				landDistance = 2
			} else {
				if dst_land.factory_max_damage > 0 {
					landDistance = 2
				}
				conquer_land(gc, &dst_land)
			}
			switch (landDistance) {
			case 0:
				src_land.Active_Armys[Active_Army.TANKS_0_MOVES] +=
					src_land.Active_Armys[Active_Army.TANKS_UNMOVED]
				src_land.Active_Armys[Active_Army.TANKS_UNMOVED] = 0
				break
			case 1:
				move_army(
					&dst_land,
					.TANKS_1_MOVES,
					gc.current_turn,
					.TANKS_UNMOVED,
					&src_land,
				)
			case 2:
				move_army(
					&dst_land,
					.TANKS_0_MOVES,
					gc.current_turn,
					.TANKS_UNMOVED,
					&src_land,
				)
			}
		}
	}
	return true
}

move_tanks_1 :: proc(gc: ^Game_Cache) -> (ok: bool) {
	debug_checks(gc)
	team := gc.current_turn.team
	enemy_team_idx := team.enemy_team.index
	clear_needed := false
	defer if (clear_needed) {clear_move_history(gc)}
	for &src_land, src_land_idx in gc.lands {
		if (src_land.Active_Armys[Active_Army.TANKS_1_MOVES] == 0) do continue
		clear_needed = true
		sa.resize(&gc.valid_moves, 1)
		dst_air_idx := src_land.territory_index
		sa.set(&gc.valid_moves, 0, dst_air_idx)
		add_valid_large_land_moves(gc, &src_land)
		for src_land.Active_Armys[Active_Army.TANKS_1_MOVES] > 0 {
			if (gc.valid_moves.len > 1) {
				if (gc.answers_remaining == 0) do return true
				dst_air_idx = get_move_input(
					gc,
					Army_Names[Active_Army.TANKS_1_MOVES],
					&src_land.territory,
				)
			}
			update_move_history(gc, &src_land.territory, dst_air_idx)
			if (dst_air_idx >= LANDS_COUNT) {
				dst_sea := &gc.seas[dst_air_idx - LANDS_COUNT]
				load_large_transport(gc, .TANKS_1_MOVES, &src_land, dst_sea)
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
				src_land.Active_Armys[Active_Army.TANKS_0_MOVES] +=
					src_land.Active_Armys[Active_Army.TANKS_1_MOVES]
				src_land.Active_Armys[Active_Army.TANKS_1_MOVES] = 0
				break
			}
			move_army(
				&dst_land,
				.TANKS_0_MOVES,
				gc.current_turn,
				.TANKS_1_MOVES,
				&src_land,
			)
		}
	}
	return true
}

add_valid_tank_2_moves :: proc(gc: ^Game_Cache, src_land: ^Land) {
	// check for moving from land to land (two moves away)
	enemy_team_idx := gc.current_turn.team.enemy_team.index
	for dst_land in sa.slice(&src_land.lands_2_moves_away) {
		if (src_land.skipped_moves[dst_land.land.territory_index]) do continue
		sa.push(&gc.valid_moves, dst_land.land.territory_index)
	}
	// check for moving from land to sea (two moves away)
	for &dst_sea_2_away in sa.slice(&src_land.seas_2_moves_away) {
		Idle_Ships := dst_sea_2_away.sea.Idle_Ships[gc.current_turn.index]
		if (Idle_Ships[Idle_Ship.TRANS_EMPTY] == 0 &&
			   Idle_Ships[Idle_Ship.TRANS_1I] == 0) { 	// assume large, only tanks move 2
			continue
		}
		if (src_land.skipped_moves[dst_sea_2_away.sea.territory_index]) do continue
		for mid_land in sa.slice(&dst_sea_2_away.mid_lands) {
			if mid_land.teams_unit_count[enemy_team_idx] == 0 {
				sa.push(&gc.valid_moves, dst_sea_2_away.sea.territory_index)
				break
			}
		}
	}
	add_valid_large_land_moves(gc, src_land)
}
