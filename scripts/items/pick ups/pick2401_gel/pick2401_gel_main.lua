local Gel = {}
local ModRef = tbom

local Common = tbom.Global.Common
local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths
local Translation = tbom.Global.Translation

local modEffectVariant = tbom.modEffectVariant
local modEntityType = tbom.modEntityType
local modPlayerType = tbom.modPlayerType
local modPickupVariant = tbom.modPickupVariant
local modCollectibleType = tbom.modCollectibleType
local modSoundEffect = tbom.modSoundEffect
local PuyoVariant = tbom.PuyoVariant
local GelSubType = tbom.GelSubType
local tbomCallbacks = tbom.tbomCallbacks
local Magic = tbom.Magic
local LevelExp = tbom.LevelExp
local CriticalChance = tbom.CriticalChance

local function GetGelData(player)
	--local data = Tools:GetPlayerData(player)
	--data.GelData = data.GelData or {}
	--return data.GelData
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
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Gel.PlayerDataInit, 0)

function Gel:GetGelNumList(player)
	local data = GetGelData(player)
	return data.GelNumList
end

local GelNumIndexList = {
	[GelSubType.GEL_GREEN] = "Green",
	[GelSubType.GEL_PURPLE] = "Purple",
	[GelSubType.GEL_RED] = "Red",
	[GelSubType.GEL_YELLOW] = "Yellow",
	[GelSubType.GEL_BLUE] = "Blue",
}

local GelCacheFlagList = {
	[GelSubType.GEL_PURPLE] = CacheFlag.CACHE_LUCK,
	[GelSubType.GEL_RED] = CacheFlag.CACHE_DAMAGE,
	[GelSubType.GEL_YELLOW] = CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SPEED,
	[GelSubType.GEL_BLUE] = CacheFlag.CACHE_FIREDELAY,
}

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

function Gel:PrePickupCollision(pickup, other, collides_other_first)
	if other.Type == 1 and other.Variant == 0 then
		local player = other:ToPlayer()
		if not pickup.Touched then
			local gel_subtype = pickup.SubType
			Gel:ModifyGelNum(player, gel_subtype, 1)
			local caflag = GelCacheFlagList[gel_subtype]
			if caflag then
				player:AddCacheFlags(caflag)
				player:EvaluateItems()
			end
			SFXManager():Play(modSoundEffect.SOUND_GEL_GET)
			Tools:PlayUniqueAnimation(pickup, "Collect")
			pickup:Remove()
			pickup.Touched = true
			return true
		else
			return true
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Gel.PrePickupCollision, modPickupVariant.PICKUP_GEL)

function Gel:OnTakeDamage(took_dmg, dmg_amount, dmg_flags, dmg_source, dmg_cd_frames)
	local player = took_dmg:ToPlayer()
	if player and (not Tools:IsSelfDamage(dmg_flags)) then
		if Gel:GetGelNum(player, GelSubType.GEL_GREEN) > 0 then
			Gel:ModifyGelNum(player, GelSubType.GEL_GREEN, -1)
		else
			for gel_subtype, caflag in pairs(GelCacheFlagList) do
				Gel:ModifyGelNum(player, gel_subtype, -1)
				player:AddCacheFlags(caflag)
				player:EvaluateItems()
			end
		end
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, Gel.OnTakeDamage, EntityType.ENTITY_PLAYER)

function Gel:EvaluateCache(player, caflag)
	if caflag == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage + 0.1 * Gel:GetGelNum(player, GelSubType.GEL_RED)
	end
	if caflag == CacheFlag.CACHE_FIREDELAY then
		player.MaxFireDelay = (30 / (30 / (player.MaxFireDelay + 1) + 0.05 * Gel:GetGelNum(player, GelSubType.GEL_BLUE)) - 1)
	end
	if caflag == CacheFlag.CACHE_RANGE then
		player.TearRange = player.TearRange + 10 * Gel:GetGelNum(player, GelSubType.GEL_YELLOW)
	end
	if caflag == CacheFlag.CACHE_SPEED then
		player.MoveSpeed = player.MoveSpeed + 0.02 * Gel:GetGelNum(player, GelSubType.GEL_YELLOW)
	end
	if caflag == CacheFlag.CACHE_LUCK then
		player.Luck = player.Luck + 0.1 * Gel:GetGelNum(player, GelSubType.GEL_PURPLE)
	end
end
ModRef:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Gel.EvaluateCache)
--[[
function Gel:OnRender(player, offset)
	--µ÷ÊÔ×¨ÓÃ
	local font = tbom.Fonts[Options.Language] or tbom.Fonts["en"]
	local texts = {
		[1] = "Green Gel Num: ".. tostring(Gel:GetGelNum(player, GelSubType.GEL_GREEN)),
		[2] = "Puyo Combo: " .. tostring(Tools:GameData_GetAttribute("PuyoComboInCurrentRoom"))
	}
	local pos = Tools:GetEntityRenderScreenPos(player)
	for i = 1, #texts do
		font:DrawStringUTF8(texts[i], pos.X - 200, pos.Y - 5 * #texts + i * 15, KColor(1, 1, 1, 0.8), 400, true)
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, Gel.OnRender)
]]
return Gel