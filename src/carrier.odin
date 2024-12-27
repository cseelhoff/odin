package oaaa

CARRIER_MAX_FIGHTERS :: 2

move_carriers::proc(gc: ^Game_Cache) {
  debug_checks(gc)
	clear_needed := false
	defer if clear_needed do clear_move_history(gc)
	for src_sea in gc.seas {
		if src_sea.Active_Ships[Active_Ship.CARRIER_UNMOVED] == 0 do continue
		dst_air_idx := reset_valid_moves(gc, &src_air, &clear_needed)
		add_valid_ship_moves(gc, src_sea)
		for src_sea.Active_Ships[Active_Ship.CARRIER_UNMOVED] > 0 {
			get_move_input(gc, CARRIER_UNMOVED_NAME, &src_air, &dst_air_idx) or_return
			dst_sea := gc.seas[dst_sea_idx]
			if !dst_sea.teams_unit_count[gc.current_turn.team.index] > 0 {
				dst_sea.combat_status = .PRE_COMBAT
			}
			if src_sea == dst_sea {
				src_sea.Active_Ships[Active_Ship.CARRIERS_0_MOVES] +=
					src_sea.Active_Ships[Active_Ship.CARRIER_UNMOVED]
				src_sea.Active_Ships[Active_Ship.CARRIER_UNMOVED] = 0
				break
			}
			move_ship(
				dst_sea,
				Active_Ship.CARRIERS_0_MOVES,
				gc.current_turn,
				Active_Ship.CARRIER_UNMOVED,
				src_sea,
			)
      carry_allied_fighters(gc, src_sea, dst_sea)
		}
	}
	return true
}

carry_allied_fighters::proc(gc: ^Game_Cache, src_sea: ^Sea, dst_sea: ^Sea) {
  fighters_remaining := CARRIER_MAX_FIGHTERS
  for player in gc.players {
    if player == gc.current_turn || player.team != gc.current_turn.team do continue
    fighters_to_move := min(src_sea.Idle_Planes[player.index][Idle_Plane.FIGHTER], fighters_remaining)
    if fighters_to_move == 0 do continue
    dst_sea.Idle_Planes[player.index][Idle_Plane.FIGHTER] += fighters_to_move
    src_sea.Idle_Planes[player.index][Idle_Plane.FIGHTER] -= fighters_to_move
    fighters_remaining -= fighters_to_move    
  }
}