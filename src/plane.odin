package oaaa

Idle_Plane :: enum {
	FIGHTERS_AIR,
	BOMBERS_AIR,
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
	Active_Plane.BOMBER_UNMOVED = BOMBER_UNMOVED_NAME,
	Active_Plane.BOMBER_5_MOVES = "BOMBER_5_MOVES",
	Active_Plane.BOMBER_4_MOVES = "BOMBER_4_MOVES",
	Active_Plane.BOMBER_3_MOVES = "BOMBER_3_MOVES",
	Active_Plane.BOMBER_2_MOVES = "BOMBER_2_MOVES",
	Active_Plane.BOMBER_1_MOVES = "BOMBER_1_MOVES",
	Active_Plane.BOMBER_0_MOVES = "BOMBER_0_MOVES",
}

move_plane :: proc(
	dst_air: ^Territory,
	dst_unit: Active_Plane,
	player: ^Player,
	src_unit: Active_Plane,
	src_air: ^Territory,
) {
	dst_air.Active_Planes[dst_unit] += 1
	dst_air.Idle_Plane_units[player.index][Active_Army_To_Idle[dst_unit]] += 1
	dst_air.teams_unit_count[player.team.index] += 1
	src_air.Active_Planes[src_unit] -= 1
	src_air.Idle_Plane_units[player.index][Active_Army_To_Idle[dst_unit]] -= 1
	src_air.teams_unit_count[player.team.index] -= 1
	src_air.Active_Planes[src_unit] -= 1
}

crash_air_units::proc(gc: ^Game_Cache) -> (ok: bool) {}
