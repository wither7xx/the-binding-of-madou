------v0.1.2开发版------
tbom = RegisterMod("The Binding of Madou", 1)

local Fonts = {
	["en"] = Font(),
	["zh"] = Font(),
	["number"] = Font(),
}
Fonts["en"]:Load("font/pftempestasevencondensed.fnt")
Fonts["zh"]:Load("font/cjk/lanapixel.fnt")
Fonts["number"]:Load("font/pftempestasevencondensed.fnt")

tbom.modCard = {}

tbom.modChallenge = {
	CHALLENGE_METEOR_SHOWER = Isaac.GetChallengeIdByName("Meteor Shower"),
	CHALLENGE_DESCENDING_INTO_PUYO_HELL = Isaac.GetChallengeIdByName("Descending Into Puyo Hell"),
}

tbom.modCollectibleType = {
	COLLECTIBLE_BLUE_GRIMOIRE = Isaac.GetItemIdByName("Blue Grimoire"),
	COLLECTIBLE_PUYO_HAT = Isaac.GetItemIdByName("Puyo Hat"),
	COLLECTIBLE_WORMHOLE_APPLE = Isaac.GetItemIdByName("Wormhole Apple"),
	COLLECTIBLE_HEART_SHAPED_COOKIE = Isaac.GetItemIdByName("Heart Shaped Cookie"),

	COLLECTIBLE_GREEN_GRIMOIRE = Isaac.GetItemIdByName("Green Grimoire"),
}

tbom.modCostume = {
	ARLE_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/character_arle_hair.anm2"),
}

tbom.modEffectVariant = {
	EXP = Isaac.GetEntityVariantByName("EXP"),
	LASER_SIGHT = Isaac.GetEntityVariantByName("Laser Sight"),
	LOCKON_MARK = Isaac.GetEntityVariantByName("Lock-on Mark"),
	MAGIC_CIRCLE = Isaac.GetEntityVariantByName("Magic Circle"),
	CHARGE_LASER_SIGHT = Isaac.GetEntityVariantByName("Charge Laser Sight"),
	PUYO_FIRE_POINT = Isaac.GetEntityVariantByName("Puyo Fire Point"),
	PUYO_GIBS = Isaac.GetEntityVariantByName("Puyo Gibs"),
	ET_CHECKPOINT = Isaac.GetEntityVariantByName("ET Checkpoint"),
	ET_SPACESHIP = Isaac.GetEntityVariantByName("ET Spaceship"),

	BLANK_ANIM = Isaac.GetEntityVariantByName("Blank Animation"),
}

tbom.modEntityType = {
	ENTITY_PUYO = Isaac.GetEntityTypeByName("Green Puyo"),
}

tbom.modFamiliarVariant = {
	LIGHT_ORB = Isaac.GetEntityVariantByName("Light Orb"),
}

tbom.Fonts = Fonts

tbom.modPickupVariant = {
	PICKUP_MANA = Isaac.GetEntityVariantByName("Mana"),
	PICKUP_GEL = Isaac.GetEntityVariantByName("Green Gel"),
}

tbom.modPlayerType = {
	PLAYER_ORIGINAL = 0,	--仅用于相关表的检索，不代表某个特定的角色实体类型
	PLAYER_ARLENADJA = Isaac.GetPlayerTypeByName("Arle Nadja", false),
	PLAYER_ARLENADJA_B = Isaac.GetPlayerTypeByName("Tainted Arle", true),
}

