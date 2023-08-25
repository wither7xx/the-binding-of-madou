local Gel_META = {
	__index = {},
}
local Gel = Gel_META.__index

local GelSubType = tbom.GelSubType

Gel.GelNumIndexList = {
	[GelSubType.GEL_GREEN] = "Green",
	[GelSubType.GEL_PURPLE] = "Purple",
	[GelSubType.GEL_RED] = "Red",
	[GelSubType.GEL_YELLOW] = "Yellow",
	[GelSubType.GEL_BLUE] = "Blue",
}

Gel.GelCacheFlagList = {
	[GelSubType.GEL_PURPLE] = CacheFlag.CACHE_LUCK,
	[GelSubType.GEL_RED] = CacheFlag.CACHE_DAMAGE,
	[GelSubType.GEL_YELLOW] = CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SPEED,
	[GelSubType.GEL_BLUE] = CacheFlag.CACHE_FIREDELAY,
}

return Gel_META