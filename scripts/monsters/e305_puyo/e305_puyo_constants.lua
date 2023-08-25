local Puyo_META = {
	__index = {},
}
local Puyo = Puyo_META.__index

local PuyoVariant = tbom.PuyoVariant
local GelSubType = tbom.GelSubType

Puyo.PuyoSkillType = {
	SKILL_NONE = 0,
	SKILL_WINCHESTER = 1,
	SKILL_KNIFE = 2,
	SKILL_DARTS = 3,
	SKILL_BOOMERANG = 4,
	SKILL_DYNAMITE = 5,
	SKILL_SHOT_GUN = 6,
	SKILL_DOUBLE_RIFLE = 7,
	SKILL_DOUBLE_PISTOL = 8,
	SKILL_MACHINE_GUN = 9,
	SKILL_RIFLE = 10,
	SKILL_ALT_RIFLE = 11,
	SKILL_ALT_BOOMERANG = 12,
	SKILL_ALT_FIRE_BALL = 13,
	SKILL_ALT_DARTS = 14,
	SKILL_ALT_BOMB_GUN = 15,
	SKILL_ALT_MACHINE_GUN = 16,
	NUM_ARC_VERSION_SKILLS = 10,
	NUM_NES_VERSION_SKILLS = 6,
}

Puyo.PuyoFlag = {
	FLAG_DO_NOT_SHOOT = (1 << 0),				--不发射弹幕
	FLAG_DO_NOT_USE_NORMAL_SKILL = (1 << 1),	--不根据楼层决定技能
	FLAG_DO_NOT_GRANT_MANA = (1 << 2),			--被消除后不掉落魔导力拾取物
	FLAG_DO_NOT_GRANT_EXP = (1 << 3),			--被消除后不奖励经验值
	FLAG_DO_NOT_GRANT_GEL = (1 << 4),			--死亡/被消除后不掉落凝胶拾取物
	FLAG_IMMUNE_TO_ICE = (1 << 5),				--免疫冻结
	FLAG_IMMUNE_TO_EXPLOSION = (1 << 6),		--免疫爆炸
	FLAG_CANNOT_HAS_TEAR_FLAGS = (1 << 7),		--友好状态下不可拥有泪弹标记
	FLAG_CAN_STACK = (1 << 8),					--能够堆叠
}

Puyo.GelSubTypeList = {
	[PuyoVariant.PUYO_GREEN] = GelSubType.GEL_GREEN,
	[PuyoVariant.PUYO_PURPLE] = GelSubType.GEL_PURPLE,
	[PuyoVariant.PUYO_RED] = GelSubType.GEL_RED,
	[PuyoVariant.PUYO_YELLOW] = GelSubType.GEL_YELLOW,
	[PuyoVariant.PUYO_BLUE] = GelSubType.GEL_BLUE,
}

Puyo.PuyoTearFuncList = {
	[PuyoVariant.PUYO_PURPLE] = function (tear)
		tear:AddTearFlags(TearFlags.TEAR_POISON)
		tear.Color = Color(0.4, 0.97, 0.5, 1, 0, 0, 0)
	end,
	[PuyoVariant.PUYO_RED] = function (tear)
		tear:AddTearFlags(TearFlags.TEAR_BURN)
		tear.Color = Color(1, 1, 1, 1, 0.3, 0, 0)
	end,
	[PuyoVariant.PUYO_YELLOW] = function (tear)
		tear:AddTearFlags(TearFlags.TEAR_CONFUSION)
		tear.Color = Color(0.5, 0.5, 0.5, 1, 0, 0, 0)
	end,
	[PuyoVariant.PUYO_BLUE] = function (tear)
		tear:AddTearFlags(TearFlags.TEAR_SLOW | TearFlags.TEAR_ICE)
		tear.Color = Color(0.518, 0.671, 0.976, 1, 0.35, 0.4, 0.45)
	end,
}

Puyo.BasePuyoChance = 2

return Puyo_META