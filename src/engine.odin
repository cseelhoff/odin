package oaaa
import sa "core:container/small_array"
import "core:fmt"
import "core:mem"
import "core:slice"

when ODIN_DEBUG {
	debug_checks :: proc(gc: ^Game_Cache) {
		// No-op
		// print_game_state(gc)
	}
} else {
	debug_checks :: proc(gc: ^Game_Cache) {
		// Add your debug checks here
	}
}
play_full_turn :: proc(gc: ^Game_Cache) -> (ok: bool) {
	move_unmoved_planes(gc) or_return // move before carriers for more options
	move_combat_ships(gc) or_return
	stage_transports(gc) or_return
	move_armies(gc) or_return
	move_transports(gc) or_return
	resolve_sea_battles(gc) or_return
	unload_transports(gc) or_return
	resolve_land_battles(gc) or_return
	move_aa_guns(gc) or_return
	land_fighter_units(gc) or_return
	land_bomber_units(gc) or_return
	buy_units(gc) or_return
	//crash_air_units(gc) or_return
	buy_factory(gc) or_return
	reset_units_fully(gc)
	collect_money(gc)
	rotate_turns(gc)
	return true
}

add_move_if_not_skipped :: proc(gc: ^Game_Cache, src_air: ^Territory, dst_air: ^Territory) {
	if !src_air.skipped_moves[dst_air.territory_index] {
		sa.push(&gc.valid_moves, int(dst_air.territory_index))
	}
}

