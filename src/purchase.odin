package oaaa
import sa "core:container/small_array"

Buy_Action :: enum {
	SKIP_BUY,
	BUY_INF,
	BUY_ARTY,
	BUY_TANK,
	BUY_AAGUN,
	BUY_FACTORY,
	BUY_FIGHTER,
	BUY_BOMBER,
	BUY_TRANS,
	BUY_SUB,
	BUY_DESTROYER,
	BUY_CARRIER,
	BUY_CRUISER,
	BUY_BATTLESHIP,
}

Valid_Sea_Buys := [?]Buy_Action {
	.BUY_TRANS,
	.BUY_SUB,
	.BUY_DESTROYER,
	.BUY_CARRIER,
	.BUY_CRUISER,
	.BUY_BATTLESHIP,
}

Buy_Active_Ship := [?]Active_Ship {
	Buy_Action.BUY_TRANS      = .TRANS_EMPTY_0_MOVES,
	Buy_Action.BUY_SUB        = .SUB_0_MOVES,
	Buy_Action.BUY_DESTROYER  = .DESTROYER_0_MOVES,
	Buy_Action.BUY_CARRIER    = .CARRIER_0_MOVES,
	Buy_Action.BUY_CRUISER    = .CRUISER_0_MOVES,
	Buy_Action.BUY_BATTLESHIP = .BATTLESHIP_0_MOVES,
}

Cost_Buy := [?]int {
	Buy_Action.SKIP_BUY       = 0,
	Buy_Action.BUY_INF        = 3,
	Buy_Action.BUY_ARTY       = 4,
	Buy_Action.BUY_TANK       = 6,
	Buy_Action.BUY_AAGUN      = 5,
	Buy_Action.BUY_FIGHTER    = 10,
	Buy_Action.BUY_BOMBER     = 12,
	Buy_Action.BUY_TRANS      = 7,
	Buy_Action.BUY_SUB        = 6,
	Buy_Action.BUY_DESTROYER  = 8,
	Buy_Action.BUY_CARRIER    = 14,
	Buy_Action.BUY_CRUISER    = 12,
	Buy_Action.BUY_BATTLESHIP = 20,
}

Buy_Names := [?]string {
	Buy_Action.SKIP_BUY       = "SKIP_BUY",
	Buy_Action.BUY_INF        = "BUY_INF",
	Buy_Action.BUY_ARTY       = "BUY_ARTY",
	Buy_Action.BUY_TANK       = "BUY_TANK",
	Buy_Action.BUY_AAGUN      = "BUY_AAGUN",
	Buy_Action.BUY_FIGHTER    = "BUY_FIGHTER",
	Buy_Action.BUY_BOMBER     = "BUY_BOMBER",
	Buy_Action.BUY_TRANS      = "BUY_TRANS",
	Buy_Action.BUY_SUB        = "BUY_SUB",
	Buy_Action.BUY_DESTROYER  = "BUY_DESTROYER",
	Buy_Action.BUY_CARRIER    = "BUY_CARRIER",
	Buy_Action.BUY_CRUISER    = "BUY_CRUISER",
	Buy_Action.BUY_BATTLESHIP = "BUY_BATTLESHIP",
}

get_buy_input :: proc(gc: ^Game_Cache, src_air: ^Territory) -> (action: Buy_Action, ok: bool) {
	action = Buy_Action(gc.valid_moves.data[0])
	if gc.valid_moves.len > 1 {
		if gc.answers_remaining == 0 do return .SKIP_BUY, false
		if PLAYER_DATA[gc.cur_player.index].is_human {
			fmt.println("Buy From ", src_air.name, " Valid Buys: ")
			for buy_action in sa.slice(&gc.valid_moves) {
				fmt.print(buy_to_action_idx(Buy_Action(buy_action)), Buy_Names[buy_action], ", ")
			}
			action = Buy_Action(get_user_input(gc))
		}
		action = Buy_Action(get_ai_input(gc))
	}
  update_buy_history(gc, src_air, action)
	return action, true
}

update_buy_history :: proc(gc: ^Game_Cache, src_air: ^Territory, action: Buy_Action) {
  //todo
}

buy_to_action_idx :: proc(action: Buy_Action) -> int {
	return int(action) + TERRITORIES_COUNT
}

