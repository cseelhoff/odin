package oaaa
import sa "core:container/small_array"

move_infantry :: proc(gc: ^Game_Cache) -> (ok: bool) {
	debug_checks(gc)
	team := gc.cur_player.team
	enemy_team_idx := team.enemy_team.index
	gc.clear_needed = false
	for &src_land in gc.lands {
		if (src_land.active_armies[Active_Army.INF_UNMOVED] == 0) do continue
		dst_air_idx := reset_valid_moves(gc, &src_land)
		add_valid_infantry_moves(gc, &src_land)
		for src_land.active_armies[Active_Army.INF_UNMOVED] > 0 {
			dst_air_idx = get_move_input(gc, TANK_UNMOVED_NAME, &src_land) or_return
			if (dst_air_idx >= len(LANDS_DATA)) {
				load_small_transport(gc, .INF_UNMOVED, &src_land, dst_air_idx)
				add_valid_infantry_moves(gc, &src_land)
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
				src_land.active_armies[Active_Army.INF_0_MOVES] +=
					src_land.active_armies[Active_Army.INF_UNMOVED]
				src_land.active_armies[Active_Army.INF_UNMOVED] = 0
				break
			}
			move_single_army(dst_land, .INF_0_MOVES, gc.cur_player, .INF_UNMOVED, &src_land)
		}
	}
	if gc.clear_needed do clear_move_history(gc)
	return true
}
