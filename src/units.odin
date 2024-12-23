package oaaa

Idle_Sea_Unit :: enum {
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

Active_Sea_Unit :: enum {
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
	TRANS_2I_2_MOVES_LEFT,
	TRANS_2I_1_MOVE_LEFT,
	TRANS_2I_0_MOVES_LEFT,
	TRANS_2I_UNLOADED,
	TRANS_1I_1A_2_MOVES_LEFT,
	TRANS_1I_1A_1_MOVE_LEFT,
	TRANS_1I_1A_0_MOVES_LEFT,
	TRANS_1I_1A_UNLOADED,
	TRANS_1I_1T_2_MOVES_LEFT,
	TRANS_1I_1T_1_MOVE_LEFT,
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

Sea_Unit_Names := [?]string {
	Active_Sea_Unit.TRANS_EMPTY_UNMOVED = "TRANS_EMPTY_UNMOVED",
	Active_Sea_Unit.TRANS_EMPTY_2_MOVES_LEFT = "TRANS_EMPTY_2_MOVES_LEFT",
	Active_Sea_Unit.TRANS_EMPTY_1_MOVE_LEFT = "TRANS_EMPTY_1_MOVE_LEFT",
	Active_Sea_Unit.TRANS_EMPTY_0_MOVES_LEFT = "TRANS_EMPTY_0_MOVES_LEFT",
	Active_Sea_Unit.TRANS_1I_UNMOVED = "TRANS_1I_UNMOVED",
	Active_Sea_Unit.TRANS_1I_2_MOVES_LEFT = "TRANS_1I_2_MOVES_LEFT",
	Active_Sea_Unit.TRANS_1I_1_MOVE_LEFT = "TRANS_1I_1_MOVE_LEFT",
	Active_Sea_Unit.TRANS_1I_0_MOVES_LEFT = "TRANS_1I_0_MOVES_LEFT",
	Active_Sea_Unit.TRANS_1I_UNLOADED = "TRANS_1I_UNLOADED",
	Active_Sea_Unit.TRANS_1A_UNMOVED = "TRANS_1A_UNMOVED",
	Active_Sea_Unit.TRANS_1A_2_MOVES_LEFT = "TRANS_1A_2_MOVES_LEFT",
	Active_Sea_Unit.TRANS_1A_1_MOVE_LEFT = "TRANS_1A_1_MOVE_LEFT",
	Active_Sea_Unit.TRANS_1A_0_MOVES_LEFT = "TRANS_1A_0_MOVES_LEFT",
	Active_Sea_Unit.TRANS_1A_UNLOADED = "TRANS_1A_UNLOADED",
	Active_Sea_Unit.TRANS_1T_UNMOVED = "TRANS_1T_UNMOVED",
	Active_Sea_Unit.TRANS_1T_2_MOVES_LEFT = "TRANS_1T_2_MOVES_LEFT",
	Active_Sea_Unit.TRANS_1T_1_MOVE_LEFT = "TRANS_1T_1_MOVE_LEFT",
	Active_Sea_Unit.TRANS_1T_0_MOVES_LEFT = "TRANS_1T_0_MOVES_LEFT",
	Active_Sea_Unit.TRANS_1T_UNLOADED = "TRANS_1T_UNLOADED",
	Active_Sea_Unit.TRANS_2I_UNMOVED = "TRANS_2I_UNMOVED",
	Active_Sea_Unit.TRANS_2I_1_MOVES_LEFT = "TRANS_2I_1_MOVES_LEFT",
	Active_Sea_Unit.TRANS_2I_0_MOVES_LEFT = "TRANS_2I_0_MOVES_LEFT",
	Active_Sea_Unit.TRANS_2I_UNLOADED = "TRANS_2I_UNLOADED",
	Active_Sea_Unit.TRANS_1I_1A_UNMOVED = "TRANS_1I_1A_UNMOVED",
	Active_Sea_Unit.TRANS_1I_1A_1_MOVES_LEFT = "TRANS_1I_1A_1_MOVES_LEFT",
	Active_Sea_Unit.TRANS_1I_1A_0_MOVES_LEFT = "TRANS_1I_1A_0_MOVES_LEFT",
	Active_Sea_Unit.TRANS_1I_1A_UNLOADED = "TRANS_1I_1A_UNLOADED",
	Active_Sea_Unit.TRANS_1I_1T_UNMOVED = "TRANS_1I_1T_UNMOVED",
	Active_Sea_Unit.TRANS_1I_1T_1_MOVES_LEFT = "TRANS_1I_1T_1_MOVES_LEFT",
	Active_Sea_Unit.TRANS_1I_1T_0_MOVES_LEFT = "TRANS_1I_1T_0_MOVES_LEFT",
	Active_Sea_Unit.TRANS_1I_1T_UNLOADED = "TRANS_1I_1T_UNLOADED",
	Active_Sea_Unit.SUBMARINES_UNMOVED = "SUBMARINES_UNMOVED",
	Active_Sea_Unit.SUBMARINES_0_MOVES_LEFT = "SUBMARINES_0_MOVES_LEFT",
	Active_Sea_Unit.DESTROYERS_UNMOVED = "DESTROYERS_UNMOVED",
	Active_Sea_Unit.DESTROYERS_0_MOVES_LEFT = "DESTROYERS_0_MOVES_LEFT",
	Active_Sea_Unit.CARRIERS_UNMOVED = "CARRIERS_UNMOVED",
	Active_Sea_Unit.CARRIERS_0_MOVES_LEFT = "CARRIERS_0_MOVES_LEFT",
	Active_Sea_Unit.CRUISERS_UNMOVED = "CRUISERS_UNMOVED",
	Active_Sea_Unit.CRUISERS_0_MOVES_LEFT = "CRUISERS_0_MOVES_LEFT",
	Active_Sea_Unit.CRUISERS_BOMBARDED = "CRUISERS_BOMBARDED",
	Active_Sea_Unit.BATTLESHIPS_UNMOVED = "BATTLESHIPS_UNMOVED",
	Active_Sea_Unit.BATTLESHIPS_0_MOVES_LEFT = "BATTLESHIPS_0_MOVES_LEFT",
	Active_Sea_Unit.BATTLESHIPS_BOMBARDED = "BATTLESHIPS_BOMBARDED",
	Active_Sea_Unit.BS_DAMAGED_UNMOVED = "BS_DAMAGED_UNMOVED",
	Active_Sea_Unit.BS_DAMAGED_0_MOVES_LEFT = "BS_DAMAGED_0_MOVES_LEFT",
	Active_Sea_Unit.BS_DAMAGED_BOMBARDED = "BS_DAMAGED_BOMBARDED",
}

Idle_Sea_From_Active := [?]Idle_Sea_Unit {
	Active_Sea_Unit.TRANS_EMPTY_UNMOVED = .TRANS_EMPTY,
	Active_Sea_Unit.TRANS_1I_UNMOVED    = .TRANS_1I,
	Active_Sea_Unit.TRANS_1A_UNMOVED    = .TRANS_1A,
	Active_Sea_Unit.TRANS_1T_UNMOVED    = .TRANS_1T,
}

Idle_Land_From_Active := [?]Idle_Land_Unit {
	Active_Land_Unit.INFANTRY_UNMOVED = .INFANTRY,
	Active_Land_Unit.ARTILLERY_UNMOVED = .ARTILLERY,
	Active_Land_Unit.TANKS_UNMOVED = .TANKS,
	Active_Land_Unit.AAGUNS_UNMOVED = .AAGUNS,
}

Idle_Land_Unit :: enum {
	INFANTRY,
	ARTILLERY,
	TANKS,
	AAGUNS,
}

Active_Land_Unit :: enum {
	INFANTRY_UNMOVED,
	INFANTRY_0_MOVES_LEFT,
	ARTILLERY_UNMOVED,
	ARTILLERY_0_MOVES_LEFT,
	TANKS_UNMOVED,
	TANKS_1_MOVE_LEFT,
	TANKS_0_MOVES_LEFT,
	AAGUNS_UNMOVED,
	AAGUNS_0_MOVES_LEFT,
}

Land_Unit_Names := [?]string {
	Active_Land_Unit.INFANTRY_UNMOVED = "INFANTRY_UNMOVED",
	Active_Land_Unit.INFANTRY_0_MOVES_LEFT = "INFANTRY_0_MOVES_LEFT",
	Active_Land_Unit.ARTILLERY_UNMOVED = "ARTILLERY_UNMOVED",
	Active_Land_Unit.ARTILLERY_0_MOVES_LEFT = "ARTILLERY_0_MOVES_LEFT",
	Active_Land_Unit.TANKS_UNMOVED = "TANKS_UNMOVED",
	Active_Land_Unit.TANKS_1_MOVE_LEFT = "TANKS_1_MOVE_LEFT",
	Active_Land_Unit.TANKS_0_MOVES_LEFT = "TANKS_0_MOVES_LEFT",
	Active_Land_Unit.AAGUNS_UNMOVED = "AAGUNS_UNMOVED",
	Active_Land_Unit.AAGUNS_0_MOVES_LEFT = "AAGUNS_0_MOVES_LEFT",
}

Idle_Air_Unit :: enum {
	FIGHTERS_AIR,
	BOMBERS_AIR,
}

Active_Air_Unit :: enum {
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

Air_Unit_Names := [?]string {
	Active_Air_Unit.FIGHTERS_AIR_UNMOVED = "FIGHTERS_AIR_UNMOVED",
	Active_Air_Unit.FIGHTERS_AIR_4_MOVES_LEFT = "FIGHTERS_AIR_4_MOVES_LEFT",
	Active_Air_Unit.FIGHTERS_AIR_3_MOVES_LEFT = "FIGHTERS_AIR_3_MOVES_LEFT",
	Active_Air_Unit.FIGHTERS_AIR_2_MOVES_LEFT = "FIGHTERS_AIR_2_MOVES_LEFT",
	Active_Air_Unit.FIGHTERS_AIR_1_MOVES_LEFT = "FIGHTERS_AIR_1_MOVES_LEFT",
	Active_Air_Unit.FIGHTERS_AIR_0_MOVES_LEFT = "FIGHTERS_AIR_0_MOVES_LEFT",
	Active_Air_Unit.BOMBERS_AIR_UNMOVED = "BOMBERS_AIR_UNMOVED",
	Active_Air_Unit.BOMBERS_AIR_5_MOVES_LEFT = "BOMBERS_AIR_5_MOVES_LEFT",
	Active_Air_Unit.BOMBERS_AIR_4_MOVES_LEFT = "BOMBERS_AIR_4_MOVES_LEFT",
	Active_Air_Unit.BOMBERS_AIR_3_MOVES_LEFT = "BOMBERS_AIR_3_MOVES_LEFT",
	Active_Air_Unit.BOMBERS_AIR_2_MOVES_LEFT = "BOMBERS_AIR_2_MOVES_LEFT",
	Active_Air_Unit.BOMBERS_AIR_1_MOVES_LEFT = "BOMBERS_AIR_1_MOVES_LEFT",
	Active_Air_Unit.BOMBERS_AIR_0_MOVES_LEFT = "BOMBERS_AIR_0_MOVES_LEFT",
}