tbom.modSoundEffect = {
	SOUND_EXP_GET = Isaac.GetSoundIdByName("EXP Get"),
	SOUND_LASER_SIGHT = Isaac.GetSoundIdByName("Laser Sight"),
	SOUND_LOCKON_MARK = Isaac.GetSoundIdByName("Lock-on Mark"),
	SOUND_THUNDER_BURSTING = Isaac.GetSoundIdByName("Thunder Bursting"),
	SOUND_PUYO_1_CHAIN = Isaac.GetSoundIdByName("Puyo 1 Chain"),
	SOUND_PUYO_2_CHAIN = Isaac.GetSoundIdByName("Puyo 2 Chain"),
	SOUND_PUYO_3_CHAIN = Isaac.GetSoundIdByName("Puyo 3 Chain"),
	SOUND_PUYO_4_CHAIN = Isaac.GetSoundIdByName("Puyo 4 Chain"),
	SOUND_PUYO_5_CHAIN = Isaac.GetSoundIdByName("Puyo 5 Chain"),
	SOUND_PUYO_6_CHAIN = Isaac.GetSoundIdByName("Puyo 6 Chain"),
	SOUND_PUYO_7_CHAIN = Isaac.GetSoundIdByName("Puyo 7 Chain"),
	SOUND_PUYO_BURST = Isaac.GetSoundIdByName("Puyo Burst"),
	SOUND_GEL_GET = Isaac.GetSoundIdByName("Gel Get"),
	SOUND_GEL_GET_ARCADE_1 = Isaac.GetSoundIdByName("Gel Get Arcade 1"),
	SOUND_GEL_GET_ARCADE_2 = Isaac.GetSoundIdByName("Gel Get Arcade 2"),
	SOUND_GEL_GET_ARCADE_3 = Isaac.GetSoundIdByName("Gel Get Arcade 3"),
	SOUND_GREEN_GEL_HIT = Isaac.GetSoundIdByName("Green Gel Hit"),
	SOUND_ET_SPACESHIP = Isaac.GetSoundIdByName("ET Spaceship"),
}

tbom.modTrinketType = {
	TRINKET_ANOTHER_CARTRIDE = Isaac.GetTrinketIdByName("Another Cartride"),
}

tbom.MagicType = {
	NONE = 0,			--空类型法术：无CD，使用瞬间消耗魔导力
	AGGRESSIVE = 1,		--攻击性法术：无CD，使用期间每秒消耗魔导力
	DEFENSIVE = 2,		--防御性法术：有CD，使用瞬间消耗魔导力，CD期间不可使用
	SPECIAL = 3,		--特殊法术：有CD，使用瞬间消耗魔导力，CD期间某段时间内仍可使用
	LOCKON = 4,			--瞄准-锁定型法术：无专用CD，使用后每瞄准一个目标消耗魔导力
	HELPER = 5,			--辅助性法术：有短暂CD，不消耗魔导力，但使用瞬间消耗其他数值（比如血量）
}

tbom.SpellType = {
	SPELL_INVALID = -1,					--无效法术
	SPELL_NONE = 0,						--间属性法术
	SPELL_FIRE = 1,						--火炎术
	SPELL_ICE_STORM = 2,				--冰霜风暴
	SPELL_THUNDER = 3,					--闪电术
	SPELL_HEALING = 4,					--治疗术
	SPELL_DIACUTE = 5,					--二阶强化术
	SPELL_BAYOEN = 6,					--繁花乱象
	SPELL_REVIA = 7,					--荆棘障壁
	SPELL_JUGEM =  8,					--气爆弹
	SPELL_LWARK_WOID = 9,				--吸星术
	SPELL_BRAIN_DUMBED = 10,			--蚀智术
	SPELL_ILLUSION = 11,				--幻象错觉
	SPELL_HEAVEN_RAY = 12,				--天界射线
	SPELL_SINGING_VOICE_OF_HOPE = 13,	--希望之音
	SPELL_ABYSS = 14,					--狱炎术
	SPELL_CHAOS = 15,					--混沌冰暴
	SPELL_LIGHTENING = 16,				--雷电术
	SPELL_ECLIPSE = 17,					--侵腐术
	SPELL_LABYRINTH = 18,				--幻惑强化术
	SPELL_VOID_HOLE = 19,				--虚空虹洞
	SPELL_RAGNAROK = 20,				--末世权化
	SPELL_GRAND_CROSS = 21,				--灾星阵

	SPELL_FLAME_TORNADO = 98,			--卷炎术
	SPELL_DARK_BLIZZARD = 99,			--暗夜霜暴
	SPELL_HEAVENLY_THUNDER = 100,		--裂天震电
	SPELL_VOLCANA = 101,				--爆炎奥术
	SPELL_GLACIERIA = 102,				--寒霜奥术
	SPELL_LIGHTING_BRUST = 103,			--惊雷奥术
	SPELL_AURORA = 104,					--曙光奥术
}

