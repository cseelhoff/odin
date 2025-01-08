package oaaa
import sa "core:container/small_array"
import "core:fmt"
import "core:strings"

BUY_ACTIONS_COUNT :: len(Buy_Action)
MAX_VALID_MOVES :: TERRITORIES_COUNT + BUY_ACTIONS_COUNT

Territory_Pointers :: [TERRITORIES_COUNT]^Territory
SA_Territory_Pointers :: sa.Small_Array(TERRITORIES_COUNT, ^Territory)
SA_Land_Pointers :: sa.Small_Array(LANDS_COUNT, ^Land)
SA_Player_Pointers :: sa.Small_Array(PLAYERS_COUNT, ^Player)
CANALS_OPEN :: bit_set[Canal_ID;u8]
UNLUCKY_TEAMS :: bit_set[Team_ID;u8]

Game_Cache :: struct {
	//state:             Game_State,
	teams:                    Teams,
	seas:                     Seas,
	lands:                    Lands,
	players:                  Players,
	territories:              Territory_Pointers,
	valid_moves:              sa.Small_Array(MAX_VALID_MOVES, int),
	unlucky_teams:            UNLUCKY_TEAMS,
	cur_player:               ^Player,
	seed:                     int,
	//canal_state:              int, //array of bools / bit_set is probably best
	canals_open:							CANALS_OPEN, //[CANALS_COUNT]bool,
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
	initialize_player_lands(&gc.lands, &gc.players)
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
	gc.cur_player = &gc.players[gs.cur_player]
	for &player, i in gc.players {
		player.money = gs.money[i]
		player.income_per_turn = 0
	}
	for &land, i in gc.lands {
		land_state := &gs.land_states[i]
		gc.players[land_state.owner].income_per_turn += land.value
		land.owner = &gc.players[land_state.owner]
		land.factory_prod = land_state.factory_prod
		if land.factory_prod > 0 {
			sa.push(&land.owner.factory_locations, &land)
		}
		land.factory_dmg = land_state.factory_dmg
		land.max_bombards = land_state.max_bombards
		land.active_armies = land_state.active_armies
		land.builds_left = land_state.builds_left
		land.idle_armies = land_state.idle_armies
		land.team_units = {}
		for player in gc.players {
			for army in land.idle_armies[player.index] {
				land.team_units[player.team.index] += army
			}
		}
		load_territory_from_state(&land.territory, &land_state.territory_state)
	}
	for &sea, i in gc.seas {
		sea_state := &gs.sea_states[i]
		sea.idle_ships = sea_state.idle_ships
		sea.active_ships = sea_state.active_ships
		load_territory_from_state(&sea.territory, &sea_state.territory_state)
	}
	count_sea_unit_totals(gc)
	load_open_canals(gc)
}

load_territory_from_state :: proc(territory: ^Territory, ts: ^Territory_State) {
	territory.combat_status = ts.combat_status
	//territory.builds_left = ts.builds_left
	territory.skipped_moves = ts.skipped_moves
	territory.active_planes = ts.active_planes
	territory.idle_planes = ts.idle_planes
}

count_sea_unit_totals :: proc(gc: ^Game_Cache) {
	for &sea in gc.seas {
		sea.enemy_fighters_total = 0
		sea.enemy_submarines_total = 0
		sea.enemy_destroyer_total = 0
		sea.enemy_blockade_total = 0		
		for enemy in sa.slice(&gc.cur_player.team.enemy_players) {
			sea.enemy_fighters_total += sea.idle_ships[enemy.index][Idle_Plane.FIGHTER]
			sea.enemy_submarines_total += sea.idle_ships[enemy.index][Idle_Ship.SUB]
			sea.enemy_destroyer_total += sea.idle_ships[enemy.index][Idle_Ship.DESTROYER]
			sea.enemy_blockade_total +=
				sea.idle_ships[enemy.index][Idle_Ship.CARRIER] +
				sea.idle_ships[enemy.index][Idle_Ship.CRUISER] +
				sea.idle_ships[enemy.index][Idle_Ship.BATTLESHIP] +
				sea.idle_ships[enemy.index][Idle_Ship.BS_DAMAGED]
		}
		sea.enemy_blockade_total += sea.enemy_destroyer_total
		sea.allied_carriers = 0
		for ally in sa.slice(&gc.cur_player.team.players) {
			sea.allied_carriers += sea.idle_ships[ally.index][Idle_Ship.CARRIER]
		}
	}
}
load_open_canals :: proc (gc: ^Game_Cache) {
	gc.canals_open = {}
	for canal, canal_idx in Canal_Lands {
		if canal[0].owner.team == gc.cur_player.team &&
		   canal[1].owner.team == gc.cur_player.team {
			gc.canals_open += {Canal_ID(canal_idx)}
		}
	}
}