update_move_history :: proc(gc: ^Game_Cache, src_air: ^Territory, dst_air_idx: Air_ID) {
	// get a list of newly skipped valid_actions
	assert(gc.valid_moves.len > 0)
	valid_action := gc.valid_moves.data[gc.valid_moves.len - 1]
	for {
		if (Air_ID(valid_action) == dst_air_idx) do return
		src_air.skipped_moves[valid_action] = true
		gc.clear_needed = true
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
	gc.clear_needed = false
}

reset_valid_moves :: proc(gc: ^Game_Cache, territory: ^Territory) { 	// -> (dst_air_idx: int) {
	gc.valid_moves.len = 1
	gc.valid_moves.data[0] = int(territory.territory_index)
}

buy_factory :: proc(gc: ^Game_Cache) -> (ok: bool) {
	if gc.cur_player.money < FACTORY_COST do return true
	gc.valid_moves.len = 1
	gc.valid_moves.data[0] = buy_to_action_idx(.SKIP_BUY)
	for land in gc.lands {
		if land.owner != gc.cur_player ||
		   land.factory_prod > 0 ||
		   land.combat_status != .NO_COMBAT ||
		   land.skipped_moves[land.territory_index] {
			continue
		}
		sa.push(&gc.valid_moves, int(land.territory_index))
	}
	for (gc.cur_player.money < FACTORY_COST) {
		factory_land_idx := get_factory_buy(gc) or_return
		if factory_land_idx == buy_to_action_idx(.SKIP_BUY) do return true
		gc.cur_player.money -= FACTORY_COST
		factory_land := &gc.lands[factory_land_idx]
		factory_land.factory_prod = factory_land.value
		sa.push(&gc.cur_player.factory_locations, factory_land)
	}
	return true
}

reset_units_fully :: proc(gc: ^Game_Cache) {
	for &sea in gc.seas {
		sea.active_ships[Active_Ship.BATTLESHIP_0_MOVES] +=
			sea.active_ships[Active_Ship.BS_DAMAGED_0_MOVES]
		sea.active_ships[Active_Ship.BATTLESHIP_BOMBARDED] +=
			sea.active_ships[Active_Ship.BS_DAMAGED_BOMBARDED]
		sea.idle_ships[gc.cur_player.index][Idle_Ship.BATTLESHIP] +=
			sea.idle_ships[gc.cur_player.index][Idle_Ship.BS_DAMAGED]
	}
}

collect_money :: proc(gc: ^Game_Cache) {
	if gc.cur_player.capital.owner == gc.cur_player {
		gc.cur_player.money += gc.cur_player.income_per_turn
	}
}

rotate_turns :: proc(gc: ^Game_Cache) {
	gc.cur_player = &gc.players[(int(gc.cur_player.index) + 1) % PLAYERS_COUNT]
	gc.clear_needed = false
	for &land in gc.lands {
		if land.owner == gc.cur_player {
			land.builds_left = land.factory_prod
		}
		land.combat_status = .NO_COMBAT
		land.max_bombards = 0
		mem.zero_slice(land.skipped_moves[:])
		mem.zero_slice(land.skipped_buys[:])
		mem.zero_slice(land.active_armies[:])
		idle_armies := &land.idle_armies[gc.cur_player.index]
		land.active_armies[Active_Army.INF_UNMOVED] = idle_armies[Idle_Army.INF]
		land.active_armies[Active_Army.ARTY_UNMOVED] = idle_armies[Idle_Army.ARTY]
		land.active_armies[Active_Army.TANK_UNMOVED] = idle_armies[Idle_Army.TANK]
		land.active_armies[Active_Army.AAGUN_UNMOVED] = idle_armies[Idle_Army.AAGUN]
		mem.zero_slice(land.active_planes[:])
		idle_planes := &land.idle_planes[gc.cur_player.index]
		land.active_planes[Active_Plane.FIGHTER_UNMOVED] = idle_planes[Idle_Plane.FIGHTER]
		land.active_planes[Active_Plane.BOMBER_UNMOVED] = idle_planes[Idle_Plane.BOMBER]
	}
	for &sea in gc.seas {
		sea.combat_status = .NO_COMBAT
		mem.zero_slice(sea.skipped_moves[:])
		mem.zero_slice(sea.skipped_buys[:])
		mem.zero_slice(sea.active_ships[:])
		idle_ships := &sea.idle_ships[gc.cur_player.index]
		sea.active_ships[Active_Ship.TRANS_EMPTY_UNMOVED] = idle_ships[Idle_Ship.TRANS_EMPTY]
		sea.active_ships[Active_Ship.TRANS_1I_UNMOVED] = idle_ships[Idle_Ship.TRANS_1I]
		sea.active_ships[Active_Ship.TRANS_1A_UNMOVED] = idle_ships[Idle_Ship.TRANS_1A]
		sea.active_ships[Active_Ship.TRANS_1T_UNMOVED] = idle_ships[Idle_Ship.TRANS_1T]
		sea.active_ships[Active_Ship.TRANS_2I_2_MOVES] = idle_ships[Idle_Ship.TRANS_2I]
		sea.active_ships[Active_Ship.TRANS_1I_1A_2_MOVES] = idle_ships[Idle_Ship.TRANS_1I_1A]
		sea.active_ships[Active_Ship.TRANS_1I_1T_2_MOVES] = idle_ships[Idle_Ship.TRANS_1I_1T]
		sea.active_ships[Active_Ship.SUB_UNMOVED] = idle_ships[Idle_Ship.SUB]
		sea.active_ships[Active_Ship.DESTROYER_UNMOVED] = idle_ships[Idle_Ship.DESTROYER]
		sea.active_ships[Active_Ship.CARRIER_UNMOVED] = idle_ships[Idle_Ship.CARRIER]
		sea.active_ships[Active_Ship.CRUISER_UNMOVED] = idle_ships[Idle_Ship.CRUISER]
		sea.active_ships[Active_Ship.BATTLESHIP_UNMOVED] = idle_ships[Idle_Ship.BATTLESHIP]
		sea.active_ships[Active_Ship.BS_DAMAGED_UNMOVED] = idle_ships[Idle_Ship.BS_DAMAGED]
		mem.zero_slice(sea.active_planes[:])
		idle_planes := &sea.idle_planes[gc.cur_player.index]
		sea.active_planes[Active_Plane.FIGHTER_UNMOVED] = idle_planes[Idle_Plane.FIGHTER]
		sea.active_planes[Active_Plane.BOMBER_UNMOVED] = idle_planes[Idle_Plane.BOMBER]
	}
	count_sea_unit_totals(gc)
	load_open_canals(gc)
}