tbom.AwardFlag = {
	AWARD_STATS_INCREASE = (1 << 0),
	AWARD_HP_UP = (1 << 1),
	AWARD_MP_UP = (1 << 2),
	AWARD_UPGRADE_SPELL = (1 << 3),
	AWARD_RECOVERY_UP = (1 << 4),
}

tbom.PuyoVariant = {
	PUYO_GREEN = Isaac.GetEntityVariantByName("Green Puyo"),
	PUYO_PURPLE = Isaac.GetEntityVariantByName("Purple Puyo"),
	PUYO_RED = Isaac.GetEntityVariantByName("Red Puyo"),
	PUYO_YELLOW = Isaac.GetEntityVariantByName("Yellow Puyo"),
	PUYO_BLUE = Isaac.GetEntityVariantByName("Blue Puyo"),
}

tbom.GelSubType = {
	GEL_GREEN = 0,
	GEL_PURPLE = 1,
	GEL_RED = 2,
	GEL_YELLOW = 3,
	GEL_BLUE = 4,
}

tbom.tbomCallbacks = {
	--带有BASE字样的回调函数具由更高的优先级
	TBOMC_ENABLE_SPELL = "TBOMC_ENABLE_SPELL",							--回调参数：spell_ID（整数）；函数参数：spell_ID（整数），rng（RNG对象），player（角色实体对象）, use_flags（整数）；返回值类型：是否显示动画（逻辑）
	TBOMC_DISABLE_SPELL = "TBOMC_DISABLE_SPELL",						--回调参数：spell_ID（整数）；函数参数：spell_ID（整数），rng（RNG对象），player（角色实体对象）, use_flags（整数）；返回值类型：是否显示动画（逻辑）
	TBOMC_SPELL_UPDATE = "TBOMC_SPELL_UPDATE",							--回调参数：spell_ID（整数）；函数参数：spell_ID（整数），player（角色实体对象）；返回值类型：无
	TBOMC_ENABLE_SPELL_BASE = "TBOMC_ENABLE_SPELL_BASE",				--回调参数：magic_type（整数）；函数参数：spell_ID（整数），rng（RNG对象），player（角色实体对象）, use_flags（整数）；返回值类型：无
	TBOMC_DISABLE_SPELL_BASE = "TBOMC_DISABLE_SPELL_BASE",				--回调参数：magic_type（整数）；函数参数：spell_ID（整数），rng（RNG对象），player（角色实体对象）, use_flags（整数）；返回值类型：无
	TBOMC_SPELL_UPDATE_BASE = "TBOMC_SPELL_UPDATE_BASE",				--回调参数：magic_type（整数）；函数参数：spell_ID（整数），player（角色实体对象）；返回值类型：无

	TBOMC_USE_SPELL = "TBOMC_USE_SPELL",								--回调参数：spell_ID（整数）；函数参数：spell_ID（整数），rng（RNG对象），player（角色实体对象）, use_flags（整数）；返回值类型：是否显示动画（逻辑）
	TBOMC_USE_SPELL_BASE = "TBOMC_USE_SPELL_BASE",						--回调参数：magic_type（整数）；函数参数：spell_ID（整数），rng（RNG对象），player（角色实体对象）, use_flags（整数）；返回值类型：无

	TBOMC_POST_SPELL_INIT = "TBOMC_POST_SPELL_INIT",					--回调参数：spell_ID（整数）；函数参数：spell_ID（整数），player（角色实体对象）；返回值类型：无
	TBOMC_POST_SPELL_INIT_BASE = "TBOMC_POST_SPELL_INIT_BASE",			--回调参数：magic_type（整数）；函数参数：spell_ID（整数），player（角色实体对象）；返回值类型：无

	TBOMC_POST_USE_SIM_SPELL = "TBOMC_POST_USE_SIM_SPELL",				--回调参数：sim_spell_ID（整数）；函数参数：sim_spell_ID（整数），rng（RNG对象），player（角色实体对象）, use_flags（整数）；返回值类型：无
	TBOMC_PRE_BURST_ATK_CHARGE = "TBOMC_PRE_BURST_ATK_CHARGE",			--回调参数：spell_ID（整数）；函数参数：spell_ID（整数），reberu（整数），rng（RNG对象），player（角色实体对象）；返回值类型：无
	TBOMC_POST_BURST_ATK_CHARGE = "TBOMC_POST_BURST_ATK_CHARGE",		--回调参数：spell_ID（整数）；函数参数：spell_ID（整数），reberu（整数），timeout（整数），rng（RNG对象），player（角色实体对象）；返回值类型：无
	TBOMC_POST_TRIGGER_ATK_EFFECT = "TBOMC_POST_TRIGGER_ATK_EFFECT",	--回调参数：spell_ID（整数）；函数参数：spell_ID（整数），rng（RNG对象），player（角色实体对象）, use_flags（整数）；返回值类型：无
	TBOMC_POST_FIRE_LOCKON_WEAPON = "TBOMC_POST_FIRE_LOCKON_WEAPON",	--回调参数：spell_ID（整数）；函数参数：spell_ID（整数），player（角色实体对象），target（实体对象）；返回值类型：无
	TBOMC_POST_COST_SPCHARGE = "TBOMC_POST_COST_SPCHARGE",				--回调参数：无；函数参数：player（角色实体对象），attribute_name（字符串），amount（正浮点数）；返回值类型：无
	TBOMC_PRE_GET_UPGRADE_AWARD = "TBOMC_PRE_GET_UPGRADE_AWARD",		--回调参数：无；函数参数：player（角色实体对象），award_flag（整数）；返回值类型：无
	
	TBOMC_DOUBLE_TAP = "TBOMC_DOUBLE_TAP",								--回调参数：button_action（整数）；函数参数：button_action（整数），player（角色实体对象）；返回值类型：无
	TBOMC_TAP_AND_HOLD_MOVING = "TBOMC_TAP_AND_HOLD_MOVING",			--回调参数：action_type（整数；0:待机；1：按住；2：释放）；函数参数：move_dir（向量），player（角色实体对象）；返回值类型：无
	TBOMC_TAP_AND_HOLD_SHOOTING = "TBOMC_TAP_AND_HOLD_SHOOTING",		--回调参数：action_type（整数；0:待机；1：按住；2：释放）；函数参数：shoot_dir（向量），player（角色实体对象）；返回值类型：无
	TBOMC_PRE_ADD_COLLECTIBLE = "TBOMC_PRE_ADD_COLLECTIBLE",			--回调参数：collectible_type（整数）；函数参数：collectible_type（整数），rng（RNG对象），player（角色实体对象）；返回值类型：无
	TBOMC_POST_ADD_COLLECTIBLE = "TBOMC_POST_ADD_COLLECTIBLE",			--回调参数：collectible_type（整数）；函数参数：collectible_type（整数），rng（RNG对象），player（角色实体对象），is_newly_added（逻辑）；返回值类型：无
	TBOMC_PRE_ADD_TRINKET = "TBOMC_PRE_ADD_TRINKET",					--回调参数：trinket_type（整数）；函数参数：trinket_type（整数），rng（RNG对象），player（角色实体对象）；返回值类型：无
	TBOMC_PRE_ADD_CARD = "TBOMC_PRE_ADD_CARD",							--回调参数：card（整数）；函数参数：card（整数），player（角色实体对象）；返回值类型：无
	TBOMC_POST_NEW_GREED_MODE_WAVE = "TBOMC_POST_NEW_GREED_MODE_WAVE",	--回调参数：无；函数参数：current_wave（整数）；返回值类型：无
}

