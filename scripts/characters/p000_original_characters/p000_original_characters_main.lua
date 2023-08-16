local Original = {}
local ModRef = tbom

local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths

local tbomCallbacks = tbom.tbomCallbacks
local modCollectibleType = tbom.modCollectibleType
local modPlayerType = tbom.modPlayerType
local MagicType = tbom.MagicType
local SpellType = tbom.SpellType
local SpellContent = tbom.SpellContent
local Magic = tbom.Magic

function Original:CheckPlayerData(player)
	--注：Game.TimeCounter只能决定是否开启BossRush，不能决定是否开启凹凸层；后者应由一个单独的计时器决定
	--注2：若想测试某时间点是否开启凹凸层，可直接修改Game.BlueWombParTime规定的时间；这一操作最好用ModCallbacks.MC_POST_PLAYER_UPDATE回调，因为这个值随时都会刷新回54000
	if Tools:IsOriginalCharacter(player) or (not Magic:IsMageCharacter(player)) then
		Magic:PlayerDataInit(player, 5, 15, 5)
		Magic:TryAddSpell(player, SpellType.SPELL_NONE, 1, true)
		local player_type = player:GetPlayerType()
		if player_type == PlayerType.PLAYER_BETHANY then
			Magic:Spell_SetAttribute(player, SpellType.SPELL_NONE, "UseLightSpellName", true)
			Magic:Spell_SetAttribute(player, SpellType.SPELL_NONE, "UseDarkSpellName", false)
			Magic:Spell_SetAttribute(player, SpellType.SPELL_NONE, "UseShadowSpellName", false)
		elseif player_type == PlayerType.PLAYER_BETHANY_B then
			Magic:Spell_SetAttribute(player, SpellType.SPELL_NONE, "UseLightSpellName", false)
			Magic:Spell_SetAttribute(player, SpellType.SPELL_NONE, "UseDarkSpellName", true)
			Magic:Spell_SetAttribute(player, SpellType.SPELL_NONE, "UseShadowSpellName", false)
		elseif player_type == PlayerType.PLAYER_JUDAS 
			or player_type == PlayerType.PLAYER_BLACKJUDAS 
			or player_type == PlayerType.PLAYER_JUDAS_B then
			Magic:Spell_SetAttribute(player, SpellType.SPELL_NONE, "UseLightSpellName", false)
			Magic:Spell_SetAttribute(player, SpellType.SPELL_NONE, "UseDarkSpellName", true)
			Magic:Spell_SetAttribute(player, SpellType.SPELL_NONE, "UseShadowSpellName", false)
		elseif player_type == PlayerType.PLAYER_LILITH 
			or player_type == PlayerType.PLAYER_LILITH_B then
			Magic:Spell_SetAttribute(player, SpellType.SPELL_NONE, "UseLightSpellName", false)
			Magic:Spell_SetAttribute(player, SpellType.SPELL_NONE, "UseDarkSpellName", false)
			Magic:Spell_SetAttribute(player, SpellType.SPELL_NONE, "UseShadowSpellName", true)
		else
			Magic:Spell_SetAttribute(player, SpellType.SPELL_NONE, "UseLightSpellName", false)
			Magic:Spell_SetAttribute(player, SpellType.SPELL_NONE, "UseDarkSpellName", false)
			Magic:Spell_SetAttribute(player, SpellType.SPELL_NONE, "UseShadowSpellName", false)
		end

		--if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
		--	Magic:MPCapCache_SetAttribute(player, "Battery", 15)
		--else
		--	Magic:MPCapCache_ClearAttribute(player, "Battery")
		--end
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CallbackPriority.EARLY, Original.CheckPlayerData, 0)

