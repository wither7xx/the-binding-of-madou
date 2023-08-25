local HeartShapedCookie_META = {
	__index = {},
}
local HeartShapedCookie = HeartShapedCookie_META.__index
local ModRef = tbom

local Common = tbom.Global.Common
local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths
local Translation = tbom.Global.Translation

local tbomCallbacks = tbom.tbomCallbacks
local modCollectibleType = tbom.modCollectibleType

local function GetHeartShapedCookieGlobalData()
	return Tools:Global_GetCollectibleData(modCollectibleType.COLLECTIBLE_HEART_SHAPED_COOKIE)
end

function HeartShapedCookie:GetSelfHurtingCharacterList()
	local data = GetHeartShapedCookieGlobalData()
	data.HurtingCharacterList = data.HurtingCharacterList or {}
	return data.HurtingCharacterList
end

function HeartShapedCookie:IsSelfHurtingCharacter(player_type)
	local self_hurting_character_list = HeartShapedCookie:GetSelfHurtingCharacterList()
	for _, config in pairs(self_hurting_character_list) do
		if config.Type == player_type then
			return true
		end
	end
	return false
end

function HeartShapedCookie:GetHurtChance(player_type)
	local self_hurting_character_list = HeartShapedCookie:GetSelfHurtingCharacterList()
	for _, config in pairs(self_hurting_character_list) do
		if config.Type == player_type then
			return config.HurtChance
		end
	end
	return 0
end

function HeartShapedCookie:AddSelfHurtingCharacter(player_type, hurt_chance)
	hurt_chance = hurt_chance or 50
	hurt_chance = math.max(0, math.min(hurt_chance, 100))
	local self_hurting_character_list = HeartShapedCookie:GetSelfHurtingCharacterList()
	if not HeartShapedCookie:IsSelfHurtingCharacter(player_type) then
		local config = {Type = player_type, HurtChance = hurt_chance,}
		table.insert(self_hurting_character_list, config)
	end
end

return HeartShapedCookie_META