package main

import "core:math/rand"

RANDOM_MAX :: 65536
RANDOM_NUMBERS: [RANDOM_MAX]int

initialize_random_numbers :: proc() {
	for i in 0 ..< RANDOM_MAX {
		RANDOM_NUMBERS[i] = rand.int_max(ACTION_COUNT)
	}
}