function Original:MPIconOffsetUpdate(player)
	local player_type = player:GetPlayerType()
	local UserIdx = Tools:GetUserIdx(player)
	if UserIdx == 0 then
		if player_type == PlayerType.PLAYER_ISAAC_B or player_type == PlayerType.PLAYER_BLUEBABY_B then
			Magic:AddMPIconAreaOffset(player, "IventoryHUD", 0, 24)
		else
			Magic:RemoveMPIconAreaOffset(player, "IventoryHUD")
		end
		if player_type == PlayerType.PLAYER_JACOB then
			Magic:AddMPIconAreaOffset(player, "JacobHUD", 0, 14)
		else
			Magic:RemoveMPIconAreaOffset(player, "JacobHUD")
		end
		if player_type == PlayerType.PLAYER_ESAU then
			Magic:AddMPIconAreaOffset(player, "EsauHUD", 0, 26)
		else
			Magic:RemoveMPIconAreaOffset(player, "EsauHUD")
		end
	elseif UserIdx == 1 then
		if player_type == PlayerType.PLAYER_ESAU then
			Magic:AddMPIconAreaOffset(player, "EsauHUD", 0, 12)
		else
			Magic:RemoveMPIconAreaOffset(player, "EsauHUD")
		end
	else
		if player_type == PlayerType.PLAYER_JACOB then
			Magic:AddMPIconAreaOffset(player, "JacobHUD", 0, -12)
		else
			Magic:RemoveMPIconAreaOffset(player, "JacobHUD")
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Original.MPIconOffsetUpdate, 0)

function Original:SoulChargeDataInit(player)
	local player_type = player:GetPlayerType()
	local key = "SoulCharge"
	if player_type == PlayerType.PLAYER_BETHANY then
		Magic:SPCharge_AddAttribute(player, key, 1)
	else
		Magic:SPCharge_RemoveAttribute(player, key)
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Original.SoulChargeDataInit, 0)

function Original:SoulChargeDataUpdate(player)
	local key = "SoulCharge"
	if Magic:SPCharge_HasAttribute(player, key) then
		local charge_value = player:GetEffectiveSoulCharge()
		local sp_value = Magic:SPCharge_GetValue(player, key)
		local sp_rate = Magic:SPCharge_GetExchangeRate(player, key)
		Magic:SPCharge_SetEffectiveMP(player, key, charge_value * sp_rate)
		Magic:SPCharge_SetValue(player, key, charge_value)
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CallbackPriority.LATE, Original.SoulChargeDataUpdate, 0)

function Original:SoulChargeDataDecrease(player, attribute_name, amount)
	local player_type = player:GetPlayerType()
	if attribute_name == "SoulCharge" then
		local key = attribute_name
		if Magic:SPCharge_HasAttribute(player, key) then
			local sp_rate = Magic:SPCharge_GetExchangeRate(player, key)
			local sp_effective = Magic:SPCharge_GetEffectiveMP(player, key)
			local modified_value = math.floor(Maths:Fix_Round(sp_effective - amount, 1) / sp_rate)
			player:SetSoulCharge(modified_value)
		end
	end
end
ModRef:AddPriorityCallback(tbomCallbacks.TBOMC_POST_COST_SPCHARGE, CallbackPriority.IMPORTANT, Original.SoulChargeDataDecrease)

function Original:BloodChargeDataInit(player)
	local player_type = player:GetPlayerType()
	local key = "BloodCharge"
	if player_type == PlayerType.PLAYER_BETHANY_B then
		Magic:SPCharge_AddAttribute(player, key, 1)
	else
		Magic:SPCharge_RemoveAttribute(player, key)
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Original.BloodChargeDataInit, 0)

function Original:BloodChargeDataUpdate(player)
	local key = "BloodCharge"
	if Magic:SPCharge_HasAttribute(player, key) then
		local charge_value = player:GetEffectiveBloodCharge()
		local sp_value = Magic:SPCharge_GetValue(player, key)
		local sp_rate = Magic:SPCharge_GetExchangeRate(player, key)
		Magic:SPCharge_SetEffectiveMP(player, key, charge_value * sp_rate)
		Magic:SPCharge_SetValue(player, key, charge_value)
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CallbackPriority.LATE, Original.BloodChargeDataUpdate, 0)

function Original:BloodChargeDataDecrease(player, attribute_name, amount)
	local player_type = player:GetPlayerType()
	if attribute_name == "BloodCharge" then
		local key = attribute_name
		if Magic:SPCharge_HasAttribute(player, key) then
			local sp_rate = Magic:SPCharge_GetExchangeRate(player, key)
			local sp_effective = Magic:SPCharge_GetEffectiveMP(player, key)
			local modified_value = math.floor(Maths:Fix_Round(sp_effective - amount, 1) / sp_rate)
			player:SetBloodCharge(modified_value)
		end
	end
end
ModRef:AddPriorityCallback(tbomCallbacks.TBOMC_POST_COST_SPCHARGE, CallbackPriority.IMPORTANT, Original.BloodChargeDataDecrease)

return Original