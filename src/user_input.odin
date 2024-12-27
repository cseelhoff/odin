package oaaa
import sa "core:container/small_array"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"

// get_move_input :: proc(
// 	gc: ^Game_Cache,
// 	unit_name: string,
// 	src_air: ^Territory,
// ) -> (
// 	dst_air_idx: int,
// ) {
// 	if (PLAYER_DATA[gc.current_turn.index].is_human) {
// 		fmt.print("Moving ", unit_name, " From ", src_air.name, " Valid Moves: ")
// 		for valid_move in sa.slice(&gc.valid_moves) {
// 			fmt.print(gc.territories[valid_move].name, ", ")
// 		}
// 		return get_user_input(gc)
// 	}
// 	return get_ai_input(gc)
// }

get_retreat_input :: proc(gc: ^Game_Cache, src_air: ^Territory) -> (dst_air_idx: int, ok: bool) {
	if gc.valid_moves.len > 1 {
		if gc.answers_remaining == 0 do return dst_air_idx, false
		if PLAYER_DATA[gc.current_turn.index].is_human {
			fmt.print("Retreat From ", src_air.name, " Valid Moves: ")
			for valid_move in sa.slice(&gc.valid_moves) {
				fmt.print(gc.territories[valid_move].name, ", ")
			}
			dst_air_idx = get_user_input(gc)
		}
		dst_air_idx = get_ai_input(gc)
	}
	return dst_air_idx, true
}

get_move_input :: proc(
	gc: ^Game_Cache,
	unit_name: string,
	src_air: ^Territory,
) -> (
	dst_air_idx: int,
	ok: bool,
) {
	if gc.valid_moves.len > 1 {
		if gc.answers_remaining == 0 do return dst_air_idx, false
		if PLAYER_DATA[gc.current_turn.index].is_human {
			fmt.print("Moving ", unit_name, " From ", src_air.name, " Valid Moves: ")
			for valid_move in sa.slice(&gc.valid_moves) {
				fmt.print(gc.territories[valid_move].name, ", ")
			}
			dst_air_idx = get_user_input(gc)
		}
		dst_air_idx = get_ai_input(gc)
	}
	update_move_history(gc, src_air, dst_air_idx)
	return dst_air_idx, true
}

get_user_input :: proc(gc: ^Game_Cache) -> (user_input: int = 0) {
	buffer: [256]byte
	fmt.print("Enter a number between 0 and 255: ")
	n, err := os.read(os.stdin, buffer[:])
	if err != 0 {
		return
	}
	input_str := string(buffer[:n])
	int_input := strconv.atoi(input_str)
	_, found := slice.linear_search(sa.slice(&gc.valid_moves), int_input)
	if !found {
		fmt.eprint("Invalid input ", int_input, "\n")
		return
	}
	return int_input
}

get_ai_input :: proc(gc: ^Game_Cache) -> (ai_input: int) {
	gc.answers_remaining -= 1
	if (gc.selected_action >= ACTION_COUNT) {
		fmt.eprint("Invalid input ", gc.selected_action, "\n")
		gc.seed += 1
		return gc.valid_moves.data[RANDOM_NUMBERS[gc.seed] % gc.valid_moves.len]
	}
	_, found := slice.linear_search(sa.slice(&gc.valid_moves), gc.selected_action)
	if !found {
		fmt.eprint("Invalid input ", gc.selected_action, "\n")
		gc.seed += 1
		return gc.valid_moves.data[RANDOM_NUMBERS[gc.seed] % gc.valid_moves.len]
	}
	return gc.selected_action
}
