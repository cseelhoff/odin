package oaaa
import sa "core:container/small_array"

TANK_UNMOVED_NAME :: "TANK_UNMOVED"
TANK_1_MOVES_NAME :: "TANK_1_MOVES"

move_tanks_2 :: proc(gc: ^Game_Cache) -> (ok: bool) {
	debug_checks(gc)
	team := gc.cur_player.team
	enemy_team_idx := team.enemy_team.index
	gc.clear_needed = false
	for &src_land in gc.lands {
		if src_land.active_armies[Active_Army.TANK_UNMOVED] == 0 do continue
		dst_air_idx := reset_valid_moves(gc, &src_land)
		add_valid_tank_2_moves(gc, &src_land)
		for src_land.active_armies[Active_Army.TANK_UNMOVED] > 0 {
			dst_air_idx = get_move_input(gc, TANK_UNMOVED_NAME, &src_land) or_return
			if (dst_air_idx >= len(LANDS_DATA)) {				
				load_large_transport(gc, .TANK_UNMOVED, &src_land, dst_air_idx)
				add_valid_tank_2_moves(gc, &src_land) //reset valid moves since transport cargo has changed
				continue
			}
			dst_land := gc.lands[dst_air_idx]
			landDistance := src_land.land_distances[dst_air_idx]
			if (dst_land.team_units[enemy_team_idx] > 0) { 	//combat ends turn
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
				src_land.active_armies[Active_Army.TANK_0_MOVES] +=
					src_land.active_armies[Active_Army.TANK_UNMOVED]
				src_land.active_armies[Active_Army.TANK_UNMOVED] = 0
				break
			case 1:
				move_single_army(&dst_land, .TANK_1_MOVES, gc.cur_player, .TANK_UNMOVED, &src_land)
			case 2:
				move_single_army(&dst_land, .TANK_0_MOVES, gc.cur_player, .TANK_UNMOVED, &src_land)
			}
		}
	}
	if gc.clear_needed do clear_move_history(gc)
	return true
}

move_tanks_1 :: proc(gc: ^Game_Cache) -> (ok: bool) {
	debug_checks(gc)
	team := gc.cur_player.team
	enemy_team_idx := team.enemy_team.index
	gc.clear_needed = false
	for &src_land in gc.lands {
		if src_land.active_armies[Active_Army.TANK_1_MOVES] == 0 do continue
		dst_air_idx := reset_valid_moves(gc, &src_land)
		add_valid_large_army_moves(gc, &src_land)
		for src_land.active_armies[Active_Army.TANK_1_MOVES] > 0 {
			dst_air_idx = get_move_input(gc, TANK_1_MOVES_NAME, &src_land) or_return
			if (dst_air_idx >= len(LANDS_DATA)) {
				load_large_transport(gc, .TANK_1_MOVES, &src_land, dst_air_idx)
				add_valid_large_army_moves(gc, &src_land)
				continue
			}
			dst_land := &gc.lands[dst_air_idx]
			landDistance := src_land.land_distances[dst_air_idx]
			if dst_land.team_units[enemy_team_idx] > 0 { 	//combat ends turn
				dst_land.combat_status = Combat_Status.PRE_COMBAT
			} else if (!team.is_allied[dst_land.owner.index]) { 	//simple relocate ends turn
				conquer_land(gc, dst_land)
			}
			if landDistance == 0 {
				src_land.active_armies[Active_Army.TANK_0_MOVES] +=
					src_land.active_armies[Active_Army.TANK_1_MOVES]
				src_land.active_armies[Active_Army.TANK_1_MOVES] = 0
				break
			}
			move_single_army(dst_land, .TANK_0_MOVES, gc.cur_player, .TANK_1_MOVES, &src_land)
		}
	}
	if gc.clear_needed do clear_move_history(gc)
	return true
}

add_valid_tank_2_moves :: proc(gc: ^Game_Cache, src_land: ^Land) {
	// check for moving from land to land (two moves away)
	enemy_team_idx := gc.cur_player.team.enemy_team.index
	for dst_land in sa.slice(&src_land.lands_2_moves_away) {
		if (src_land.skipped_moves[dst_land.land.territory_index]) do continue
		sa.push(&gc.valid_moves, dst_land.land.territory_index)
	}
	// check for moving from land to sea (two moves away)
	for &dst_sea_2_away in sa.slice(&src_land.seas_2_moves_away) {
		Idle_Ships := dst_sea_2_away.sea.idle_ships[gc.cur_player.index]
		if (Idle_Ships[Idle_Ship.TRANS_EMPTY] == 0 && Idle_Ships[Idle_Ship.TRANS_1I] == 0) { 	// assume large, only tanks move 2
			continue
		}
		if (src_land.skipped_moves[dst_sea_2_away.sea.territory_index]) do continue
		for mid_land in sa.slice(&dst_sea_2_away.mid_lands) {
			if mid_land.team_units[enemy_team_idx] == 0 {
				sa.push(&gc.valid_moves, dst_sea_2_away.sea.territory_index)
				break
			}
		}
	}
	add_valid_large_army_moves(gc, src_land)
}
