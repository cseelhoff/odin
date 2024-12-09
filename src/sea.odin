package main

MAX_SEA_TO_LAND_CONNECTIONS :: 6
MAX_SEA_TO_SEA_CONNECTIONS :: 7

Sea_Strings :: struct {
	name:      string,
	sea_conns: [dynamic]string,
}

SEAS := [?]Sea_Strings {
	{name = "Pacific", sea_conns = {"Atlantic"}},
	{name = "Atlantic", sea_conns = {"Pacific", "Baltic"}},
	{name = "Baltic", sea_conns = {"Atlantic"}},
}
SEAS_COUNT :: len(SEAS)
