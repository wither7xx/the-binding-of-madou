local Gel_META = {
	__index = setmetatable({}, include("scripts/items/pick ups/pick2401_gel/pick2401_gel_constants")),
}
local Gel = Gel_META.__index

local Common = tbom.Global.Common
local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths
local Translation = tbom.Global.Translation

local modPickupVariant = tbom.modPickupVariant
local modSoundEffect = tbom.modSoundEffect

local GelNumIndexList = Gel.GelNumIndexList
local GelCacheFlagList = Gel.GelCacheFlagList

local Puyo = include("scripts/monsters/e305_puyo/e305_puyo_api")

local function GetGelData(player)
	return Tools:GetPlayerPickupData(player, modPickupVariant.PICKUP_GEL)
end

function Gel:PlayerDataInit(player)
	local data = GetGelData(player)
	if data.GelNumList == nil then
		data.GelNumList = {
			Green = 0,
			Purple = 0,
			Red = 0,
			Yellow = 0,
			Blue = 0,
		}
	end
	if data.GelStatsMultiCache == nil then
		data.GelStatsMultiCache = {}
	end
end

function Gel:GetGelNumList(player)
	local data = GetGelData(player)
	return data.GelNumList
end

function Gel:GetGelNum(player, gel_subtype)
	local data = GetGelData(player)
	local idx = GelNumIndexList[gel_subtype]
	if data.GelNumList and idx then
		return data.GelNumList[idx] or 0
	end
	return 0
end

function Gel:SetGelNum(player, gel_subtype, value)
	local data = GetGelData(player)
	local idx = GelNumIndexList[gel_subtype]
	if data.GelNumList and idx then
		data.GelNumList[idx] = math.max(0, value)
	end
end

function Gel:ModifyGelNum(player, gel_subtype, amount)
	local data = GetGelData(player)
	local idx = GelNumIndexList[gel_subtype]
	if data.GelNumList and idx then
		data.GelNumList[idx] = math.max(0, data.GelNumList[idx] + amount)
	end
end
--[[
function Gel:AddGelStatsMultiCache(player, key, amount)
	local data = GetGelData(player)
	if data.GelStatsMultiCache then
		if data.GelStatsMultiCache[key] == nil then
			data.GelStatsMultiCache[key] = amount
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_LUCK)
			player:EvaluateItems()
		end
	end
end
]]
function Gel:AddGelStatsMultiCache(player, key, value)
	local data = GetGelData(player)
	if data.GelStatsMultiCache then
		if data.GelStatsMultiCache[key] ~= value then
			data.GelStatsMultiCache[key] = value
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_LUCK)
			player:EvaluateItems()
		end
	end
end

function Gel:ClearGelStatsMultiCache(player, key)
	local data = GetGelData(player)
	if data.GelStatsMultiCache then
		if data.GelStatsMultiCache[key] ~= nil then
			data.GelStatsMultiCache[key] = nil
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_LUCK)
			player:EvaluateItems()
		end
	end
end

function Gel:GetGelStatsMulti(player)
	local data = GetGelData(player)
	local multi = 1
	if data.GelStatsMultiCache then
		for _, value in pairs(data.GelStatsMultiCache) do
			multi = multi * value
		end
	end
	return multi
end

function Gel:GetGelSFX()
	local game = Game()
	local difficulty = game.Difficulty
	if not (difficulty == Difficulty.DIFFICULTY_NORMAL or difficulty == Difficulty.DIFFICULTY_GREED) then
		local puyo_skill_type = Puyo:GetSkillTypeByCurrentStage()
		local PuyoSkillType = Puyo.PuyoSkillType
		local sfx_list = {
			[PuyoSkillType.SKILL_WINCHESTER] = modSoundEffect.SOUND_GEL_GET_ARCADE_1,
			[PuyoSkillType.SKILL_KNIFE] = modSoundEffect.SOUND_GEL_GET_ARCADE_1,
			[PuyoSkillType.SKILL_DARTS] = modSoundEffect.SOUND_GEL_GET_ARCADE_2,
			[PuyoSkillType.SKILL_BOOMERANG] = modSoundEffect.SOUND_GEL_GET_ARCADE_1,
			[PuyoSkillType.SKILL_DYNAMITE] = modSoundEffect.SOUND_GEL_GET_ARCADE_1,
			[PuyoSkillType.SKILL_SHOT_GUN] = modSoundEffect.SOUND_GEL_GET_ARCADE_3,
			[PuyoSkillType.SKILL_DOUBLE_RIFLE] = modSoundEffect.SOUND_GEL_GET_ARCADE_1,
			[PuyoSkillType.SKILL_DOUBLE_PISTOL] = modSoundEffect.SOUND_GEL_GET_ARCADE_2,
			[PuyoSkillType.SKILL_MACHINE_GUN] = modSoundEffect.SOUND_GEL_GET_ARCADE_1,
			[PuyoSkillType.SKILL_RIFLE] = modSoundEffect.SOUND_GEL_GET_ARCADE_2,
		}
		if sfx_list[puyo_skill_type] then
			return sfx_list[puyo_skill_type]
		end
	end
	return modSoundEffect.SOUND_GEL_GET
end

return Gel_META