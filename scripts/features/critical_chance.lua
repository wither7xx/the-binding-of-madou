local CriticalChance = {}
local ModRef = tbom

local Common = tbom.Global.Common
local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths

local Fonts = tbom.Fonts
local modPlayerType = tbom.modPlayerType
local SpellContent = tbom.SpellContent
local MagicType = tbom.MagicType
local SpellType = tbom.SpellType
local Magic = tbom.Magic
local tbomCallbacks = tbom.tbomCallbacks
local modCollectibleType = tbom.modCollectibleType

function CriticalChance:PlayerDataInit(player, starting_crit_chance)
	local data = Tools:GetPlayerData(player)
	if data.CritChance == nil then
		data.CritChance = starting_crit_chance
	end
	if data.CritCacheAttribute == nil then
		data.CritCacheAttribute = {}
	end
end

function CriticalChance:ClearCritChanceData(player)
	local data = Tools:GetPlayerData(player)
	data.IsCritCharacter = nil		--角色是否启用暴击机制（逻辑）
	data.CritChance = nil			--暴击率（浮点数）
	data.CritCacheAttribute = nil	--暴击率加成缓存（散列表）
end

function CriticalChance:IsCritCharacter(player)
	local player_type = player:GetPlayerType()
	local data = Tools:GetPlayerData(player)
	return data.IsCritCharacter == true
		or player_type == modPlayerType.PLAYER_ARLENADJA 
		or player_type == modPlayerType.PLAYER_DOPPELGANGERARLE 
end

function CriticalChance:SetCritCharacter(player, value)
	local data = Tools:GetPlayerData(player)
	data.IsCritCharacter = value
end

function CriticalChance:TrySetCritCharacter(player, value)
	local data = Tools:GetPlayerData(player)
	if data.IsCritCharacter == nil then
		CriticalChance:SetCritCharacter(player, value)
	end
end

function CriticalChance:GetCritChance(player)
	local data = Tools:GetPlayerData(player)
	if data.CritChance then
		local CritChance = math.max(1, data.CritChance)
		if data.CritCacheAttribute then
			for i, chance in pairs(data.CritCacheAttribute) do
				CritChance = math.max(1, CritChance + chance)
			end
		end
		return CritChance
	end
	return 0
end

function CriticalChance:CritCache_AddAttribute(player, key, starting_value)
	local data = Tools:GetPlayerData(player)
	local CritCacheAttribute = data.CritCacheAttribute
	if CritCacheAttribute and CritCacheAttribute[key] == nil and type(key) == "string" and type(starting_value) == "number" then
		CritCacheAttribute[key] = starting_value
	end
end

function CriticalChance:CritCache_GetAttribute(player, key)
	local data = Tools:GetPlayerData(player)
	local CritCacheAttribute = data.CritCacheAttribute
	if CritCacheAttribute and type(key) == "string" then
		return CritCacheAttribute[key]
	end
	return nil
end

function CriticalChance:CritCache_SetAttribute(player, key, value)
	local data = Tools:GetPlayerData(player)
	local CritCacheAttribute = data.CritCacheAttribute
	if CritCacheAttribute and type(key) == "string" and type(value) == "number" then
		CritCacheAttribute[key] = value
	end
end

function CriticalChance:CritCache_ModifyAttribute(player, key, amount)
	local data = Tools:GetPlayerData(player)
	local CritCacheAttribute = data.CritCacheAttribute
	if CritCacheAttribute and type(key) == "string" and type(amount) == "number" then
		CritCacheAttribute[key] = CritCacheAttribute[key] + amount
	end
end

function CriticalChance:CritCache_ClearAttribute(player, key)
	local data = Tools:GetPlayerData(player)
	local CritCacheAttribute = data.CritCacheAttribute
	if CritCacheAttribute and type(key) == "string" and CritCacheAttribute[key] ~= nil then
		CritCacheAttribute[key] = nil
	end
end

function CriticalChance:PlayerDataUpdate(player)
	if CriticalChance:IsCritCharacter(player) then
		CriticalChance:CritCache_SetAttribute(player, "PlayerLuck", Maths:Fix_Round(player.Luck, 2))
		if player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM, false) then
			CriticalChance:CritCache_SetAttribute(player, "TeardropCharm", player:GetTrinketMultiplier(TrinketType.TRINKET_TEARDROP_CHARM) * 3)
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CriticalChance.PlayerDataUpdate, 0)

function CriticalChance:GetMaxCritChance()
	local NumPlayers = Game():GetNumPlayers()
	local MaxCritChance = 0
	for p = 0, NumPlayers - 1 do
		local player = Game():GetPlayer(p)
		if player and CriticalChance:IsCritCharacter(player) then
			local CritChance = CriticalChance:GetCritChance(player)
			if CritChance > MaxCritChance then
				MaxCritChance = CritChance
			end
		end
	end
	return MaxCritChance
end

local OnTakeDMG_DONE = false

function CriticalChance:OnTakeDMG(took_dmg, dmg_amount, dmg_flags, dmg_source, dmg_cd_frames)
	local MaxCritChance = CriticalChance:GetMaxCritChance()
	if took_dmg:IsVulnerableEnemy() and (not OnTakeDMG_DONE) then
		OnTakeDMG_DONE = true
		if Maths:RandomInt(100) + Maths:RandomFloat() < MaxCritChance then
			took_dmg:TakeDamage(dmg_amount, dmg_flags | DamageFlag.DAMAGE_IGNORE_ARMOR | DamageFlag.DAMAGE_CLONES, dmg_source, 0)
		end
		OnTakeDMG_DONE = false
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, CriticalChance.OnTakeDMG)

return CriticalChance