buy_units :: proc(gc: ^Game_Cache) -> (ok: bool) {
	gc.valid_moves.data[0] = buy_to_action_idx(.SKIP_BUY)
	for land in sa.slice(&gc.cur_player.factory_locations) {
		if land.builds_left == 0 do continue
		repair_cost := 0
		// buy sea units
		for dst_sea in sa.slice(&land.adjacent_seas) {
			for (land.builds_left > 0) {
				if gc.cur_player.money < MIN_SHIP_COST do break
				//units_built := land.factory_prod - land.builds_left
				repair_cost = max(0, 1 + land.factory_dmg - land.builds_left)
				gc.valid_moves.len = 1
				if gc.cur_player.money >= Cost_Buy[Buy_Action.BUY_FIGHTER] + repair_cost &&
				   is_carrier_available(gc, dst_sea) {
					add_buy_if_not_skipped(gc, dst_sea, Buy_Action.BUY_FIGHTER)
				}
				for buy_ship in Valid_Sea_Buys {
					if gc.cur_player.money < Cost_Buy[buy_ship] + repair_cost do continue
					add_buy_if_not_skipped(gc, dst_sea, buy_ship)
				}
				action := get_buy_input(gc, dst_sea) or_return
			}
		}
	}
	return true
}
// 				if (unit_type == FIGHTERS) {
// 					uint total_fighters = 0;
// 					for (uint player_idx = 0; player_idx < PLAYERS_COUNT; player_idx++) {
// 						total_fighters += total_player_sea_unit_types[player_idx][dst_sea][FIGHTERS];
// 					}
// 					if (allied_carriers[dst_sea] * 2 <= total_fighters) {
// 						continue;
// 					}
// 				}
// 				valid_moves[valid_moves_count++] = unit_type;
// 			}
// 			if (valid_moves_count == 1) {
// 				state.builds_left.at(dst_air) = 0;
// 				break;
// 			}
// 			if (answers_remaining == 0) {
// 				return true;
// 			}
// 			units_to_process = true;
// 			uint purchase = get_user_purchase_input(dst_air);
// 			if (purchase == SEA_UNIT_TYPES_COUNT) { // pass all units
// 				state.builds_left[dst_air] = 0;
// 				break;
// 			}
// 			for (uint sea_idx2 = sea_idx; sea_idx2 < LAND_TO_SEA_COUNT[dst_land]; sea_idx2++) {
// 				state.builds_left.at(LAND_TO_SEA_CONN[dst_land][sea_idx2] + LANDS_COUNT)--;
// 			}
// 			state.builds_left.at(dst_land)--;
// 			*factory_dmg[dst_land] -= repair_cost;
// 			state.money[0] -= COST_UNIT_SEA[purchase] + repair_cost;
// 			sea_units_state[dst_sea][purchase][0]++;
// 			total_player_sea_units[0][dst_sea]++;
// 			current_player_sea_unit_types[dst_sea][purchase]++;
// 			if (purchase > last_purchased) {
// 				for (uint unit_type2 = last_purchased; unit_type2 < purchase; unit_type2++) {
// 					state.skipped_moves[0][unit_type2].bit = true;
// 				}

// 				last_purchased = purchase;
// 			}
// 		}
// 		if (units_to_process) {
// 			clear_move_history();
// 		}
// 	}
// 	// buy land units
// 	valid_moves[0] = LAND_UNIT_TYPES_COUNT; // pass all units
// 	uint last_purchased = 0;
// 	units_to_process = false;
// 	while (state.builds_left.at(dst_land) > 0) {
// 		if (state.money[0] < INFANTRY_COST) {
// 			state.builds_left.at(dst_land) = 0;
// 			break;
// 		}
// 		uint units_built = *factory_max[dst_land] - state.builds_left.at(dst_land);
// 		if (*factory_max[dst_land] < 1 + units_built + *factory_dmg[dst_land]) {
// 			repair_cost = 1 + units_built + *factory_dmg[dst_land] - *factory_max[dst_land];
// 		}
// 		// add all units that can be bought
// 		valid_moves_count = 1;
// 		for (uint unit_type1 = 0; unit_type1 <= LAND_UNIT_TYPES_COUNT - 1; unit_type1++) {
// 			uint unit_type = LAND_UNIT_TYPES_COUNT - 1 - unit_type1;
// 			// if (unit_type < last_purchased)
// 			//   break;
// 			if (state.skipped_moves[0][unit_type].bit) {
// 				last_purchased = unit_type;
// 				break;
// 			}
// 			if (state.money[0] < COST_UNIT_LAND[unit_type] + repair_cost) {
// 				continue;
// 			}
// 			valid_moves[valid_moves_count++] = unit_type;
// 		}
// 		if (valid_moves_count == 1) {
// 			state.builds_left.at(dst_land) = 0;
// 			break;
// 		}
// 		if (answers_remaining == 0) {
// 			return true;
// 		}
// 		units_to_process = true;
// 		uint purchase = get_user_purchase_input(dst_land);
// 		if (purchase == LAND_UNIT_TYPES_COUNT) { // pass all units
// 			state.builds_left.at(dst_land) = 0;
// 			break;
// 		}
// 		state.builds_left.at(dst_land)--;
// 		*factory_dmg[dst_land] -= repair_cost;
// 		state.money[0] -= COST_UNIT_LAND[purchase] + repair_cost;
// 		land_units_state[dst_land][purchase][0]++;
// 		total_player_land_units[0][dst_land]++;
// 		total_player_land_unit_types[0][dst_land][purchase]++;
// 		if (purchase > last_purchased) {
// 			for (uint unit_type2 = last_purchased; unit_type2 < purchase; unit_type2++) {
// 				state.skipped_moves[0][unit_type2].bit = true;
// 			}
// 		}
// 		last_purchased = purchase;
// 	}
// 	if (units_to_process) {
// 		clear_move_history();
// 	}
// }
// return false;
