package oaaa
import sa "core:container/small_array"
import "core:fmt"
import "core:mem"
import "core:slice"

Transports_With_1_MOVES := [?]Active_Ship {
	.TRANS_1I_1_MOVES,
	.TRANS_1A_1_MOVES,
	.TRANS_1T_1_MOVES,
	.TRANS_2I_1_MOVES,
	.TRANS_1I_1A_1_MOVES,
	.TRANS_1I_1T_1_MOVES,
}

Transports_Needing_Staging := [?]Active_Ship {
	.TRANS_EMPTY_UNMOVED,
	.TRANS_1I_UNMOVED,
	.TRANS_1A_UNMOVED,
	.TRANS_1T_UNMOVED,
}

Transports_After_Prestage_0_Moves := [?]Active_Ship {
	Active_Ship.TRANS_EMPTY_UNMOVED = .TRANS_EMPTY_2_MOVES,
	Active_Ship.TRANS_1I_UNMOVED    = .TRANS_1I_2_MOVES,
	Active_Ship.TRANS_1A_UNMOVED    = .TRANS_1A_2_MOVES,
	Active_Ship.TRANS_1T_UNMOVED    = .TRANS_1T_2_MOVES,
}

Transports_After_Prestage_1_Move := [?]Active_Ship {
	Active_Ship.TRANS_EMPTY_UNMOVED = .TRANS_EMPTY_1_MOVES,
	Active_Ship.TRANS_1I_UNMOVED    = .TRANS_1I_1_MOVES,
	Active_Ship.TRANS_1A_UNMOVED    = .TRANS_1A_1_MOVES,
	Active_Ship.TRANS_1T_UNMOVED    = .TRANS_1T_1_MOVES,
}

Transports_After_Prestage_2_Moves := [?]Active_Ship {
	Active_Ship.TRANS_EMPTY_UNMOVED = .TRANS_EMPTY_0_MOVES,
	Active_Ship.TRANS_1I_UNMOVED    = .TRANS_1I_0_MOVES,
	Active_Ship.TRANS_1A_UNMOVED    = .TRANS_1A_0_MOVES,
	Active_Ship.TRANS_1T_UNMOVED    = .TRANS_1T_0_MOVES,
}

Transports_With_Large_Cargo_Space := [?]bool {
	Active_Ship.TRANS_EMPTY_UNMOVED = true,
	Active_Ship.TRANS_1I_UNMOVED    = true,
	Active_Ship.TRANS_1A_UNMOVED    = false,
	Active_Ship.TRANS_1T_UNMOVED    = false,
}

Transport_Load_Unit := [len(Idle_Army)][len(Active_Ship)]Active_Ship {
	Idle_Army.INFANTRY = {
		Active_Ship.TRANS_1T_2_MOVES = .TRANS_1I_1T_2_MOVES,
		Active_Ship.TRANS_1A_2_MOVES = .TRANS_1I_1A_2_MOVES,
		Active_Ship.TRANS_1I_2_MOVES = .TRANS_2I_2_MOVES,
		Active_Ship.TRANS_EMPTY_2_MOVES = .TRANS_1I_2_MOVES,
		Active_Ship.TRANS_1T_1_MOVES = .TRANS_1I_1T_1_MOVES,
		Active_Ship.TRANS_1A_1_MOVES = .TRANS_1I_1A_1_MOVES,
		Active_Ship.TRANS_1I_1_MOVES = .TRANS_2I_1_MOVES,
		Active_Ship.TRANS_EMPTY_1_MOVES = .TRANS_1I_1_MOVES,
		Active_Ship.TRANS_1T_0_MOVES = .TRANS_1I_1T_0_MOVES,
		Active_Ship.TRANS_1A_0_MOVES = .TRANS_1I_1A_0_MOVES,
		Active_Ship.TRANS_1I_0_MOVES = .TRANS_2I_0_MOVES,
		Active_Ship.TRANS_EMPTY_0_MOVES = .TRANS_1I_0_MOVES,
	},
	Idle_Army.ARTILLERY = {
		Active_Ship.TRANS_1I_2_MOVES = .TRANS_1I_1A_2_MOVES,
		Active_Ship.TRANS_EMPTY_2_MOVES = .TRANS_1A_2_MOVES,
		Active_Ship.TRANS_1I_1_MOVES = .TRANS_1I_1A_1_MOVES,
		Active_Ship.TRANS_EMPTY_1_MOVES = .TRANS_1A_1_MOVES,
		Active_Ship.TRANS_1I_0_MOVES = .TRANS_1I_1A_0_MOVES,
		Active_Ship.TRANS_EMPTY_0_MOVES = .TRANS_1A_0_MOVES,
	},
	Idle_Army.TANKS = {
		Active_Ship.TRANS_1I_2_MOVES = .TRANS_1I_1T_2_MOVES,
		Active_Ship.TRANS_EMPTY_2_MOVES = .TRANS_1T_2_MOVES,
		Active_Ship.TRANS_1I_1_MOVES = .TRANS_1I_1T_1_MOVES,
		Active_Ship.TRANS_EMPTY_1_MOVES = .TRANS_1T_1_MOVES,
		Active_Ship.TRANS_1I_0_MOVES = .TRANS_1I_1T_0_MOVES,
		Active_Ship.TRANS_EMPTY_0_MOVES = .TRANS_1T_0_MOVES,
	},
}

