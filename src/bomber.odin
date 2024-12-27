package oaaa
import sa "core:container/small_array"
import "core:mem"
import "core:slice"

Bomber_Moves := [?]Active_Plane {
	.BOMBER_0_MOVES,
	.BOMBER_5_MOVES,
	.BOMBER_4_MOVES,
	.BOMBER_3_MOVES,
	.BOMBER_2_MOVES,
	.BOMBER_1_MOVES,
	.BOMBER_0_MOVES,
}

BOMBER_UNMOVED_NAME :: "BOMBER_UNMOVED"
BOMBER_MAX_MOVES :: 6

move_unmoved_bombers :: proc(gc: ^Game_Cache) -> (ok: bool) {
	debug_checks(gc)
	clear_needed := false
	defer if clear_needed do clear_move_history(gc)
	for src_air in gc.territories {
		if src_air.Active_Planes[Active_Plane.BOMBER_UNMOVED] == 0 do continue
		if !gc.is_bomber_cache_current do refresh_can_bombers_land_here(gc)
		dst_air_idx := reset_valid_moves(gc, &src_air, &clear_needed)
		add_valid_bomber_moves(gc, src_air)
		for src_air.Active_Planes[Active_Plane.BOMBER_UNMOVED] > 0 {
			get_move_input(gc, BOMBER_UNMOVED_NAME, &src_air, &dst_air_idx) or_return
			dst_air := gc.territories[dst_air_idx]
			air_dist := src_air.air_distances[dst_air_idx]
			if !dst_air.can_bomber_land_here > 0 {
				dst_air.combat_status = .PRE_COMBAT
			} else {
				air_dist = BOMBER_MAX_MOVES
			}
			move_plane(dst_air, Bomber_Moves[air_dist], gc.current_turn, .BOMBER_UNMOVED, src_air)
		}
	}
	return true
}

bomber_can_land_here :: proc(territory: ^Territory) {
	territory.can_bomber_land_here = true
	for air in sa.slice(&territory.adjacent_airs) {
		air.can_bomber_land_in_1_move = true
	}
	for air in sa.slice(&territory.airs_2_moves_away) {
		air.can_bomber_land_in_2_moves = true
	}
}

refresh_can_bombers_land_here :: proc(gc: ^Game_Cache) {
	// initialize all to false
	for territory in gc.territories {
		territory.can_bomber_land_here = false
		territory.can_bomber_land_in_1_move = false
		territory.can_bomber_land_in_2_moves = false
	}
	// check if any bombers have full moves remaining
	for &land in gc.lands {
		// is allied owned and not recently conquered?
		//Since bombers happen first, we can assume that the land is not recently conquered
		if gc.current_turn.team == land.owner.team { 	//&& land.combat_status == .NO_COMBAT {
			bomber_can_land_here(&land)
		}
	}
	gc.is_bomber_cache_current = true
}
add_valid_bomber_moves :: proc(gc: ^Game_Cache, src_air: ^Territory) {
	for dst_air in sa.slice(&src_air.adjacent_airs) {
		add_meaningful_bomber_move(gc, src_air, dst_air)
	}
	for dst_air in sa.slice(&src_air.airs_2_moves_away) {
		add_meaningful_bomber_move(gc, src_air, dst_air)
	}
	for dst_air in sa.slice(&src_air.airs_3_moves_away) {
		add_meaningful_bomber_move(gc, src_air, dst_air)
	}
	for dst_air in sa.slice(&src_air.airs_4_moves_away) {
		if dst_air.can_bomber_land_in_2_moves {
			add_meaningful_bomber_move(gc, src_air, dst_air)
		}
	}
	for dst_air in sa.slice(&src_air.airs_5_moves_away) {
		if dst_air.can_bomber_land_in_1_move {
			add_meaningful_bomber_move(gc, src_air, dst_air)
		}
	}
	for dst_air in sa.slice(&src_air.airs_6_moves_away) {
		if dst_air.can_bomber_land_here {
			add_move_if_not_skipped(gc, src_air, dst_air)
		}
	}
}

add_meaningful_bomber_move :: proc(gc: ^Game_Cache, src_air: ^Territory, dst_air: ^Territory) {
	terr_idx := dst_air.territory_index
	if dst_air.can_bomber_land_here ||
	   dst_air.teams_unit_count[gc.current_turn.team.enemy_team.terr_idx] != 0 ||
	   terr_idx < len(gc.lands) &&
		   gc.lands[terr_idx].factory_damage < gc.lands[terr_idx].factory_max_damage * 2 {
		add_move_if_not_skipped(gc, src_air, dst_air)
	}
}

land_bomber_units::proc(gc: ^Game_Cache) -> (ok: bool) {}
