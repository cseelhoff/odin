package oaaa

import sa "core:container/small_array"

CARRIER_MAX_FIGHTERS :: 2

carry_allied_fighters::proc(gc: ^Game_Cache, src_sea: ^Sea, dst_sea: ^Sea) {
  fighters_remaining := CARRIER_MAX_FIGHTERS
  for player in sa.slice(&gc.cur_player.team.players) {
    if player == gc.cur_player do continue
		fighters_to_move := src_sea.idle_planes[player.index][Idle_Plane.FIGHTER]
    if fighters_to_move == 0 do continue
    fighters_to_move = min(fighters_to_move, fighters_remaining)
    dst_sea.idle_planes[player.index][Idle_Plane.FIGHTER] += fighters_to_move
    src_sea.idle_planes[player.index][Idle_Plane.FIGHTER] -= fighters_to_move
    fighters_remaining -= fighters_to_move
		if fighters_remaining == 0 do break
  }
}