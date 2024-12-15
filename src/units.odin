package oaaa

Idle_Sea_Unit_Type :: enum {
	TRANS_EMPTY,
	TRANS_1I,
	TRANS_1A,
	TRANS_1T,
	TRANS_2I,
	TRANS_1I1A,
	TRANS_1I1T,
	SUBMARINES,
	DESTROYERS,
	CARRIERS,
	CRUISERS,
	BATTLESHIPS,
	BS_DAMAGED,
}

Active_Sea_Unit_Type :: enum {
	TRANS_EMPTY_UNMOVED,
	TRANS_EMPTY_2_MOVES_LEFT,
	TRANS_EMPTY_1_MOVE_LEFT,
	TRANS_EMPTY_0_MOVES_LEFT,
	TRANS_1I_UNMOVED,
	TRANS_1I_2_MOVES_LEFT,
	TRANS_1I_1_MOVE_LEFT,
	TRANS_1I_0_MOVES_LEFT,
	TRANS_1I_UNLOADED,
	TRANS_1A_UNMOVED,
	TRANS_1A_2_MOVES_LEFT,
	TRANS_1A_1_MOVE_LEFT,
	TRANS_1A_0_MOVES_LEFT,
	TRANS_1A_UNLOADED,
	TRANS_1T_UNMOVED,
	TRANS_1T_2_MOVES_LEFT,
	TRANS_1T_1_MOVE_LEFT,
	TRANS_1T_0_MOVES_LEFT,
	TRANS_1T_UNLOADED,
	TRANS_2I_UNMOVED,
	TRANS_2I_1_MOVES_LEFT,
	TRANS_2I_0_MOVES_LEFT,
	TRANS_2I_UNLOADED,
	TRANS_1I_1A_UNMOVED,
	TRANS_1I_1A_1_MOVES_LEFT,
	TRANS_1I_1A_0_MOVES_LEFT,
	TRANS_1I_1A_UNLOADED,
	TRANS_1I_1T_UNMOVED,
	TRANS_1I_1T_1_MOVES_LEFT,
	TRANS_1I_1T_0_MOVES_LEFT,
	TRANS_1I_1T_UNLOADED,
	SUBMARINES_UNMOVED,
	SUBMARINES_0_MOVES_LEFT,
	DESTROYERS_UNMOVED,
	DESTROYERS_0_MOVES_LEFT,
	CARRIERS_UNMOVED,
	CARRIERS_0_MOVES_LEFT,
	CRUISERS_UNMOVED,
	CRUISERS_0_MOVES_LEFT,
	CRUISERS_BOMBARDED,
	BATTLESHIPS_UNMOVED,
	BATTLESHIPS_0_MOVES_LEFT,
	BATTLESHIPS_BOMBARDED,
	BS_DAMAGED_UNMOVED,
	BS_DAMAGED_0_MOVES_LEFT,
	BS_DAMAGED_BOMBARDED,
}

Idle_Land_Unit_Type :: enum {
	INFANTRY,
	ARTILLERY,
	TANKS,
	AAGUNS,
}

Active_Land_Unit_Type :: enum {
	INFANTRY_UNMOVED,
	INFANTRY_0_MOVES_LEFT,
	ARTILLERY_UNMOVED,
	ARTILLERY_0_MOVES_LEFT,
	TANKS_UNMOVED,
	TANKS_0_MOVES_LEFT,
	AAGUNS_UNMOVED,
	AAGUNS_0_MOVES_LEFT,
}

Idle_Air_Unit_Type :: enum {
	FIGHTERS_AIR,
	BOMBERS_AIR,
}

Active_Air_Unit_Type :: enum {
	FIGHTERS_AIR_UNMOVED,
	FIGHTERS_AIR_4_MOVES_LEFT,
	FIGHTERS_AIR_3_MOVES_LEFT,
	FIGHTERS_AIR_2_MOVES_LEFT,
	FIGHTERS_AIR_1_MOVES_LEFT,
	FIGHTERS_AIR_0_MOVES_LEFT,
	BOMBERS_AIR_UNMOVED,
	BOMBERS_AIR_5_MOVES_LEFT,
	BOMBERS_AIR_4_MOVES_LEFT,
	BOMBERS_AIR_3_MOVES_LEFT,
	BOMBERS_AIR_2_MOVES_LEFT,
	BOMBERS_AIR_1_MOVES_LEFT,
	BOMBERS_AIR_0_MOVES_LEFT,
}

Active_Air_Unit_Set :: bit_set[Active_Air_Unit_Type]

Is_Fighter :: Active_Air_Unit_Set {
	.FIGHTERS_AIR_UNMOVED,
	.FIGHTERS_AIR_4_MOVES_LEFT,
	.FIGHTERS_AIR_3_MOVES_LEFT,
	.FIGHTERS_AIR_2_MOVES_LEFT,
	.FIGHTERS_AIR_1_MOVES_LEFT,
	.FIGHTERS_AIR_0_MOVES_LEFT,
}
