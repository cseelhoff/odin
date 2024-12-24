package oaaa
import sa "core:container/small_array"
import "core:fmt"
import "core:os"
import "core:strconv"

get_move_input_air :: proc(
	gc: ^Game_Cache,
	unit: Active_Air_Unit_Type,
	src_air: ^Territory,
) -> (
	dst_air_idx: int,
) {
	if (PLAYER_DATA[gc.current_turn.index].is_human) {
		fmt.print("Moving ", Air_Unit_Names[unit], " From ", src_air.name, " Valid Moves: ")
		for valid_move in sa.slice(&gc.valid_moves) {
			fmt.print(gc.territories[valid_move].name, ", ")
		}
		return get_user_input(gc)
	}
	return get_ai_input(gc)
}

get_move_input_land :: proc(
	gc: ^Game_Cache,
	unit: Active_Land_Unit_Type,
	src_air: ^Territory,
) -> (
	dst_air_idx: int,
) {
	if (PLAYER_DATA[gc.current_turn.index].is_human) {
		fmt.print("Moving ", Land_Unit_Names[unit], " From ", src_air.name, " Valid Moves: ")
		for valid_move in sa.slice(&gc.valid_moves) {
			fmt.print(gc.territories[valid_move].name, ", ")
		}
		return get_user_input(gc)
	}
	return get_ai_input(gc)
}

get_move_input_sea :: proc(
	gc: ^Game_Cache,
	unit: Active_Sea_Unit_Type,
	src_air: ^Territory,
) -> (
	dst_air_idx: int,
) {
	if (PLAYER_DATA[gc.current_turn.index].is_human) {
		fmt.print("Moving ", Sea_Unit_Names[unit], " From ", src_air.name, " Valid Moves: ")
		for valid_move in sa.slice(&gc.valid_moves) {
			fmt.print(gc.territories[valid_move].name, ", ")
		}
		return get_user_input(gc)
	}
	return get_ai_input(gc)
}

get_user_input :: proc(gc: ^Game_Cache) -> (user_input: int = 0) {
	buffer: [256]byte
	fmt.print("Enter a number between 0 and 255: ")
	n := os.read(os.stdin, buffer[:]) or_return
	input_str := string(buf[:n])
	int_input := strconv.atoi(input_str) or_return
	sa.linear_search(&gc.valid_moves, int_input) or_return
	return int_input
}

get_ai_input :: proc(gc: ^Game_Cache) -> (ai_input: int) {
	gc.answers_remaining -= 1
	ai_input = gc.valid_moves[RANDOM_NUMBERS[gc.seed] % gc.valid_moves.size()]
	gc.seed += 1
	if (gc.selected_action >= ACTION_COUNT) do return
	sa.linear_search(&gc.valid_moves, gc.selected_action) or_return
	return gc.selected_action
}
