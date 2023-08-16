local SpellContent = {}
local MagicType = tbom.MagicType
local SpellType = tbom.SpellType

local GFXRoot = "gfx/tbom/ui/spells/"
local MPCost = "MP cost: "
local MPCost_zh = "消耗魔导力： "
local PPS = " points per second"
local PPS_zh = "每秒"
local PPT = " points per target"
local PPT_zh = "每个目标"
local second = 60

SpellContent[0] = {
	Type = MagicType.NONE,
	ID = SpellType.SPELL_NONE,
	Name = {["en"] = "", ["zh"] = ""},
	Desc = {["en"] = "", ["zh"] = ""},
	GFX = "gfx/blank.png",
	Cost = 5,
	MaxReberu = 1,
}

SpellContent[1] = {
	Type = MagicType.AGGRESSIVE,
	ID = SpellType.SPELL_FIRE,
	Name = {["en"] = "Fire", ["zh"] = "火炎术"},
	Desc = {["en"] = MPCost.."0.2"..PPS, ["zh"] = MPCost_zh..PPS_zh.."0.2点"},
	GFX = GFXRoot.."fire.png",
	Cost = 0.2,
	MaxReberu = 4,
	MinChargeReberu = 1,
	MaxCharge = 2 * second,
	BurstingTime = 1,
	OverHeatCD = 3 * second,
}

SpellContent[2] = {
	Type = MagicType.AGGRESSIVE,
	ID = SpellType.SPELL_ICE_STORM,
	Name = {["en"] = "Ice Storm", ["zh"] = "冰霜风暴"},
	Desc = {["en"] = MPCost.."0.2"..PPS, ["zh"] = MPCost_zh..PPS_zh.."0.2点"},
	GFX = GFXRoot.."ice_storm.png",
	Cost = 0.2,
	MaxReberu = 4,
	MinChargeReberu = 2,
	MaxCharge = 2 * second,
	BurstingTime = {[2] = 0, [3] = 5 * second, [4] = 5 * second,},
	OverHeatCD = 10 * second,
}

SpellContent[3] = {
	Type = MagicType.AGGRESSIVE,
	ID = SpellType.SPELL_THUNDER,
	Name = {["en"] = "Thunder", ["zh"] = "闪电术"},
	Desc = {["en"] = MPCost.."0.3"..PPS, ["zh"] = MPCost_zh..PPS_zh.."0.3点"},
	GFX = GFXRoot.."thunder.png",
	Cost = 0.3,
	MaxReberu = 4,
	MinChargeReberu = 3,
	MaxCharge = 2 * second,
	--MaxCharge = 5 * second,
	BurstingTime = 20,
	OverHeatCD = 3 * second,
	--OverHeatCD = 20 * second,
}

SpellContent[4] = {
	Type = MagicType.DEFENSIVE,
	ID = SpellType.SPELL_HEALING,
	Name = {["en"] = "Healing", ["zh"] = "治疗术"},
	Desc = {["en"] = MPCost.."25", ["zh"] = MPCost_zh.."25"},
	GFX = GFXRoot.."healing.png",
	Cost = 25,
	MaxReberu = 1,
	MaxCD = 80 * second,
}

SpellContent[5] = {
	Type = MagicType.SPECIAL,
	ID = SpellType.SPELL_DIACUTE,
	Name = {["en"] = "Diacute", ["zh"] = "二阶强化术"},
	Desc = {["en"] = MPCost.."15", ["zh"] = MPCost_zh.."15"},
	GFX = GFXRoot.."diacute.png",
	Cost = 15,
	MaxReberu = 4,
	MaxCD = 30 * second,
	FormalCD = 60 * second,
}

SpellContent[6] = {
	Type = MagicType.DEFENSIVE,
	ID = SpellType.SPELL_BAYOEN,
	Name = {["en"] = "Bayoen", ["zh"] = "繁花乱象"},
	Desc = {["en"] = MPCost.."25", ["zh"] = MPCost_zh.."25"},
	GFX = GFXRoot.."bayoen.png",
	Cost = 25,
	MaxReberu = 1,
	MaxCD = 100 * second,
}

SpellContent[7] = {
	Type = MagicType.DEFENSIVE,
	ID = SpellType.SPELL_REVIA,
	Name = {["en"] = "Revia", ["zh"] = "荆棘障壁"},
	Desc = {["en"] = MPCost.."20", ["zh"] = MPCost_zh.."20"},
	GFX = GFXRoot.."revia.png",
	Cost = 20,
	MaxReberu = 1,
	MaxCD = 60 * second,
}

SpellContent[8] = {
	Type = MagicType.LOCKON,
	ID = SpellType.SPELL_JUGEM,
	Name = {["en"] = "Jugem", ["zh"] = "气爆弹"},
	Desc = {["en"] = MPCost.."5"..PPT, ["zh"] = MPCost_zh..PPT_zh.."5点"},
	GFX = GFXRoot.."jugem.png",
	Cost = 5,
	MaxReberu = 1,
	MaxTargetNum = 4,
	DMGMulti = 20,
}

return SpellContent