Transport_Can_Load_Large := [?]Active_Ship {
	Active_Ship.TRANS_1I_2_MOVES,
	Active_Ship.TRANS_EMPTY_2_MOVES,
	Active_Ship.TRANS_1I_1_MOVES,
	Active_Ship.TRANS_EMPTY_1_MOVES,
	Active_Ship.TRANS_1I_0_MOVES,
	Active_Ship.TRANS_EMPTY_0_MOVES,
}

Transport_Can_Load_Small := [?]Active_Ship {
	Active_Ship.TRANS_1T_2_MOVES,
	Active_Ship.TRANS_1A_2_MOVES,
	Active_Ship.TRANS_1I_2_MOVES,
	Active_Ship.TRANS_EMPTY_2_MOVES,
	Active_Ship.TRANS_1T_1_MOVES,
	Active_Ship.TRANS_1A_1_MOVES,
	Active_Ship.TRANS_1I_1_MOVES,
	Active_Ship.TRANS_EMPTY_1_MOVES,
	Active_Ship.TRANS_1T_0_MOVES,
	Active_Ship.TRANS_1A_0_MOVES,
	Active_Ship.TRANS_1I_0_MOVES,
	Active_Ship.TRANS_EMPTY_0_MOVES,
}

Transport_Done_Moving := [?]Active_Ship {
	Active_Ship.TRANS_1I_1_MOVES = .TRANS_1I_0_MOVES,
	Active_Ship.TRANS_1A_1_MOVES = .TRANS_1A_0_MOVES,
	Active_Ship.TRANS_1T_1_MOVES = .TRANS_1T_0_MOVES,
	Active_Ship.TRANS_2I_1_MOVES = .TRANS_2I_0_MOVES,
	Active_Ship.TRANS_1I_1A_1_MOVES = .TRANS_1I_1A_0_MOVES,
	Active_Ship.TRANS_1I_1T_1_MOVES = .TRANS_1I_1T_0_MOVES,
}

stage_transport_units :: proc(gc: ^Game_Cache) -> (ok: bool) {
	debug_checks(gc)
	player_idx := gc.current_turn.index
	team_idx := gc.current_turn.team.index
	for ship in Transports_Needing_Staging {
		clear_needed := false
		defer if clear_needed do clear_move_history(gc)
		for &src_sea in gc.seas {
			if src_sea.Active_Ships[ship] == 0 do continue
			dst_air_idx := reset_valid_moves(gc, &src_air, &clear_needed)
			add_valid_transport_moves(gc, &src_sea, 2)
			for src_sea.Active_Ships[ship] > 0 {
				if (gc.valid_moves.len > 1) {
					if (gc.answers_remaining == 0) {
						return true
					}
					dst_air_idx = get_move_input(gc, Ship_Names[ship], &src_sea)
				}
				dst_air := gc.territories[dst_air_idx]
				update_move_history(gc, &src_sea.territory, dst_air_idx)
				dst_sea_idx := dst_air_idx - len(gc.lands)
				sea_distance := src_sea.canal_paths[gc.canal_state].sea_distance[dst_sea_idx]
				dst_sea := gc.seas[dst_sea_idx]
				if (dst_sea.enemy_blockade_total > 0) {
					// only allow staging to sea with enemy blockade if other unit started combat
					// dst_air.combat_status = Combat_Status.PRE_COMBAT
					sea_distance = 2
				}
				ship_after_move: Active_Ship
				switch (sea_distance) {
				case 0:
					src_sea.Active_Ships[Transports_After_Prestage_0_Moves[ship]] +=
						src_sea.Active_Ships[ship]
					src_sea.Active_Ships[ship] = 0
					break
				case 1:
					ship_after_move = Transports_After_Prestage_1_Move[ship]
				case 2:
					ship_after_move = Transports_After_Prestage_2_Moves[ship]
				case:
					fmt.eprintln("Error: Invalid sea_distance: %d\n", sea_distance)
					return false
				}
				dst_sea.Active_Ships[ship_after_move] += 1
				dst_sea.Idle_Ships[player_idx][Active_Ship_To_Idle[ship_after_move]] += 1
				dst_sea.teams_unit_count[team_idx] += 1
				src_sea.Active_Ships[ship] -= 1
				src_sea.Idle_Ships[player_idx][Active_Ship_To_Idle[ship]] -= 1
				src_sea.teams_unit_count[team_idx] -= 1
			}
		}
	}
	return true
}

