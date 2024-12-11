package main

import "core:math/rand"

RANDOM_MAX :: 65536
RANDOM_NUMBERS: [RANDOM_MAX]int
ACTION_COUNT :: 20

initialize_random_numbers :: proc() {
	for &value in RANDOM_NUMBERS {
		value = rand.int_max(ACTION_COUNT)
	}
}
