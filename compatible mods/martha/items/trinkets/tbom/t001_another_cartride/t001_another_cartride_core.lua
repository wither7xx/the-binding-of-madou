local CM_AnotherCartride_META = {
	__index = {},
}
local CM_AnotherCartride = CM_AnotherCartride_META.__index

local modTrinketType = tbom.modTrinketType
local AnotherCartride = tbom.Trinkets[modTrinketType.TRINKET_ANOTHER_CARTRIDE]
local ModRef = tbom

local Tools = tbom.Global.Tools

local MarthaPlayerType = tbom.CM_MarthaPlayerType

local Hope = Martha.Collectibles.Hope
local Martha_Character = Martha.Players.Martha

local function CM_Martha_GetAnotherCartrideData(player)
	local data = Tools:GetPlayerTrinketData(player, modTrinketType.TRINKET_ANOTHER_CARTRIDE)
	data.CM_Martha_Data = data.CM_Martha_Data or {}
	return data.CM_Martha_Data
end

function CM_AnotherCartride:AnotherCartrideDataInit(player)
	local data = CM_Martha_GetAnotherCartrideData(player)
	if data.Hope == nil then
		data.Hope = 0
	end
	if data.BlastCooldown == nil then
		data.BlastCooldown = 0
	end
	if data.IsUsingMarthaData == nil then
		data.IsUsingMarthaData = false
	end
end

function CM_AnotherCartride:GetHope(player)
	local data = CM_Martha_GetAnotherCartrideData(player)
	return data.Hope or 0
end

function CM_AnotherCartride:GetBlastCooldown(player)
	local data = CM_Martha_GetAnotherCartrideData(player)
	return data.BlastCooldown or 0
end

function CM_AnotherCartride:IsUsingMarthaData(player)
	local data = CM_Martha_GetAnotherCartrideData(player)
	return data.IsUsingMarthaData
end

function CM_AnotherCartride:SetIfUsingMarthaData(player, value)
	local data = CM_Martha_GetAnotherCartrideData(player)
	data.IsUsingMarthaData = value
end

function CM_AnotherCartride:TryUpdateMarthaData(player)
	local data = CM_Martha_GetAnotherCartrideData(player)
	if not data.IsUsingMarthaData then
		data.Hope = Hope:GetHope(player)
		local martha_data = Martha:GetMarthaData(player)
		if martha_data and martha_data.BlastCooldown then
			data.BlastCooldown = martha_data.BlastCooldown
		end
	end
end

return CM_AnotherCartride_META