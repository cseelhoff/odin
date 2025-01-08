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
// 	if (PLAYER_DATA[gc.cur_player.index].is_human) {
// 		fmt.print("Moving ", unit_name, " From ", src_air.name, " Valid Moves: ")
// 		for valid_move in sa.slice(&gc.valid_moves) {
// 			fmt.print(gc.territories[valid_move].name, ", ")
// 		}
// 		return get_user_input(gc)
// 	}
// 	return get_ai_input(gc)
// }

get_retreat_input :: proc(
	gc: ^Game_Cache,
	src_air: ^Territory,
) -> (
	dst_air_idx: Air_ID,
	ok: bool,
) {
	dst_air_idx = Air_ID(gc.valid_moves.data[0])
	if gc.valid_moves.len > 1 {
		if gc.answers_remaining == 0 do return dst_air_idx, false
		if PLAYER_DATA[gc.cur_player.index].is_human {
			print_game_state(gc)
			fmt.println("Retreat From ", src_air.name, " Valid Moves: ")
			for valid_move in sa.slice(&gc.valid_moves) {
				fmt.print(int(valid_move), gc.territories[valid_move].name, ", ")
			}
			dst_air_idx = Air_ID(get_user_input(gc))
		} else {
			dst_air_idx = Air_ID(get_ai_input(gc))
		}
	}
	return dst_air_idx, true
}

get_move_input :: proc(
	gc: ^Game_Cache,
	unit_name: string,
	src_air: ^Territory,
) -> (
	dst_air_idx: Air_ID,
	ok: bool,
) {
	dst_air_idx = Air_ID(gc.valid_moves.data[0])
	if gc.valid_moves.len > 1 {
		if gc.answers_remaining == 0 do return dst_air_idx, false
		if PLAYER_DATA[gc.cur_player.index].is_human {
			print_game_state(gc)
			fmt.println("Moving ", unit_name, " From ", src_air.name, " Valid Moves: ")
			for valid_move in sa.slice(&gc.valid_moves) {
				fmt.print(int(valid_move), gc.territories[valid_move].name, ", ")
			}
			dst_air_idx = Air_ID(get_user_input(gc))
		} else {
			dst_air_idx = Air_ID(get_ai_input(gc))
		}
	}
	update_move_history(gc, src_air, dst_air_idx)
	return dst_air_idx, true
}

get_user_input :: proc(gc: ^Game_Cache) -> (user_input: int = 0) {
	buffer: [10]byte	
	fmt.print("Enter a number between 0 and 255: ")
	n, err := os.read(os.stdin, buffer[:])
	if err != 0 {
		return
	}
	input_str := string(buffer[:n])
	int_input := strconv.atoi(input_str)
	_, found := slice.linear_search(sa.slice(&gc.valid_moves), int_input)
	if !found {
		fmt.eprintln("Invalid input ", int_input)
		return
	}
	return int_input
}

get_ai_input :: proc(gc: ^Game_Cache) -> (ai_input: int) {
	gc.answers_remaining -= 1
	if (gc.selected_action >= ACTION_COUNT) {
		fmt.eprintln("Invalid input ", gc.selected_action)
		gc.seed += 1
		return gc.valid_moves.data[RANDOM_NUMBERS[gc.seed] % gc.valid_moves.len]
	}
	_, found := slice.linear_search(sa.slice(&gc.valid_moves), gc.selected_action)
	if !found {
		fmt.eprintln("Invalid input ", gc.selected_action)
		gc.seed += 1
		return gc.valid_moves.data[RANDOM_NUMBERS[gc.seed] % gc.valid_moves.len]
	}
	return gc.selected_action
}

print_game_state :: proc(gc: ^Game_Cache) {
	color := PLAYER_DATA[gc.cur_player.index].color
	fmt.println("Current Player: ", color, PLAYER_DATA[gc.cur_player.index].name)
	fmt.println("Money: ", gc.cur_player.money, DEF_COLOR)
	for territory in gc.territories {
		if int(territory.territory_index) < LANDS_COUNT {
			land := get_land(gc, territory.territory_index) 
			fmt.print(PLAYER_DATA[land.owner.index].color)
			fmt.println("\n",territory.name, "builds:", land.builds_left, land.combat_status, land.factory_dmg, "/", land.factory_prod, "bombards:", land.max_bombards)
			fmt.print(PLAYER_DATA[gc.cur_player.index].color)
			for army, army_idx in land.active_armies {
				if army > 0 {
					fmt.println(Active_Army_Names[army_idx], ":", army)
				}
			}
			for plane, plane_idx in land.active_planes {
				if plane > 0 {
					fmt.println(Active_Plane_Names[plane_idx], ":", plane)
				}
			}
			for &player in gc.players {
				if &player == gc.cur_player do continue
				fmt.print(PLAYER_DATA[player.index].color)
				for army, army_idx in land.idle_armies[player.index] {
					if army > 0 {
						fmt.println(Idle_Army_Names[army_idx], ":", army)
					}
				}
				for plane, plane_idx in land.idle_planes[player.index] {
					if plane > 0 {
						fmt.println(Idle_Plane_Names[plane_idx], ":", plane)
					}
				}
			}
			fmt.print(DEF_COLOR)
		} else {
			sea := get_sea(gc, territory.territory_index)
			fmt.println("\n",territory.name)
			fmt.print(PLAYER_DATA[gc.cur_player.index].color)
			for ship, ship_idx in sea.active_ships {
				if ship > 0 {
					fmt.println(Active_Ship_Names[ship_idx], ":", ship)
				}
			}
			for plane, plane_idx in sea.active_planes {
				if plane > 0 {
					fmt.println(Active_Plane_Names[plane_idx], ":", plane)
				}
			}
			for &player in gc.players {
				if &player == gc.cur_player do continue
				fmt.print(PLAYER_DATA[player.index].color)
				for ship, ship_idx in sea.idle_ships[player.index] {
					if ship > 0 {
						fmt.println(Idle_Army_Names[ship_idx], ":", ship)
					}
				}
				for plane, plane_idx in sea.idle_planes[player.index] {
					if plane > 0 {
						fmt.println(Idle_Plane_Names[plane_idx], ":", plane)
					}
				}
			}
			fmt.print(DEF_COLOR)
		}		
	}
}
