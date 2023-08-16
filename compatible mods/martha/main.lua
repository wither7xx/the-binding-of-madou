local CM_Martha = {}
local ModRef = tbom

local Hope = Martha.Collectibles.Hope
local Martha_player = Martha.Players.Martha
local MarthaB_player = Martha.Players.MarthaB

local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths
local Translation = tbom.Global.Translation

local tbomCallbacks = tbom.tbomCallbacks
local modCollectibleType = tbom.modCollectibleType
local modPlayerType = tbom.modPlayerType
local MagicType = tbom.MagicType
local SpellType = tbom.SpellType
local SpellContent = tbom.SpellContent
local Magic = tbom.Magic

local None = tbom.Spells[SpellType.SPELL_NONE]

function CM_Martha:CheckPlayerData(player)
	local player_type = player:GetPlayerType()
	if player_type  == Martha_player.ID then
		None:TryAddSimulatedSpell(player, SpellType.SPELL_HEAVEN_RAY)
	else
		None:TryRemoveSimulatedSpell(player, sim_spell_ID)
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CallbackPriority.EARLY, CM_Martha.CheckPlayerData, 0)

function CM_Martha:HopeChargeDataInit(player)
	local player_type = player:GetPlayerType()
	local key = "HopeCharge"
	if player_type == Martha_player.ID  then
		if not Magic:SPCharge_HasAttribute(player, key) then
			Magic:SPCharge_AddAttribute(player, key, 1)
			Magic:SPCharge_SetTopPriority(player, key)
		end
	else
		Magic:SPCharge_RemoveAttribute(player, key)
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CM_Martha.HopeChargeDataInit, 0)

local function IsHopeIconExisting()
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = Game():GetPlayer(p)
		local player_type = player:GetPlayerType()
		if player_type == Martha_player.ID then
			return true
		end
	end
	return false
end

function CM_Martha:MPIconOffsetUpdate(player)
	if IsHopeIconExisting() then
		local NumPlayers = Game():GetNumPlayers()
		for p = 0, NumPlayers - 1 do
			local player = Game():GetPlayer(p)
			if Tools:GetUserIdx(player) == 0 then
				Magic:AddMPIconAreaOffset(player, "HopeHUD", -4, 12)
			else
				Magic:RemoveMPIconAreaOffset(player, "HopeHUD")
			end
		end
	else
		Magic:RemoveMPIconAreaOffset(player, "HopeHUD")
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CM_Martha.MPIconOffsetUpdate, 0)

function CM_Martha:EID_OnRender()
	if EID then
		if EID.GameRenderCount % 30 ~= 0 then
			return
		end
		if IsHopeIconExisting() then
			EID:addTextPosModifier("HopeIcon", Vector(0, 20))
		else
			EID:removeTextPosModifier("HopeIcon")
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_RENDER, CM_Martha.EID_OnRender)

function CM_Martha:HopeChargeDataUpdate(player)
	local player_type = player:GetPlayerType()
	local key = "HopeCharge"
	if Magic:SPCharge_HasAttribute(player, key) then
		local charge_value = Hope:GetHope(player)
		local sp_value = Magic:SPCharge_GetValue(player, key)
		local sp_rate = Magic:SPCharge_GetExchangeRate(player, key)
		Magic:SPCharge_SetEffectiveMP(player, key, charge_value * sp_rate)
		Magic:SPCharge_SetValue(player, key, charge_value)
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CallbackPriority.LATE, CM_Martha.HopeChargeDataUpdate, 0)

function CM_Martha:HopeChargeDataDecrease(player, attribute_name, amount)
	local player_type = player:GetPlayerType()
	if attribute_name == "HopeCharge" then
		local key = attribute_name
		if Magic:SPCharge_HasAttribute(player, key) then
			local sp_value_prev = Magic:SPCharge_GetValue(player, key)
			local sp_rate = Magic:SPCharge_GetExchangeRate(player, key)
			local sp_effective = Magic:SPCharge_GetEffectiveMP(player, key)
			local modified_value = math.floor(Maths:Fix_Round(sp_effective - amount, 1) / sp_rate)
			Hope:CostHope(player, sp_value_prev - modified_value)
		end
	end
end
ModRef:AddPriorityCallback(tbomCallbacks.TBOMC_POST_COST_SPCHARGE, CallbackPriority.IMPORTANT, CM_Martha.HopeChargeDataDecrease)

function CM_Martha:HeavenRay_OnUse(sim_spell_ID, rng, player, use_flag)
	Hope:CastHolyLight(player, Game():GetRoom():GetRandomPosition(40), false)	
	player:UseActiveItem(CollectibleType.COLLECTIBLE_CRACK_THE_SKY, UseFlag.USE_NOANIM)

	local texts = {["en"] = "Heaven Ray", ["zh"] = "天界射线"}
	local lang_fixed = Translation:FixLanguage(Options.Language)
	local HUD = Game():GetHUD()
	HUD:ShowItemText(texts[lang_fixed], "")

	if Tools:CanAddWisp(player, use_flag) then
		player:AddWisp(CollectibleType.COLLECTIBLE_CRACK_THE_SKY, player.Position)			
	end
end
ModRef:AddCallback(tbomCallbacks.TBOMC_POST_USE_SIM_SPELL, CM_Martha.HeavenRay_OnUse, SpellType.SPELL_HEAVEN_RAY)

return CM_Martha