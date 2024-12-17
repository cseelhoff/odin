package oaaa
import sa "core:container/small_array"
import "core:mem"
import "core:slice"

stage_transport_units::proc(gc: ^Game_Cache) -> (ok: bool) {
  debug_checks(gc);
  //for (uint unit_type = TRANSEMPTY; unit_type <= TRANS2I; unit_type++) {
  unit_type := Active_Sea_Unit_Type.TRANS_EMPTY_UNMOVED
    refresh_occured := false
    for src_sea in gc.seas {
      // std::vector<uint>& sea_units = active_transports->at(src_sea);
      // uint& unmoved_sea_units = sea_units.at(staging_state);
      if (src_sea.active_sea_units[unit_type] == 0) {
        continue
      }
      refresh_occured = true;
      // const uint src_air = src_sea + LANDS_COUNT;
      valid_moves.assign(1, src_air);
      add_valid_sea_moves(state, src_sea, 2);
      const SeaArray& sea_dist_src_sea = sea_dist[src_sea];
      while (unmoved_sea_units > 0) {
        uint dst_air = valid_moves[0];
        if (valid_moves.size() > 1) {
          if (answers_remaining == 0) {
            return true;
          }
          dst_air = get_user_move_input(state, unit_type, src_air);
        }
        uint sea_distance = sea_dist_src_sea[dst_air];
        // update_move_history(dst_air, src_sea); todo update_move_history_4air
        const uint dst_sea = dst_air - LANDS_COUNT;
        if (enemy_blockade_total[dst_sea] > 0) {
          combat_status[dst_air] = CombatStatus::PRE_COMBAT;
          sea_distance = TRANSPORT_MOVES_MAX;
        }
        if (src_air == dst_air) {
          sea_units.at(done_staging) += unmoved_sea_units;
          unmoved_sea_units = 0;
          break;
        }
        active_transports->at(dst_sea)[staging_state - 1 - sea_distance]++;
        idle_sea_transports[dst_sea]++;
        total_player_units.at(dst_air)++;
        team_units_count_team.at(dst_air)++;
        transports_with_small_cargo_space.at(dst_sea)++;
        unmoved_sea_units--;
        idle_sea_transports[src_sea]--;
        total_player_units.at(src_air)--;
        team_units_count_team.at(src_air)--;
        transports_with_small_cargo_space[src_sea]--;
        if (unit_type <= TRANS1I) {
          transports_with_large_cargo_space[src_sea]--;
          transports_with_large_cargo_space[dst_sea]++;
        }
      }
    }
    if (units_to_process) {
      clear_move_history(state);
    }
    return false;
  }
}
