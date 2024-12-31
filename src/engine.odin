package oaaa
import sa "core:container/small_array"
import "core:fmt"
import "core:mem"
import "core:slice"

when ODIN_DEBUG {
	debug_checks :: proc(gc: ^Game_Cache) {
		// No-op
	}
} else {
	debug_checks :: proc(gc: ^Game_Cache) {
		// Add your debug checks here
	}
}
play_full_turn :: proc(gc: ^Game_Cache) -> (ok: bool) {
	move_unmoved_fighters(gc) or_return // move before carriers for more options
	move_unmoved_bombers(gc) or_return
	move_dest_crus_bs(gc) or_return
	move_subs(gc) or_return
	move_carriers(gc) or_return
	stage_transport_units(gc) or_return
	move_tanks_2(gc) or_return
	move_tanks_1(gc) or_return
	move_artillery(gc) or_return
	move_infantry(gc) or_return
	move_transports(gc) or_return
	resolve_sea_battles(gc) or_return
	unload_transports(gc) or_return
	resolve_land_battles(gc) or_return
	move_aa_guns(gc) or_return
	land_fighter_units(gc) or_return
	land_bomber_units(gc) or_return
	buy_units(gc) or_return
	crash_air_units(gc) or_return
	reset_units_fully(gc) or_return
	buy_factory(gc) or_return
	collect_money(gc) or_return
	rotate_turns(gc) or_return
	return true
}

add_move_if_not_skipped :: proc(gc: ^Game_Cache, src_air: ^Territory, dst_air: ^Territory) {
	if !src_air.skipped_moves[dst_air.territory_index] {
		sa.push(&gc.valid_moves, dst_air.territory_index)
	}
}

update_move_history :: proc(gc: ^Game_Cache, src_air: ^Territory, dst_air_idx: int) {
	// get a list of newly skipped valid_actions
	assert(gc.valid_moves.len > 0)
	valid_action := gc.valid_moves.data[gc.valid_moves.len - 1]
	for {
		if (valid_action == dst_air_idx) do break
		src_air.skipped_moves[valid_action] = true
		//apply_skip(gc, src_air, gc.territories[valid_action])
		valid_action = sa.pop_back(&gc.valid_moves)
	}
}

// apply_skip :: proc(gc: ^Game_Cache, src_air: ^Territory, dst_air: ^Territory) {
// 	for skipped_move, src_air_idx in dst_air.skipped_moves {
// 		if skipped_move {
// 			src_air.skipped_moves[src_air_idx] = true
// 		}
// 	}
// }

clear_move_history :: proc(gc: ^Game_Cache) {
	for territory in gc.territories {
		mem.zero_slice(territory.skipped_moves[:])
	}
}

reset_valid_moves :: proc(gc: ^Game_Cache, territory: ^Territory) {// -> (dst_air_idx: int) {
	//dst_air_idx = territory.territory_index
	sa.resize(&gc.valid_moves, 1)
	//sa.set(&gc.valid_moves, 0, dst_air_idx)
	sa.set(&gc.valid_moves, 0, territory.territory_index)
	gc.clear_needed = true
	//return
}

allied_fighters_exist :: proc(gc: ^Game_Cache, territory: ^Territory) -> bool {
	for player in sa.slice(&gc.cur_player.team.players) {
		if territory.idle_planes[Idle_Plane.FIGHTER][player.index] > 0 {
			return true
		}
	}
	return false
}

no_defender_threat_exists :: proc(gc: ^Game_Cache, src_sea: ^Sea) -> bool {
	if (src_sea.enemy_blockade_total == 0 && src_sea.enemy_fighters_total == 0) {
		if src_sea.enemy_submarines_total == 0 do return true
		if do_allied_destroyers_exist(gc, src_sea) do return false
		return true
	}
	return false
}

get_allied_subs_count :: proc(gc: ^Game_Cache, src_sea: ^Sea) -> (allied_subs: int) {
	allied_subs = 0
	for player in sa.slice(&gc.cur_player.team.players) {
		allied_subs += src_sea.idle_ships[player.index][Idle_Ship.SUB]
	}
	return
}

do_allied_destroyers_exist :: proc(gc: ^Game_Cache, src_sea: ^Sea) -> bool {
	for player in sa.slice(&gc.cur_player.team.players) {
		if src_sea.idle_ships[player.index][Idle_Ship.DESTROYER] > 0 {
			return true
		}
	}
	return false
}