tbom.DefaultKeyConfig = {
	["P1 change spell 1 (Keyboard)"] = Keyboard.KEY_LEFT_ALT,
	["P1 change spell 2 (Keyboard)"] = Keyboard.KEY_RIGHT_CONTROL,
	["P1 change spell 1 (Controller)"] = 0,
	["P1 change spell 2 (Controller)"] = 1,

	["P2 change spell 1 (Keyboard)"] = Keyboard.KEY_LEFT_ALT,
	["P2 change spell 2 (Keyboard)"] = Keyboard.KEY_RIGHT_CONTROL,
	["P2 change spell 1 (Controller)"] = 0,
	["P2 change spell 2 (Controller)"] = 1,

	["P3 change spell 1 (Keyboard)"] = Keyboard.KEY_LEFT_ALT,
	["P3 change spell 2 (Keyboard)"] = Keyboard.KEY_RIGHT_CONTROL,
	["P3 change spell 1 (Controller)"] = 0,
	["P3 change spell 2 (Controller)"] = 1,

	["P4 change spell 1 (Keyboard)"] = Keyboard.KEY_LEFT_ALT,
	["P4 change spell 2 (Keyboard)"] = Keyboard.KEY_RIGHT_CONTROL,
	["P4 change spell 1 (Controller)"] = 0,
	["P4 change spell 2 (Controller)"] = 1,
}

