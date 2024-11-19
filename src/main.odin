package main

import "core:fmt"
import "core:os"
import "core:strconv"

main :: proc() {
	fmt.println("Starting CAAA")
	iterations := 1000000000
	if len(os.args) > 1 {
		iterations = strconv.parse_int(os.args[1]) or_else iterations
	}
	fmt.println("Running ", iterations, " iterations")
    initialize_random_numbers();
    // GameState game_state;
    // load_game_data("game_data.json", game_state);
    // initialize_map_constants();
    // MCTSNode* root = mcts_search(game_state, iterations);
    // uint best_action = select_best_action(root);
    // print_mcts(root);
    // fmt.println("Best action: ", best_action);
}