disable_bombardment :: proc(gc: ^Game_Cache, src_sea: ^Sea) {
	src_sea.active_ships[Active_Ship.CRUISER_BOMBARDED] +=
		src_sea.active_ships[Active_Ship.CRUISER_0_MOVES]
	src_sea.active_ships[Active_Ship.CRUISER_0_MOVES] = 0
	src_sea.active_ships[Active_Ship.BATTLESHIP_BOMBARDED] +=
		src_sea.active_ships[Active_Ship.BATTLESHIP_0_MOVES]
	src_sea.active_ships[Active_Ship.BATTLESHIP_0_MOVES] = 0
	src_sea.active_ships[Active_Ship.BS_DAMAGED_BOMBARDED] +=
		src_sea.active_ships[Active_Ship.BS_DAMAGED_0_MOVES]
	src_sea.active_ships[Active_Ship.BS_DAMAGED_0_MOVES] = 0
}

non_dest_non_sub_exist :: proc(gc: ^Game_Cache, src_sea: ^Sea) -> bool {
	player_idx := gc.cur_player.index
	return(
		src_sea.active_ships[Active_Ship.CARRIER_0_MOVES] > 0 ||
		src_sea.idle_ships[player_idx][Idle_Ship.CRUISER] > 0 ||
		src_sea.idle_ships[player_idx][Idle_Ship.BATTLESHIP] > 0 ||
		src_sea.idle_ships[player_idx][Idle_Ship.BS_DAMAGED] > 0 ||
		src_sea.idle_planes[player_idx][Idle_Plane.BOMBER] > 0 ||
		allied_fighters_exist(gc, src_sea) \
	)
}

build_sea_retreat_options :: proc(gc: ^Game_Cache, src_sea: ^Sea) {
	// ensure no enemy fighters exist
	if src_sea.enemy_blockade_total == 0 &&
		   src_sea.team_units[gc.cur_player.team.enemy_team.index] ==
			   src_sea.enemy_submarines_total ||
	   src_sea.active_ships[Active_Ship.SUB_0_MOVES] > 0 ||
	   src_sea.active_ships[Active_Ship.DESTROYER_0_MOVES] > 0 ||
	   non_dest_non_sub_exist(gc, src_sea) {
		// I am allowed to stay because I have combat units or no enemy blockade remains
		// otherwise I am possibly wasting transports
		sa.push(&gc.valid_moves, src_sea.territory_index)
	}
	for dst_sea in sa.slice(&src_sea.canal_paths[gc.canal_state].adjacent_seas) {
		// todo only allow retreat to valid territories where attack originated
		if dst_sea.enemy_blockade_total == 0 && dst_sea.combat_status == .NO_COMBAT {
			sa.push(&gc.valid_moves, dst_sea.territory_index)
		}
	}
}

sea_retreat :: proc(gc: ^Game_Cache, src_sea: ^Sea, dst_air_idx: int) {
	dst_sea := &gc.seas[dst_air_idx - len(gc.lands)]
	player_idx := gc.cur_player.index
	team_idx := gc.cur_player.team.index
	for active_ship in Retreatable_Ships {
		number_of_ships := src_sea.active_ships[active_ship]
		dst_sea.active_ships[Ships_After_Retreat[active_ship]] += number_of_ships
		dst_sea.idle_ships[player_idx][Active_Ship_To_Idle[active_ship]] += number_of_ships
		dst_sea.team_units[team_idx] += number_of_ships
		src_sea.active_ships[active_ship] = 0
		src_sea.idle_ships[player_idx][Active_Ship_To_Idle[active_ship]] = 0
		src_sea.team_units[team_idx] -= number_of_ships
	}
	src_sea.combat_status = .NO_COMBAT
}

do_sea_targets_exist :: proc(gc: ^Game_Cache, src_sea: ^Sea) -> bool {
	enemy_team_idx := gc.cur_player.team.enemy_team.index
	if src_sea.active_ships[Active_Ship.DESTROYER_0_MOVES] > 0 {
		return src_sea.team_units[enemy_team_idx] > 0
	} else if non_dest_non_sub_exist(gc, src_sea) {
		return src_sea.team_units[enemy_team_idx] > src_sea.enemy_submarines_total
	} else if get_allied_subs_count(gc, src_sea) > 0 {
		return(
			src_sea.team_units[enemy_team_idx] >
			src_sea.enemy_submarines_total + src_sea.enemy_fighters_total \
		)
	}
	return false
}