tbom.KeyConfig = {}
for key, cfg in pairs(tbom.DefaultKeyConfig) do
	tbom.KeyConfig[key] = tbom.DefaultKeyConfig[key]
end

tbom.TempData = {}
--tbom.TempData.PlayerData_Static = {}
--tbom.TempData.PlayerData_Static["UserNum"] = 0
--tbom.TempData.PlayerData_UserRegister = {}
tbom.TempData.PlayerData = {}
tbom.TempData.GameData = {}
tbom.TempData.NPCData = {}
tbom.TempData.EffectData = {}

tbom.Global = {}
tbom.Global.Common = include("scripts/!global/common")
tbom.Global.Maths = include("scripts/!global/maths")
tbom.Global.Tools = include("scripts/!global/tools")
tbom.Global.Translation = include("scripts/!global/translation")
tbom.Global.ModData = include("scripts/!global/mod_data")

tbom.SpellContent = include("scripts/features/spells/!content")
tbom.Magic = include("scripts/features/magic")

tbom.LevelExp = include("scripts/features/level_exp")

tbom.CriticalChance = include("scripts/features/critical_chance")

local MagicType = tbom.MagicType
tbom.BaseSpell = {
	[MagicType.NONE] = include("scripts/features/spells/000_none/!base"),
	[MagicType.AGGRESSIVE] = include("scripts/features/spells/001_aggressive/!base"),
	[MagicType.DEFENSIVE] = include("scripts/features/spells/002_defensive/!base"),
	[MagicType.SPECIAL] = include("scripts/features/spells/003_special/!base"),
	[MagicType.LOCKON] = include("scripts/features/spells/004_lockon/!base"),
	[MagicType.HELPER] = include("scripts/features/spells/005_helper/!base"),
}

local SpellType = tbom.SpellType
tbom.Spells = {
	--空类型法术
	[SpellType.SPELL_NONE] = include("scripts/features/spells/000_none/000_none"),
	--攻击性法术
	[SpellType.SPELL_FIRE] = include("scripts/features/spells/001_aggressive/001_fire"),
	[SpellType.SPELL_ICE_STORM] = include("scripts/features/spells/001_aggressive/002_ice_storm"),
	[SpellType.SPELL_THUNDER] = include("scripts/features/spells/001_aggressive/003_thunder"),
	--防御性法术
	[SpellType.SPELL_HEALING] = include("scripts/features/spells/002_defensive/004_healing"),
	[SpellType.SPELL_BAYOEN] = include("scripts/features/spells/002_defensive/006_bayoen"),
	[SpellType.SPELL_REVIA] = include("scripts/features/spells/002_defensive/007_revia"),
	--特殊法术
	[SpellType.SPELL_DIACUTE] = include("scripts/features/spells/003_special/005_diacute"),
	--瞄准-锁定型法术
	[SpellType.SPELL_JUGEM] = include("scripts/features/spells/004_lockon/008_jugem"),
}

local modCard = tbom.modCard
tbom.Cards = {
	--命名格式：k[ID]_[名称]
}

local modEffectVariant = tbom.modEffectVariant
tbom.Effects = {
	--命名格式：ef[ID]_[名称]
	[modEffectVariant.EXP] = include("scripts/effects/ef2400_exp/ef2400_exp_main"),
	[modEffectVariant.LASER_SIGHT] = include("scripts/effects/ef2401_laser_sight/ef2401_laser_sight_main"),
	[modEffectVariant.LOCKON_MARK] = include("scripts/effects/ef2402_lockon_mark/ef2402_lockon_mark_main"),
	[modEffectVariant.MAGIC_CIRCLE] = include("scripts/effects/ef2403_magic_circle/ef2403_magic_circle_main"),
	[modEffectVariant.ET_SPACESHIP] = include("scripts/effects/ef2408_et_spaceship/ef2408_et_spaceship_main"),
}

