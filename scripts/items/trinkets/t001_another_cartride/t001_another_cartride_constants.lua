local AnotherCartride_META = {
	__index = {},
}
local AnotherCartride = AnotherCartride_META.__index

AnotherCartride.TrinketPhase = {
	PHASE_STANDBY = 0,
	PHASE_ON_SPACESHIP = 1,
}

AnotherCartride.CheckpointType = {
	CHECKPOINT_NOT_FOUND = 0,
	CHECKPOINT_SPACESHIP = 1,
}

return AnotherCartride_META