package oaaa

import "core:fmt"

MAX_PLANE_MOVES :: 6

Idle_Plane :: enum {
	FIGHTER,
	BOMBER,
}

Active_Plane :: enum {
	FIGHTER_UNMOVED, // distinct from 4_moves, for when ships placed under fighter
	FIGHTER_4_MOVES,
	FIGHTER_3_MOVES,
	FIGHTER_2_MOVES,
	FIGHTER_1_MOVES,
	FIGHTER_0_MOVES,
	BOMBER_UNMOVED,
	BOMBER_5_MOVES,
	BOMBER_4_MOVES,
	BOMBER_3_MOVES,
	BOMBER_2_MOVES,
	BOMBER_1_MOVES,
	BOMBER_0_MOVES,
}

Plane_Names := [?]string {
	Active_Plane.FIGHTER_UNMOVED = "FIGHTER_UNMOVED",
	Active_Plane.FIGHTER_4_MOVES = "FIGHTER_4_MOVES",
	Active_Plane.FIGHTER_3_MOVES = "FIGHTER_3_MOVES",
	Active_Plane.FIGHTER_2_MOVES = "FIGHTER_2_MOVES",
	Active_Plane.FIGHTER_1_MOVES = "FIGHTER_1_MOVES",
	Active_Plane.FIGHTER_0_MOVES = "FIGHTER_0_MOVES",
	Active_Plane.BOMBER_UNMOVED  = "BOMBER_UNMOVED",
	Active_Plane.BOMBER_5_MOVES  = "BOMBER_5_MOVES",
	Active_Plane.BOMBER_4_MOVES  = "BOMBER_4_MOVES",
	Active_Plane.BOMBER_3_MOVES  = "BOMBER_3_MOVES",
	Active_Plane.BOMBER_2_MOVES  = "BOMBER_2_MOVES",
	Active_Plane.BOMBER_1_MOVES  = "BOMBER_1_MOVES",
	Active_Plane.BOMBER_0_MOVES  = "BOMBER_0_MOVES",
}

Plane_After_Moves := [?]Active_Plane {
	Active_Plane.FIGHTER_UNMOVED = Active_Plane.FIGHTER_0_MOVES,
	Active_Plane.BOMBER_UNMOVED  = Active_Plane.BOMBER_0_MOVES,
}

move_unmoved_planes :: proc(gc: ^Game_Cache) -> (ok: bool) {
	for plane in Unmoved_Planes {
		move_plane_airs(gc, plane) or_return
	}
	return true
}

move_plane_airs :: proc(gc: ^Game_Cache, plane: Active_Plane) -> (ok: bool) {
	debug_checks(gc)
	gc.clear_needed = false
	for &src_air in gc.territories {
		move_plane_air(gc, src_air, plane)
	}
	if gc.clear_needed do clear_move_history(gc)
	return true
}

move_plane_air :: proc(gc: ^Game_Cache, src_air: ^Territory, plane: Active_Plane) -> (ok: bool) {
	if src_air.active_planes[plane] == 0 do return true
	refresh_plane_can_land_here(gc, plane)
	reset_valid_moves(gc, src_air)
	add_valid_plane_moves(gc, src_air, plane)
	for src_air.active_planes[plane] > 0 {
		move_next_plane_in_air(gc, src_air, plane) or_return
	}
	return true
}

move_next_plane_in_air :: proc(gc: ^Game_Cache, src_air: ^Territory, plane: Active_Plane) -> (ok: bool) {
	dst_air_idx := get_move_input(gc, Plane_Names[plane], src_air) or_return
	dst_air := gc.territories[dst_air_idx]
	if skip_plane(src_air, dst_air, plane, gc.cur_player.team.enemy_team.index) do return true
	plane_after_move := plane_enemy_checks(gc, src_air, dst_air, plane)
	move_single_plane(dst_air, plane_after_move, gc.cur_player, plane, src_air)
	return true
}

skip_plane :: proc(
	src_air: ^Territory,
	dst_air: ^Territory,
	plane: Active_Plane,
	enemy_idx: Team_ID,
) -> (
	ok: bool,
) {
	if src_air != dst_air || dst_air.team_units[enemy_idx] > 0 do return false
	src_air.active_planes[Plane_After_Moves[plane]] += src_air.active_planes[plane]
	src_air.active_planes[plane] = 0
	return true
}

move_single_plane :: proc(
	dst_air: ^Territory,
	dst_unit: Active_Plane,
	player: ^Player,
	src_unit: Active_Plane,
	src_air: ^Territory,
) {
	dst_air.active_planes[dst_unit] += 1
	dst_air.idle_planes[player.index][Active_Army_To_Idle[dst_unit]] += 1
	dst_air.team_units[player.team.index] += 1
	src_air.active_planes[src_unit] -= 1
	src_air.idle_planes[player.index][Active_Army_To_Idle[dst_unit]] -= 1
	src_air.team_units[player.team.index] -= 1
	src_air.active_planes[src_unit] -= 1
}

plane_enemy_checks :: proc(
	gc: ^Game_Cache,
	src_air: ^Territory,
	dst_air: ^Territory,
	plane: Active_Plane,
) -> Active_Plane {
	if plane == Active_Plane.FIGHTER_UNMOVED {
		return fighter_enemy_checks(gc, src_air, dst_air)
	}
	return bomber_enemy_checks(gc, src_air, dst_air)
}

add_valid_plane_moves :: proc(gc: ^Game_Cache, src_air: ^Territory, plane: Active_Plane) {
	if plane == Active_Plane.FIGHTER_UNMOVED {
		add_valid_fighter_moves(gc, src_air)
	} else {
		add_valid_bomber_moves(gc, src_air)
	}
}

refresh_plane_can_land_here :: proc(gc: ^Game_Cache, plane: Active_Plane) {
	if plane == Active_Plane.FIGHTER_UNMOVED {
		refresh_can_fighters_land_here(gc)
	} else {
		refresh_can_bombers_land_here(gc)
	}
}

crash_air_units :: proc(gc: ^Game_Cache) -> (ok: bool) {
	fmt.eprintln("Error: crash_air_units not implemented")
	return false
}
