package oaaa

import "core:math/rand"

RANDOM_MAX :: 1024
RANDOM_NUMBERS: [RANDOM_MAX]int

initialize_random_numbers :: proc() {
	rand.reset(0)
	for &value in RANDOM_NUMBERS {
		value = rand.int_max(MAX_VALID_MOVES)
	}
}
