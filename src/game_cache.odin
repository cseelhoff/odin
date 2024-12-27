package oaaa
import sa "core:container/small_array"
import "core:fmt"
import "core:strings"

MAX_VALID_MOVES :: 20

Territory_Pointers :: [TERRITORIES_COUNT]^Territory
SA_Territory_Pointers :: sa.Small_Array(TERRITORIES_COUNT, ^Territory)
SA_Land_Pointers :: sa.Small_Array(len(LANDS_DATA), ^Land)
SA_Player_Pointers :: sa.Small_Array(PLAYERS_COUNT, ^Player)

Game_Cache :: struct {
	//state:             Game_State,
	teams:                    Teams,
	seas:                     Seas,
	lands:                    Lands,
	players:                  Players,
	territories:              Territory_Pointers,
	valid_moves:              sa.Small_Array(MAX_VALID_MOVES, int),
	unlucky_player:           ^Player,
	current_turn:             ^Player,
	seed:                     int,
	canal_state:              int,
	step_id:                  int,
	answers_remaining:        int,
	selected_action:          int,
	max_loops:                int,
	user_input:               int,
	actually_print:           bool,
	is_bomber_cache_current:  bool,
	is_fighter_cache_current: bool,
	clear_needed:             bool,
}

initialize_map_constants :: proc(gc: ^Game_Cache) -> (ok: bool) {
	initialize_teams(&gc.teams, &gc.players)
	initialize_territories(&gc.lands, &gc.seas, &gc.territories)
	initialize_land_connections(&gc.lands) or_return
	//initialize_sea_connections(&gc.canal_paths, &gc.seas) or_return
	initialize_sea_connections(&gc.seas) or_return
	initialize_costal_connections(&gc.lands, &gc.seas) or_return
	initialize_canals(&gc.lands) or_return
	initialize_lands_2_moves_away(&gc.lands)
	// initialize_seas_2_moves_away(&gc.seas, &gc.canal_paths)
	initialize_seas_2_moves_away(&gc.seas)
	initialize_air_dist(&gc.lands, &gc.seas, &gc.territories)
	// initialize_land_path()
	// initialize_sea_path()
	// initialize_within_x_moves()
	// intialize_airs_x_to_4_moves_away()
	// initialize_skip_4air_precals()
	return true
}

load_cache_from_state :: proc(gc: ^Game_Cache, gs: ^Game_State) {
	//gc.state = gs
	gc.seed = gs.seed
	gc.current_turn = &gc.players[gs.current_turn]
	for money, i in gs.money {
		gc.players[i].money = money
	}
	for &land, i in gs.land_state {
		gc.lands[i].owner = &gc.players[land.owner]
		gc.lands[i].factory_damage = land.factory_damage
		gc.lands[i].factory_max_damage = land.factory_max_damage
		gc.lands[i].bombard_max_damage = land.bombard_max_damage
		gc.lands[i].idle_armies = land.idle_armies
		gc.lands[i].active_armies = land.active_armies
		load_territory_from_state(&gc.lands[i].territory, &land.territory_state)
	}
	for &sea, i in gs.sea_state {
		gc.seas[i].idle_ships = sea.idle_ships
		gc.seas[i].active_ships = sea.active_ships
		load_territory_from_state(&gc.seas[i].territory, &sea.territory_state)
	}
}

load_territory_from_state :: proc(territory: ^Territory, ts: ^Territory_State) {
	territory.combat_status = ts.combat_status
	territory.builds_left = ts.builds_left
	territory.skipped_moves = ts.skipped_moves
	territory.active_planes = ts.active_planes
	territory.idle_planes = ts.idle_planes
}