destroy_vulnerable_transports :: proc(gc: ^Game_Cache, src_sea: ^Sea) {
	// Perhaps it may be possible to have enemy fighters and friendly subs here?
	player_idx := gc.cur_player.index
	if src_sea.team_units[gc.cur_player.team.enemy_team.index] >
	   src_sea.enemy_submarines_total {
		// I dont think this is reachable
		fmt.eprintln("destroy_vulnerable_transports: unreachable code")
		src_sea.team_units[gc.cur_player.team.index] -=
			src_sea.active_ships[Active_Ship.TRANS_EMPTY_0_MOVES]
		src_sea.idle_ships[player_idx][Idle_Ship.TRANS_EMPTY] = 0
		src_sea.active_ships[Active_Ship.TRANS_EMPTY_0_MOVES] = 0

		src_sea.team_units[gc.cur_player.team.index] -=
			src_sea.active_ships[Active_Ship.TRANS_1I_0_MOVES]
		src_sea.idle_ships[player_idx][Idle_Ship.TRANS_1I] = 0
		src_sea.active_ships[Active_Ship.TRANS_1I_0_MOVES] = 0

		src_sea.team_units[gc.cur_player.team.index] -=
			src_sea.active_ships[Active_Ship.TRANS_1A_0_MOVES]
		src_sea.idle_ships[player_idx][Idle_Ship.TRANS_1A] = 0
		src_sea.active_ships[Active_Ship.TRANS_1A_0_MOVES] = 0

		src_sea.team_units[gc.cur_player.team.index] -=
			src_sea.active_ships[Active_Ship.TRANS_1T_0_MOVES]
		src_sea.idle_ships[player_idx][Idle_Ship.TRANS_1T] = 0
		src_sea.active_ships[Active_Ship.TRANS_1T_0_MOVES] = 0

		src_sea.team_units[gc.cur_player.team.index] -=
			src_sea.active_ships[Active_Ship.TRANS_1I_1A_0_MOVES]
		src_sea.idle_ships[player_idx][Idle_Ship.TRANS_1I_1A] = 0
		src_sea.active_ships[Active_Ship.TRANS_1I_1A_0_MOVES] = 0

		src_sea.team_units[gc.cur_player.team.index] -=
			src_sea.active_ships[Active_Ship.TRANS_1I_1T_0_MOVES]
		src_sea.idle_ships[player_idx][Idle_Ship.TRANS_1I_1T] = 0
		src_sea.active_ships[Active_Ship.TRANS_1I_1T_0_MOVES] = 0
	}
}

destroy_defender_transports :: proc(gc: ^Game_Cache, src_sea: ^Sea) {
	if do_sea_targets_exist(gc, src_sea) {
		enemy_team_idx := gc.cur_player.team.enemy_team.index
		for enemy_player in sa.slice(&gc.cur_player.team.enemy_team.players) {
			enemy_player_idx := enemy_player.index
			src_sea.team_units[enemy_team_idx] -=
				src_sea.idle_ships[enemy_player_idx][Idle_Ship.TRANS_EMPTY]
			src_sea.idle_ships[enemy_player_idx][Idle_Ship.TRANS_EMPTY] = 0

			src_sea.team_units[enemy_team_idx] -=
				src_sea.idle_ships[enemy_player_idx][Idle_Ship.TRANS_1I]
			src_sea.idle_ships[enemy_player_idx][Idle_Ship.TRANS_1I] = 0

			src_sea.team_units[enemy_team_idx] -=
				src_sea.idle_ships[enemy_player_idx][Idle_Ship.TRANS_1A]
			src_sea.idle_ships[enemy_player_idx][Idle_Ship.TRANS_1A] = 0

			src_sea.team_units[enemy_team_idx] -=
				src_sea.idle_ships[enemy_player_idx][Idle_Ship.TRANS_1T]
			src_sea.idle_ships[enemy_player_idx][Idle_Ship.TRANS_1T] = 0

			src_sea.team_units[enemy_team_idx] -=
				src_sea.idle_ships[enemy_player_idx][Idle_Ship.TRANS_1I_1A]
			src_sea.idle_ships[enemy_player_idx][Idle_Ship.TRANS_1I_1A] = 0

			src_sea.team_units[enemy_team_idx] -=
				src_sea.idle_ships[enemy_player_idx][Idle_Ship.TRANS_1I_1T]
			src_sea.idle_ships[enemy_player_idx][Idle_Ship.TRANS_1I_1T] = 0
		}
	}
}
DICE_SIDES :: 6
get_attacker_hits :: proc(gc: ^Game_Cache, attacker_damage: int) -> (attacker_hits: int) {
	attacker_hits = attacker_damage / DICE_SIDES
	// todo why does this check for 2 answers remaining?
	if gc.answers_remaining <= 1 {
		if gc.cur_player.team != gc.unlucky_player.team { 	// attacker is lucky
			attacker_hits += 0 < attacker_damage % DICE_SIDES ? 1 : 0 // no dice, round up
		}
	} else {
		attacker_hits +=
			RANDOM_NUMBERS[gc.seed] % DICE_SIDES < attacker_damage % DICE_SIDES ? 1 : 0
		gc.seed += 1
	}
	return
}

