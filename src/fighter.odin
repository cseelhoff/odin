package oaaa
import sa "core:container/small_array"
import "core:mem"
import "core:slice"

Fighter_After_Moves := [?]Active_Plane {
	.FIGHTER_4_MOVES,
	.FIGHTER_3_MOVES,
	.FIGHTER_2_MOVES,
	.FIGHTER_1_MOVES,
	.FIGHTER_0_MOVES,
}

FIGHTER_UNMOVED_NAME :: "FIGHTER_UNMOVED"
FIGHTER_MAX_MOVES :: 4

move_unmoved_fighters :: proc(gc: ^Game_Cache) -> (ok: bool) {
	debug_checks(gc)
	gc.clear_needed = false
	defer if gc.clear_needed do clear_move_history(gc)
	for &src_air in gc.territories {
		if src_air.active_planes[Active_Plane.FIGHTER_UNMOVED] == 0 do continue
		if !gc.is_fighter_cache_current do refresh_can_fighters_land_here(gc)
		dst_air_idx := reset_valid_moves(gc, src_air)
		add_valid_fighter_moves(gc, src_air)
		for src_air.active_planes[Active_Plane.FIGHTER_UNMOVED] > 0 {
			dst_air_idx = get_move_input(gc, FIGHTER_UNMOVED_NAME, src_air) or_return
			dst_air := gc.territories[dst_air_idx]
			airDistance := src_air.air_distances[dst_air_idx]
			if (dst_air.teams_unit_count[gc.current_turn.team.enemy_team.index] > 0) {
				dst_air.combat_status = .PRE_COMBAT
			} else {
				airDistance = FIGHTER_MAX_MOVES
			}
			move_plane(
				dst_air,
				Fighter_After_Moves[airDistance],
				gc.current_turn,
				.FIGHTER_UNMOVED,
				src_air,
			)
		}
	}
	return true
}

fighter_can_land_here :: proc(territory: ^Territory) {
	territory.can_fighter_land_here = true
	for air in sa.slice(&territory.adjacent_airs) {
		air.can_fighter_land_in_1_move = true
	}
}

refresh_can_fighters_land_here :: proc(gc: ^Game_Cache) {
	// initialize all to false
	for territory in gc.territories {
		territory.can_fighter_land_here = false
		territory.can_fighter_land_in_1_move = false
	}
	for &land in gc.lands {
		// is allied owned and not recently conquered?
		if gc.current_turn.team == land.owner.team &&
		   land.combat_status == Combat_Status.NO_COMBAT {
			fighter_can_land_here(&land.territory)
		}
		// check for possiblity to build carrier under fighter
		if (land.owner == gc.current_turn && land.factory_max_damage > 0) {
			for &sea in sa.slice(&land.adjacent_seas) {
				fighter_can_land_here(&sea.territory)
			}
		}
	}
	for &sea in gc.seas {
		if sea.allied_carriers > 0 {
			fighter_can_land_here(&sea.territory)
		}
		// if player owns a carrier, then landing area is 2 spaces away
		if sea.active_ships[Active_Ship.CARRIER_UNMOVED] > 0 {
			for adj_sea in sa.slice(&sea.canal_paths[gc.canal_state].adjacent_seas) {
				fighter_can_land_here(adj_sea)
			}
			for sea_2_moves_away in sa.slice(&sea.canal_paths[gc.canal_state].seas_2_moves_away) {
				fighter_can_land_here(sea_2_moves_away.sea)
			}
		}
	}
	gc.is_fighter_cache_current = true
}

add_valid_fighter_moves :: proc(gc: ^Game_Cache, src_air: ^Territory) {
	for dst_air in sa.slice(&src_air.adjacent_airs) {
		add_meaningful_fighter_move(gc, src_air, dst_air)
	}
	for dst_air in sa.slice(&src_air.airs_2_moves_away) {
		add_meaningful_fighter_move(gc, src_air, dst_air)
	}
	for dst_air in sa.slice(&src_air.airs_3_moves_away) {
		if dst_air.can_fighter_land_in_1_move {
			add_meaningful_fighter_move(gc, src_air, dst_air)
		}
	}
	for dst_air in sa.slice(&src_air.airs_4_moves_away) {
		if dst_air.can_fighter_land_here {
			add_move_if_not_skipped(gc, src_air, dst_air)
		}
	}
}

add_meaningful_fighter_move :: proc(gc: ^Game_Cache, src_air: ^Territory, dst_air: ^Territory) {
	if dst_air.can_fighter_land_here ||
	   dst_air.teams_unit_count[gc.current_turn.team.enemy_team.index] != 0 {
		add_move_if_not_skipped(gc, src_air, dst_air)
	}
}

land_fighter_units::proc(gc: ^Game_Cache) -> (ok: bool) {
	return false
}