local modFamiliarVariant = tbom.modFamiliarVariant
tbom.Familiar = {
	--命名格式：f[ID]_[名称]
	[modFamiliarVariant.LIGHT_ORB] = include("scripts/familiar/f2400_light_orb/f2400_light_orb_main"),
}

local modEntityType = tbom.modEntityType
tbom.Monsters = {
	--命名格式：e[ID]_[名称]
	[modEntityType.ENTITY_PUYO] = include("scripts/monsters/e305_puyo/e305_puyo_main"),
}

local modCollectibleType = tbom.modCollectibleType
tbom.Collectibles = {
	--命名格式：c[ID]_[名称]
	[modCollectibleType.COLLECTIBLE_BLUE_GRIMOIRE] = include("scripts/items/collectibles/c001_blue_grimoire/c001_blue_grimoire_main"),
	[modCollectibleType.COLLECTIBLE_PUYO_HAT] = include("scripts/items/collectibles/c002_puyo_hat/c002_puyo_hat_main"),
	[modCollectibleType.COLLECTIBLE_WORMHOLE_APPLE] = include("scripts/items/collectibles/c003_wormhole_apple/c003_wormhole_apple_main"),
	[modCollectibleType.COLLECTIBLE_HEART_SHAPED_COOKIE] = include("scripts/items/collectibles/c004_heart_shaped_cookie/c004_heart_shaped_cookie_main"),

	[modCollectibleType.COLLECTIBLE_GREEN_GRIMOIRE] = include("scripts/items/collectibles/c098_green_grimoire/c098_green_grimoire_main"),
}

local modPickupVariant = tbom.modPickupVariant
tbom.Pickups = {
	--命名格式：pick[ID]_[名称]
	[modPickupVariant.PICKUP_MANA] = include("scripts/items/pick ups/pick2400_mana/pick2400_mana_main"),
	[modPickupVariant.PICKUP_GEL] = include("scripts/items/pick ups/pick2401_gel/pick2401_gel_main"),
}

local modTrinketType = tbom.modTrinketType
tbom.Trinkets = {
	--命名格式：t[ID]_[名称]
	[modTrinketType.TRINKET_ANOTHER_CARTRIDE] = include("scripts/items/trinkets/t001_another_cartride/t001_another_cartride_main"),
}

local modPlayerType = tbom.modPlayerType
tbom.Characters = {
	--命名格式：p[ID]_[名称]
	[modPlayerType.PLAYER_ORIGINAL] = include("scripts/characters/p000_original_characters/p000_original_characters_main"),
	[modPlayerType.PLAYER_ARLENADJA] = include("scripts/characters/p001_arle_nadja/p001_arle_nadja_main"),
}

local modChallenge = tbom.modChallenge
tbom.Challenges = {
	--命名格式：ch[ID]_[名称]
	[modChallenge.CHALLENGE_METEOR_SHOWER] = include("scripts/challenges/ch001_meteor_shower/ch001_meteor_shower_main"),
	[modChallenge.CHALLENGE_DESCENDING_INTO_PUYO_HELL] = include("scripts/challenges/ch002_descending_into_puyo_hell/ch002_descending_into_puyo_hell_main"),
}

tbom.CompatibleMods = include("compatible mods/main")

tbom.DebugConsole = include("scripts/debug_console")

TBOM = tbom

function tbom:TryReloadShaders()
	local players = Isaac.FindByType(EntityType.ENTITY_PLAYER)
    if #players <= 0 then
        Isaac.ExecuteCommand("reloadshaders")
    end
end
tbom:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, tbom.TryReloadShaders)

do
	print("[TBOM] The Binding of Madou v0.1.2 loaded.")
	------开发者专用------
	print("[TBOM] Developer only!!!")
	--"luamod the binding of madou_v0_1_2_dev"
	------
end