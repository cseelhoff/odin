package oaaa
import sa "core:container/small_array"
import "core:fmt"
import "core:strings"

MAX_VALID_MOVES :: 20

Territory_Pointers :: [TERRITORIES_COUNT]^Territory
SA_Territory_Pointers :: sa.Small_Array(TERRITORIES_COUNT, ^Territory)
SA_Land_Pointers :: sa.Small_Array(LANDS_COUNT, ^Land)
SA_Player_Pointers :: sa.Small_Array(PLAYERS_COUNT, ^Player)

Game_Cache :: struct {
	state:             Game_State,
	teams:             Teams,
	seas:              Seas,
	lands:             Lands,
	players:           Players,
	territories:       Territory_Pointers,
	valid_moves:       sa.Small_Array(MAX_VALID_MOVES, int),
	unlucky_player:    ^Player,
	current_turn:      ^Player,
	seed:              uint,
	canal_state:       int,
	step_id:           uint,
	answers_remaining: uint,
	selected_action:   uint,
	max_loops:         uint,
	actually_print:    bool,
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