load_unit :: proc(
	src_land: ^Land,
	dst_sea: ^Sea,
	active_transport: Active_Ship,
	player_idx: int,
	Active_Army: Active_Army,
) {
	Idle_Army := Active_Army_To_Idle[Active_Army]
	new_active_transport := Transport_Load_Unit[Idle_Army][active_transport]
	dst_sea.Active_Ships[new_active_transport] += 1
	dst_sea.Idle_Ships[player_idx][Active_Ship_To_Idle[new_active_transport]] += 1
	src_land.Active_Armys[Active_Army] -= 1
	src_land.Idle_Armys[player_idx][Idle_Army] -= 1
}

load_large_transport :: proc(
	gc: ^Game_Cache,
	Active_Army: Active_Army,
	src_land: ^Land,
	dst_sea: ^Sea,
) {
	for transport in Transport_Can_Load_Large {
		if dst_sea.Active_Ships[transport] > 0 {
			load_unit(src_land, dst_sea, transport, gc.current_turn.index, Active_Army)
			return
		}
	}
}

load_small_transport :: proc(
	gc: ^Game_Cache,
	Active_Army: Active_Army,
	src_land: ^Land,
	dst_sea: ^Sea,
) {
	for transport in Transport_Can_Load_Small {
		if dst_sea.Active_Ships[transport] > 0 {
			load_unit(src_land, dst_sea, transport, gc.current_turn.index, Active_Army)
			return
		}
	}
}

skip_empty_transports::proc(gc: ^Game_Cache) {
	for &src_sea in gc.seas {
		src_sea.Active_Ships[.TRANS_EMPTY_0_MOVES] +=
			src_sea.Active_Ships[.TRANS_EMPTY_1_MOVES] +
			src_sea.active[.TRANS_EMPTY_2_MOVES]
		src_sea.Active_Ships[.TRANS_EMPTY_1_MOVES] = 0
		src_sea.Active_Ships[.TRANS_EMPTY_2_MOVES] = 0
  }
}

move_transports::proc(gc: ^Game_Cache) -> (ok: bool) {
  debug_checks(gc)
	player_idx := gc.current_turn.index
	team_idx := gc.current_turn.team.index
  for transport in Transports_With_1_MOVES {
		clear_needed := false
		defer if clear_needed do clear_move_history(gc)
		for &src_sea in gc.seas {
			if src_sea.Active_Ships[transport] == 0 do continue
			dst_air_idx := reset_valid_moves(gc, &src_sea, &clear_needed)
			add_valid_transport_moves(gc, &src_sea, 1)
			for src_sea.Active_Ships[transport] > 0 {
				get_move_input(gc, Ship_Names[transport], &src_sea, &dst_air_idx) or_return
				dst_sea_idx := dst_air_idx - LANDS_COUNT
				dst_sea := &gc.seas[dst_sea_idx]
				// if dst_sea.enemy_blockade_total == 0 || dst_sea.combat_status == CombatStatus.PRE_COMBAT {
				seaDistance := src_sea.land_distances[dst_air_idx]
				if seaDistance==0 {
					src_sea.Active_Ships[Transport_Done_Moving[transport]] += src_sea.Active_Ships[transport]
					src_sea.Active_Ships[transport] = 0
					break
				}
				Active_Ships->at(dst_sea)[unloading_state]++;
				idle_ships.at(dst_sea)++;
				total_player_units_player.at(dst_air)++;
				team_units_count_team.at(dst_air)++;
				active_unmoved_ships--;
				idle_ships.at(src_sea)--;
				total_player_units_player.at(src_air)--;
				team_units_count_team.at(src_air)--;
				if (unit_type <= TRANS1T) {
					transports_with_small_cargo_space[dst_sea]++;
					transports_with_small_cargo_space[src_sea]--;
					if (unit_type <= TRANS1I) {
						transports_with_large_cargo_space[dst_sea]++;
						transports_with_large_cargo_space[src_sea]--;
					}
				}
			}
		}
	}
  return true
}

unload_transports::proc(gc: ^Game_Cache) -> (ok: bool) {}
