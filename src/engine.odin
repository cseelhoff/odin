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
		sea.active_ships[Active_Ship.BATTLESHIP_0_MOVES] += sea.active_ships[Active_Ship.BS_DAMAGED_0_MOVES]
		sea.active_ships[Active_Ship.BATTLESHIP_BOMBARDED] += sea.active_ships[Active_Ship.BS_DAMAGED_BOMBARDED]
		sea.idle_ships[gc.cur_player.index][Idle_Ship.BATTLESHIP] += sea.idle_ships[gc.cur_player.index][Idle_Ship.BS_DAMAGED]
	}
}

collect_money :: proc(gc: ^Game_Cache) {
	if gc.cur_player.captial.owner == gc.cur_player {
		gc.cur_player.money += gc.cur_player.income_per_turn
	}
}

rotate_turns :: proc(gc: ^Game_Cache) {
	// set active army,ship,planes
  // for (uint factory_idx = 0; factory_idx < total_factory_count[0]; factory_idx++) {
  //   uint dst_land = factory_locations[0][factory_idx];
  //   state.builds_left[dst_land] = *factory_max[dst_land];
  //   for (uint sea_idx = 0; sea_idx < LAND_TO_SEA_COUNT[dst_land]; sea_idx++) {
  //     state.builds_left[LAND_TO_SEA_CONN[dst_land][sea_idx] + LANDS_COUNT] +=
  //         *factory_max[dst_land];
  //   }
  // }
	//refresh canals

}
