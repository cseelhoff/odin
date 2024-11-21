package main
import "core:mem"
MIN_AIR_HOPS :: 2
MAX_AIR_HOPS :: 6
MIN_SEA_HOPS :: 1
MAX_SEA_HOPS :: 2
MIN_LAND_HOPS :: 1
MAX_LAND_HOPS :: 2
AIR_MOVE_SIZE :: 1 + MAX_AIR_HOPS - MIN_AIR_HOPS
SEA_MOVE_SIZE :: 1 + MAX_SEA_HOPS - MIN_SEA_HOPS
LAND_MOVE_SIZE :: 1 + MAX_LAND_HOPS - MIN_LAND_HOPS
PLAYERS_COUNT_P1 :: PLAYERS_COUNT + 1
AIRS_COUNT :: LANDS_COUNT + SEAS_COUNT
MAX_AIR_TO_AIR_CONNECTIONS :: 7
ACTION_COUNT :: max(AIRS_COUNT, len(SeaUnitTypesEnum) + 1)
MAX_INT:: 1000

initialize_map_constants :: proc(game_cache: ^Game_Cache) {
	initialize_enemies()
	initialize_land_dist(game_cache)
	land_dist_floyd_warshall()
	initialize_sea_dist()
	initialize_air_dist()
	initialize_land_path()
	initialize_sea_path()
	initialize_within_x_moves()
	intialize_airs_x_to_4_moves_away()
	initialize_skip_4air_precals()
}
initialize_enemies :: proc() {
	for &player in PLAYERS {
		player.enemy_team = 1 - player.team
		for other_player, j in PLAYERS {
			if (player.team == other_player.team) {
				player.is_allied[j] = true
				append(&player.allies, j)
			} else {
				append(&player.enemies, j)
			}
		}
	}
}
initialize_land_dist::proc(game_cache: ^Game_Cache) {
    for &land_cache, i in game_cache.land_cache {
        mem.set(&land_cache.land_dist, MAX_INT, sizeof(land_cache.land_dist))
        for &land_connection in land_cache.land_connections {
            land_cache.land_dist[land_connection] = 1
        }
    }
    for (uint src_land = 0; src_land < LANDS_COUNT; src_land++) {
      //LAND_VALUE[src_land] = LANDS[src_land].land_value;
      Land land = LANDS[src_land];
      // initialize LAND_TO_LAND_CONN
      uint land_conn_count = land.land_conn_count;
      LAND_TO_LAND_COUNT[src_land] = land_conn_count;
      COPY_SUB_ARRAY(land.land_conns, LAND_TO_LAND_CONN[src_land], LAND_TO_LAND_COUNT[src_land]);
      // set_l2l_land_dist_to_one
      for (uint conn_idx = 0; conn_idx < land_conn_count; conn_idx++) {
        uint dst_land = land.land_conns[conn_idx];
        LAND_DIST[src_land][dst_land] = 1;
        LAND_DIST[dst_land][src_land] = 1;
      }
      // initialize LAND_TO_SEA_CONN
      uint sea_conn_count = land.sea_conn_count;
      LAND_TO_SEA_COUNT[src_land] = sea_conn_count;
      COPY_SUB_ARRAY(land.sea_conns, LAND_TO_SEA_CONN[src_land], LAND_TO_SEA_COUNT[src_land]);
      LAND_DIST[src_land][src_land] = 0;
      // set_l2s_land_dist_to_one
      for (uint conn_idx = 0; conn_idx < sea_conn_count; conn_idx++) {
        uint dst_air = land.sea_conns[conn_idx] + LANDS_COUNT;
        LAND_DIST[src_land][dst_air] = 1;
      }
    }
  }