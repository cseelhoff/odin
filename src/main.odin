package oaaa

import "core:fmt"
import "core:os"
import "core:strconv"

main :: proc() {
	fmt.println("Starting CAAA")
	iterations := 1_000_000_000
	if len(os.args) > 1 {
		iterations, _ = strconv.parse_int(os.args[1])
	}
	fmt.println("Running ", iterations, " iterations")
	initialize_random_numbers()
	game_cache: Game_Cache
	ok := initialize_map_constants(&game_cache)
	if !ok {
		fmt.eprintln("Error initializing map constants")
		return
	}
	game_state: Game_State
	//save_json(game_state)
	load_game_data("game_state.json", &game_state)
	load_cache_from_state(&game_cache, &game_state)
	
  play_full_turn(&game_cache)
	// MCTSNode* root = mcts_search(game_state, iterations);
	// uint best_action = select_best_action(root);
	// print_mcts(root);
	// fmt.println("Best action: ", best_action);
}
