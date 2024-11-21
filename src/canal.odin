package main

Canal :: struct {
	sea1:  int,
	sea2:  int,
	land1: int,
    land2: int,
}

CANALS := [?]Canal {
    {0,0,0,0},
    {0,0,0,0},
}

CANAL_STATES :: 1 << len(CANALS)
//Canal_State_Set :: bit_set[0..<len(CANALS)]