get_defender_hits :: proc(gc: ^Game_Cache, defender_damage: int) -> (defender_hits: int) {
	defender_hits = defender_damage / DICE_SIDES
	if gc.answers_remaining <= 1 {
		if gc.cur_player.team == gc.unlucky_player.team { 	// attacker is unlucky
			defender_hits += 0 < defender_damage % DICE_SIDES ? 1 : 0 // no dice, round up
		}
	} else {
		defender_hits +=
			RANDOM_NUMBERS[gc.seed] % DICE_SIDES < defender_damage % DICE_SIDES ? 1 : 0
		gc.seed += 1
	}
	return
}

resolve_sea_battles :: proc(gc: ^Game_Cache) -> (ok: bool) {
	for &src_sea in gc.seas {
		if src_sea.combat_status == .NO_COMBAT do continue
		//if src_sea.team_units[gc.cur_player.team.index] == 0 ||
		if no_defender_threat_exists(gc, &src_sea) {
			destroy_defender_transports(gc, &src_sea)
			src_sea.combat_status = .NO_COMBAT
			break
		}
		disable_bombardment(gc, &src_sea)
		sa.resize(&gc.valid_moves, 0)
		for {
			if src_sea.combat_status == .MID_COMBAT {
				build_sea_retreat_options(gc, &src_sea)
				dst_air_idx := get_retreat_input(gc, &src_sea) or_return
				if (dst_air_idx != src_sea.territory_index) {
					sea_retreat(gc, &src_sea, dst_air_idx)
					break
				}
			}
			src_sea.combat_status = .MID_COMBAT
			if (!do_sea_targets_exist(gc, &src_sea)) {
				destroy_vulnerable_transports(gc, &src_sea)
				src_sea.combat_status = .NO_COMBAT
				break
			}
			attacker_hits := get_attacker_hits(
				gc,
				get_allied_subs_count(gc, &src_sea) * SUB_ATTACK,
			)
			// subs only return fire if they can't submerge
			if do_allied_destroyers_exist(gc, &src_sea) {
				remove_sea_attackers(
					gc,
					&src_sea,
					get_defender_hits(gc, src_sea.enemy_submarines_total * SUB_DEFENSE),
				)
			}
			remove_sea_defenders(gc, &src_sea, attacker_hits)
			attacker_hits = get_attacker_hits(gc, get_attacker_ship_damage(gc, &src_sea))
			remove_sea_attackers(
				gc,
				&src_sea,
				get_defender_hits(gc, get_defender_ship_damage(gc, &src_sea)),
			)
			remove_sea_defenders(gc, &src_sea, attacker_hits)
			// can't retreat if no allied units exist
			if src_sea.team_units[gc.cur_player.team.index] == 0 {
				src_sea.combat_status = .NO_COMBAT
				break
			}
			// don't offer retreat if no defender threat exists
			if no_defender_threat_exists(gc, &src_sea) {
				destroy_defender_transports(gc, &src_sea)
				src_sea.combat_status = .NO_COMBAT
				break
			}
		}
	}
	return false
}

check_for_enemy :: proc(gc: ^Game_Cache, dst_air_idx: int) -> bool {
	dst_air := gc.territories[dst_air_idx]
	if dst_air.team_units[gc.cur_player.team.enemy_team.index] == 0 do return false
	dst_air.combat_status = .PRE_COMBAT
	return true
}

check_for_conquer :: proc(gc: ^Game_Cache, dst_land: ^Land) -> bool {
	if gc.cur_player.team.is_allied[dst_land.owner.index] do return false
	conquer_land(gc, dst_land)
	return true
}

resolve_land_battles :: proc(gc: ^Game_Cache) -> (ok: bool) {
	return false
}
buy_units :: proc(gc: ^Game_Cache) -> (ok: bool) {
	return false
}
reset_units_fully :: proc(gc: ^Game_Cache) -> (ok: bool) {
	return false
}
buy_factory :: proc(gc: ^Game_Cache) -> (ok: bool) {
	return false
}
collect_money :: proc(gc: ^Game_Cache) -> (ok: bool) {
	return false
}
rotate_turns :: proc(gc: ^Game_Cache) -> (ok: bool) {
	return false
}
remove_sea_attackers :: proc(gc: ^Game_Cache, src_sea: ^Sea, hits: int) -> (ok: bool) {
	return false
}
remove_sea_defenders :: proc(gc: ^Game_Cache, src_sea: ^Sea, hits: int) -> (ok: bool) {
	return false
}
get_attacker_ship_damage :: proc(gc: ^Game_Cache, src_sea: ^Sea) -> (damage: int) {
	return 0
}
get_defender_ship_damage :: proc(gc: ^Game_Cache, src_sea: ^Sea) -> (damage: int) {
	return 0
}
