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

HeartShapedCookie.SelfHurtingCharacter = {}

function HeartShapedCookie:IsSelfHurtingCharacter(player_type)
	for i, config in pairs(self.SelfHurtingCharacter) do
		if config.Type == player_type then
			return true
		end
	end
	return false
end

function HeartShapedCookie:GetHurtChance(player_type)
	for i, config in pairs(self.SelfHurtingCharacter) do
		if config.Type == player_type then
			return config.HurtChance
		end
	end
	return 0
end

function HeartShapedCookie:AddSelfHurtingCharacter(player_type, hurt_chance)
	hurt_chance = hurt_chance or 50
	hurt_chance = math.max(0, math.min(hurt_chance, 100))
	if not HeartShapedCookie:IsSelfHurtingCharacter(player_type) then
		local config = {Type = player_type, HurtChance = hurt_chance,}
		table.insert(self.SelfHurtingCharacter, config)
	end
end

return HeartShapedCookie_META