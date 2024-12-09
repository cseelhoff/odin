package main

Canal_Strings :: struct {
	sea1:  string,
	sea2:  string,
	land1: string,
	land2: string,
}

CANALS := [?]Canal_Strings{{"Pacific", "Baltic", "Moscow", "Moscow"}}
CANALS_COUNT :: len(CANALS)
CANAL_STATES :: 1 << CANALS_COUNT

//Canal_State_Set :: bit_set[0..<len(CANALS)]
