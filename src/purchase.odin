package oaaa
import sa "core:container/small_array"
import "core:fmt"
import "core:mem"


Buy_Action :: enum {
	SKIP_BUY,
	BUY_INF,
	BUY_ARTY,
	BUY_TANK,
	BUY_AAGUN,
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

Valid_Air_Buys := [?]Buy_Action {
	.BUY_FIGHTER,
  .BUY_BOMBER,
}

Valid_Land_Buys := [?]Buy_Action {
	.BUY_INF,
  .BUY_ARTY,
  .BUY_TANK,
  .BUY_AAGUN,
}

Buy_Active_Ship := [?]Active_Ship {
	Buy_Action.BUY_TRANS      = .TRANS_EMPTY_0_MOVES,
	Buy_Action.BUY_SUB        = .SUB_0_MOVES,
	Buy_Action.BUY_DESTROYER  = .DESTROYER_0_MOVES,
	Buy_Action.BUY_CARRIER    = .CARRIER_0_MOVES,
	Buy_Action.BUY_CRUISER    = .CRUISER_0_MOVES,
	Buy_Action.BUY_BATTLESHIP = .BATTLESHIP_0_MOVES,
}

Buy_Active_Plane := [?]Active_Plane {
  Buy_Action.BUY_FIGHTER    = .FIGHTER_0_MOVES,
  Buy_Action.BUY_BOMBER     = .BOMBER_0_MOVES,
}

Buy_Active_Army := [?]Active_Army {
  Buy_Action.BUY_INF        = .INF_0_MOVES,
  Buy_Action.BUY_ARTY       = .ARTY_0_MOVES,
  Buy_Action.BUY_TANK       = .TANK_0_MOVES,
  Buy_Action.BUY_AAGUN      = .AAGUN_0_MOVES,
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

FACTORY_COST :: 15

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

get_factory_buy :: proc(
	gc: ^Game_Cache
) -> (
	action: int,
	ok: bool,
) {
	action = gc.valid_moves.data[0]
	if gc.valid_moves.len > 1 {
		if gc.answers_remaining == 0 do return action, false
		if PLAYER_DATA[gc.cur_player.index].is_human {
			fmt.println("Buying Factory For: ")
			for valid_move in sa.slice(&gc.valid_moves) {
        if valid_move > TERRITORIES_COUNT {
          fmt.print(int(valid_move), "=Skip", ", ")
        } else {
				  fmt.print(int(valid_move), gc.territories[valid_move].name, ", ")
        }
			}
			action = get_user_input(gc)
		}
		action = get_ai_input(gc)
	}
	update_factory_history(gc, action)
	return action, true
}

update_factory_history :: proc (gc: ^Game_Cache, action: int) {
  assert(gc.valid_moves.len > 0)
  valid_action := gc.valid_moves.data[gc.valid_moves.len - 1]
  for {
    if (valid_action == action) do return
    gc.territories[valid_action].skipped_moves[valid_action] = true
    valid_action = sa.pop_back(&gc.valid_moves)
  }
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
	assert(gc.valid_moves.len > 0)
	valid_action := gc.valid_moves.data[gc.valid_moves.len - 1]
	for {
		if (Buy_Action(valid_action) == action) do return
		src_air.skipped_buys[valid_action] = true
		gc.clear_needed = true
		valid_action = sa.pop_back(&gc.valid_moves)
	}
}

buy_to_action_idx :: proc(action: Buy_Action) -> int {
	return int(action) + TERRITORIES_COUNT
}

add_buy_if_not_skipped :: proc(gc: ^Game_Cache, src_air: ^Territory, action: Buy_Action) {
	if !src_air.skipped_buys[int(action)] {
		sa.push(&gc.valid_moves, buy_to_action_idx(action))
	}
}

buy_sea_units :: proc(gc: ^Game_Cache, land: ^Land) -> (ok: bool) {
	for dst_sea in sa.slice(&land.adjacent_seas) {
		for (land.builds_left > 0 && !dst_sea.skipped_buys[Buy_Action.SKIP_BUY]) {
			repair_cost := max(0, 1 + land.factory_dmg - land.builds_left)
			gc.valid_moves.len = 1
			if gc.cur_player.money >= Cost_Buy[Buy_Action.BUY_FIGHTER] + repair_cost &&
      dst_sea.can_fighter_land_here {
				add_buy_if_not_skipped(gc, dst_sea, Buy_Action.BUY_FIGHTER)
			}
			for buy_ship in Valid_Sea_Buys {
				if gc.cur_player.money < Cost_Buy[buy_ship] + repair_cost do continue
				add_buy_if_not_skipped(gc, dst_sea, buy_ship)
			}
			action := get_buy_input(gc, dst_sea) or_return
			if action == .SKIP_BUY {
        dst_sea.skipped_buys[Buy_Action.SKIP_BUY] = true
        break
      }
			land.builds_left -= 1
			land.factory_dmg -= repair_cost
			gc.cur_player.money -= Cost_Buy[action] + repair_cost
			if action == .BUY_FIGHTER {
				dst_sea.active_planes[Active_Plane.FIGHTER_0_MOVES] += 1
				dst_sea.idle_planes[gc.cur_player.index][Idle_Plane.FIGHTER] += 1
        dst_sea.can_fighter_land_here = is_carrier_available(gc, dst_sea)
			} else {
				ship := Buy_Active_Ship[action]
				dst_sea.active_ships[ship] += 1
				dst_sea.idle_ships[gc.cur_player.index][Active_Ship_To_Idle[ship]] += 1
        if ship == .CARRIER_0_MOVES do dst_sea.can_fighter_land_here = true
			}
			dst_sea.team_units[gc.cur_player.team.index] += 1
		}
	}
	return true
}

clear_buy_history :: proc(gc: ^Game_Cache, land: ^Land) {
  for sea in sa.slice(&land.adjacent_seas) {
    mem.zero_slice(sea.skipped_buys[:])
  }
  gc.clear_needed = false
}

buy_land_units :: proc(gc: ^Game_Cache, land: ^Land) -> (ok: bool) {
	for (land.builds_left > 0) {
    repair_cost := max(0, 1 + land.factory_dmg - land.builds_left)
    gc.valid_moves.len = 1
    for buy_plane in Valid_Air_Buys {
      if gc.cur_player.money < Cost_Buy[buy_plane] + repair_cost do continue
      add_buy_if_not_skipped(gc, land, buy_plane)
    }
    for buy_army in Valid_Land_Buys {
      if gc.cur_player.money < Cost_Buy[buy_army] + repair_cost do continue
      add_buy_if_not_skipped(gc, land, buy_army)
    }
    action := get_buy_input(gc, land) or_return
    if action == .SKIP_BUY {
      land.builds_left = 0
      break
    }
    land.builds_left -= 1
    land.factory_dmg -= repair_cost
    gc.cur_player.money -= Cost_Buy[action] + repair_cost
    if action == .BUY_FIGHTER || action == .BUY_BOMBER {
      plane := Buy_Active_Plane[action]
      land.active_planes[plane] += 1
      land.idle_planes[gc.cur_player.index][Active_Plane_To_Idle[plane]] += 1
    } else {
      army := Buy_Active_Army[action]
      land.active_armies[army] += 1
      land.idle_armies[gc.cur_player.index][Active_Army_To_Idle[army]] += 1
    }
    land.team_units[gc.cur_player.team.index] += 1
	}
	return true
}

buy_units :: proc(gc: ^Game_Cache) -> (ok: bool) {
	gc.valid_moves.data[0] = buy_to_action_idx(.SKIP_BUY)
	for land in sa.slice(&gc.cur_player.factory_locations) {
		if land.builds_left == 0 do continue
    if gc.clear_needed do clear_buy_history(gc, land)
		buy_sea_units(gc, land) or_return
		buy_land_units(gc, land) or_return
	}
	return true
}
