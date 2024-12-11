package main

import "core:encoding/json"
import "core:fmt"
import "core:os"

save_json :: proc(game_state: Game_State) {
	fmt.println("Some of Odin's builtin constants")

	path := len(os.args) > 1 ? os.args[1] : "game_state.json"

	fmt.println("Odin:")
	fmt.printfln("%#v", game_state)

	fmt.println("JSON:")
	json_data, err := json.marshal(game_state, {pretty = true, use_enum_names = false})
	if err != nil {
		fmt.eprintfln("Unable to marshal JSON: %v", err)
		os.exit(1)
	}

	fmt.printfln("%s", json_data)
	fmt.printfln("Writing: %s", path)
	werr := os.write_entire_file_or_err(path, json_data)
	if werr != nil {
		fmt.eprintfln("Unable to write file: %v", werr)
		os.exit(1)
	}

	fmt.println("Done")
}

load_game_data :: proc(path: string, game_state: ^Game_State) -> (ok: bool) {
	// Load in your json file!
	data, read_ok := os.read_entire_file_from_filename(path)
	if !read_ok {
		fmt.eprintln("Failed to load the file!")
		return false
	}
	defer delete(data) // Free the memory at the end

	// Parse the json file.
	json_data, err := json.parse(data)
	if err != .None {
		fmt.eprintln("Failed to parse the json file.")
		fmt.eprintln("Error:", err)
		return false
	}
	defer json.destroy_value(json_data)
	local_game_state := game_state
	json.unmarshal(data, game_state)
	return true
}
