package oaaa
import "core:slice"
when NDEBUG {
  debug_checks :: proc(state: ^GameState) {
      // No-op
  }
} else {
  debug_checks :: proc(state: ^GameState) {
      // Add your debug checks here
  }
}

play_full_turn:: proc(gc: ^Game_Cache) -> (ok: bool) {
  move_air_units(&gc)
  // stage_transport_units(state)
  // move_land_unit_type(state, TANKS)
  // move_land_unit_type(state, ARTILLERY)
  // move_land_unit_type(state, INFANTRY)
  // move_subs_battleships(state)
  // resolve_sea_battles(state)
  // unload_transports(state)
  // resolve_land_battles(state)
  // move_land_unit_type(state, AAGUNS)
  // land_fighter_units(state)
  // land_bomber_units(state)
  // buy_units(state)
  // crash_air_units(state)
  // reset_units_fully(state)
  // buy_factory(state)
  // collect_money(state)
  // rotate_turns(state)
}

move_air_units:: proc(gc: ^Game_Cache) -> (ok: bool) {
  debug_checks(state)
  units_to_process:bool = false
  for src_air in gc.territories {
    unmoved_air_units := &src_air.active_air_units[FIGHTERS_AIR_UNMOVED] 
    if (unmoved_air_units == 0) {
      continue
    }
    if (!units_to_process) {
      units_to_process = true
      refresh_can_planes_land_here(&gc, air_unit_type)
    }
    gc.valid_moves.resize(1)
    gc.valid_moves[0] = src_air.territory_index
    add_valid_air_moves(state, src_air, air_unit_type)
    for unmoved_air_units > 0 {
      dst_air:uint = valid_moves[0];
      if (valid_moves.len > 1) {
        if (answers_remaining == 0){
          return true;
        }
        dst_air = get_user_move_input(state, air_unit_type, src_air);
      }
      if (unit_type == FIGHTERS_AIR) { // todo bombers
        update_move_history_4air(state, src_air, dst_air);
      }
      if (src_air == dst_air) {
        // this is a rare case where an enemy ship is purchased under a unit
        if (unit_type == FIGHTERS_AIR && team_units_count_enemy.at(dst_air) > 0) {
          combat_status[dst_air] = Combat_Status::PRE_COMBAT
          continue;
        }
        air_units.at(0) += unmoved_air_units;
        unmoved_air_units = 0;
        break;
      }
      uint airDistance = AIR_DIST[src_air][dst_air];
      if (team_units_count_enemy.at(dst_air) > 0 ||
          (unit_type == BOMBERS_AIR && factory_dmg[dst_air] < factory_max[dst_air] * 2 &&
            !canBomberLandHere[dst_air])) {
        combat_status[dst_air] = CombatStatus::PRE_COMBAT;
      } else {
        airDistance = max_move_air;
      }
      get_active_air_units(state, dst_air, air_unit_type).at(max_move_air - airDistance)++;
      get_idle_air_units(state, player_idx, dst_air, air_unit_type)++;
      total_player_units_player.at(dst_air)++;
      team_units_count_team.at(dst_air)++;
      unmoved_air_units--;
      get_idle_air_units(state, player_idx, src_air, air_unit_type)--;
      total_player_units_player.at(src_air)--;
      team_units_count_team.at(src_air)--;
    }
  }
  if (units_to_process) {
    clear_move_history(state);
  }
  
  return false;
}
refresh_can_planes_land_here::proc(gc: ^Game_Cache, unit_type: Active_Air_Unit_Type) {
  if unit_type in Is_Fighter {
    refresh_can_fighters_land_here(&gc);
  } else {
    refresh_can_bombers_land_here(&gc);
  }
}

fighter_can_land_here::proc(territory: ^Territory) {
  territory.can_fighter_land_here = true
  for air in territory.adjacent_airs {
    air.can_fighter_land_in_1_move = true
  }
}

refresh_can_fighters_land_here::proc(gc: ^Game_Cache) {
  // initialize all to false
  for territory in gc.territories {
    territory.can_fighter_land_here = false
    territory.can_fighter_land_in_1_move = false
  }
  for land in gc.lands {
    // is allied owned and not recently conquered?
    if gc.current_turn.team == land.owner.team && land.combat_status == CombatStatus.NO_COMBAT {
      fighter_can_land_here(land)
    }
    // check for possiblity to build carrier under fighter
    if (land.owner == gc.current_turn && land.factory_max_damage > 0) {
      for sea in sa.slice(&land.adjacent_seas) {
        fighter_can_land_here(sea)
      }
    }
  }
  for sea in gc.seas {
    if sea.allied_carriers > 0 {
      fighter_can_land_here(sea)
    }
    // if player owns a carrier, then landing area is 2 spaces away
    if sea.active_sea_units[Active_Sea_Unit_Type.CARRIERS_UNMOVED] > 0 {
      for adj_sea in sa.slice(&sea.adjacent_seas) {
        fighter_can_land_here(adj_sea)
      }
      for sea_2_moves_away in sa.slice(&sea.seas_2_moves_away) {
        fighter_can_land_here(sea_2_moves_away)
      }
    }
  }
}

bomber_can_land_here::proc(territory: ^Territory) {
  territory.can_bomber_land_here = true
  for air in territory.adjacent_airs {
    air.can_bomber_land_in_1_move = true
  }
  for air in territory.airs_2_moves_away {
    air.can_bomber_land_in_2_moves = true
  }
}

refresh_can_bombers_land_here::proc(gc: ^Game_Cache) {
  // initialize all to false
  for territory in gc.territories {
    territory.can_bomber_land_here = false
    territory.can_bomber_land_in_1_move = false
    territory.can_bomber_land_in_2_moves = false
  }
  // check if any bombers have full moves remaining
  for land in gc.lands {
    // is allied owned and not recently conquered?
    if gc.current_turn.team == land.owner.team && land.combat_status == CombatStatus.NO_COMBAT {
      bomber_can_land_here(land)
    }
  }
}

add_valid_air_moves::proc(gc: ^Game_Cache, src_air:^Territory, unit_type:AirUnitTypeEnum) {
  if unit_type in Is_Fighter {
    add_valid_fighter_moves(state, src_air);
  } else {
    add_valid_bomber_moves(state, src_air);
  }
}