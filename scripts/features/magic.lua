local Magic = {}
local ModRef = tbom

local Common = tbom.Global.Common
local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths
local Translation = tbom.Global.Translation

local Fonts = tbom.Fonts
local modPlayerType = tbom.modPlayerType
local SpellContent = tbom.SpellContent
local MagicType = tbom.MagicType
local SpellType = tbom.SpellType
local KeyConfig = tbom.KeyConfig
local tbomCallbacks = tbom.tbomCallbacks
local modCollectibleType = tbom.modCollectibleType

Magic.MagicFlag = {
	FLAG_CANNOT_SWITCH_SPELL = (1 << 0),
	FLAG_NUMBER_KEY_DISABLED = (1 << 1),
}
local MagicFlag = Magic.MagicFlag

function Magic:IsValidSpell(spell_ID)
	return spell_ID ~= SpellType.SPELL_INVALID
end

function Magic:GetGlobalSpellIdList()
	local list = {}
	for i, ID in pairs(SpellType) do
		if Magic:IsValidSpell(ID) then
			table.insert(list, ID)
		end
	end
	return list
end

function Magic:GetMagicType(spell_ID)
	if SpellContent[spell_ID] and SpellContent[spell_ID].Type then
		return SpellContent[spell_ID].Type
	end
	return MagicType.NONE
end

function Magic:GetName(spell_ID, lang)
	local lang_fixed = Translation:FixLanguage(lang)
	if SpellContent[spell_ID] and SpellContent[spell_ID].Name then
		return SpellContent[spell_ID].Name[lang_fixed] or ""
	end
	return ""
end

function Magic:GetDesc(spell_ID, lang)
	local lang_fixed = Translation:FixLanguage(lang)
	if SpellContent[spell_ID] and SpellContent[spell_ID].Desc then
		return SpellContent[spell_ID].Desc[lang_fixed] or ""
	end
	return ""
end

function Magic:GetActualName(player, spell_ID, lang)		--此处特别注意，要额外传一个player参数进去
	if not Magic:IsSpellUnlocked(player, spell_ID) then
		if not Magic:IsSpellAllowed(player, spell_ID) then
			return ""
		else
			return "???"
		end
	end
	return Magic:GetName(spell_ID, lang)
end

function Magic:GetActualDesc(player, spell_ID, lang)		--此处特别注意，要额外传一个player参数进去
	local lang_fixed = Translation:FixLanguage(lang)
	local CD = math.ceil(Magic:GetSpellCD(player, spell_ID) / 60)
	local forbidden_text = {
		["en"] = "Not allowed in this challenge",
		["zh"] = "本挑战不允许",
	}
	local recharging_text = {
		["en"] = "Recharging... ",
		["zh"] = "恢复中... ",
	}
	if not Magic:IsSpellAllowed(player, spell_ID) then
		if Magic:IsSpellUnlocked(player, spell_ID) then
			return forbidden_text[lang_fixed]
		else
			return ""
		end
	else
		if not Magic:IsSpellUnlocked(player, spell_ID) then
			return ""
		elseif not Magic:IsSpellRecharged(player, spell_ID, false) then
			return (recharging_text[lang_fixed])..tostring(CD)
		end
	end
	return Magic:GetDesc(spell_ID, lang)
end

function Magic:GetGFX(spell_ID)
	if SpellContent[spell_ID] and SpellContent[spell_ID].GFX then
		return SpellContent[spell_ID].GFX
	end
	return "gfx/blank.png"
end

function Magic:GetCost(spell_ID)
	if SpellContent[spell_ID] and SpellContent[spell_ID].Cost then
		return SpellContent[spell_ID].Cost
	end
	return 0
end

function Magic:GetMaxReberu(spell_ID)
	if SpellContent[spell_ID] and SpellContent[spell_ID].MaxReberu then
		return SpellContent[spell_ID].MaxReberu
	end
	return 1
end

function Magic:GetMinChargeReberu(spell_ID)
	if SpellContent[spell_ID] and SpellContent[spell_ID].MinChargeReberu then
		return SpellContent[spell_ID].MinChargeReberu
	end
	return nil
end

function Magic:GetMaxCharge(spell_ID, reberu)
	--print(spell_ID)
	if SpellContent[spell_ID] and SpellContent[spell_ID].MaxCharge then
		--print("point 1")
		if type(SpellContent[spell_ID].MaxCharge) == "number" then
		--	print("point 2")
		--	print(SpellContent[spell_ID].MaxCharge)
			return SpellContent[spell_ID].MaxCharge
		elseif type(SpellContent[spell_ID].MaxCharge) == "table" and reberu then
		--	print("point 3")
			return SpellContent[spell_ID].MaxCharge[reberu]
		end
	end
	--print("point 4")
	return nil
end

function Magic:GetBurstingTime(spell_ID, reberu)
	if SpellContent[spell_ID] and SpellContent[spell_ID].BurstingTime then
		if type(SpellContent[spell_ID].BurstingTime) == "number" then
			return SpellContent[spell_ID].BurstingTime
		elseif type(SpellContent[spell_ID].BurstingTime) == "table" and reberu then
			return SpellContent[spell_ID].BurstingTime[reberu]
		end
	end
	return nil
end

function Magic:GetOverHeatCD(spell_ID, reberu)
	if SpellContent[spell_ID] and SpellContent[spell_ID].OverHeatCD then
		if type(SpellContent[spell_ID].OverHeatCD) == "number" then
			return SpellContent[spell_ID].OverHeatCD
		elseif type(SpellContent[spell_ID].OverHeatCD) == "table" and reberu then
			return SpellContent[spell_ID].OverHeatCD[reberu]
		end
	end
	return nil
end

function Magic:GetMaxCD(spell_ID)
	if SpellContent[spell_ID] and SpellContent[spell_ID].MaxCD then
		return SpellContent[spell_ID].MaxCD
	end
	return 0
end

function Magic:GetFormalCD(spell_ID)
	if SpellContent[spell_ID] then
		if SpellContent[spell_ID].FormalCD then
			return SpellContent[spell_ID].FormalCD
		elseif SpellContent[spell_ID].MaxCD then
			return SpellContent[spell_ID].MaxCD
		end
	end
	return 0
end


function Magic:GetMaxTargetNum(spell_ID)
	if SpellContent[spell_ID] and SpellContent[spell_ID].MaxTargetNum then
		return SpellContent[spell_ID].MaxTargetNum
	end
	return 0
end

function Magic:GetDMGMulti(spell_ID)
	if SpellContent[spell_ID] and SpellContent[spell_ID].DMGMulti then
		return SpellContent[spell_ID].DMGMulti
	end
	return 1
end

function Magic:PostSpellUpdate(player)
	local CurrentSpellID = Magic:GetCurrentSpellId(player)
	local IsUsingCurrentSpell = Magic:IsUsingSpell(player, CurrentSpellID)
	local CanToggle = Magic:CanToggleSpell(player, CurrentSpellID, false)
	if (not CanToggle) and IsUsingCurrentSpell then
		Magic:TryDisableSpell(player, CurrentSpellID, UseFlag.USE_OWNED, Magic:GetSpellRNG(player, CurrentSpellID))
	end

	local list = Magic:GetSpellIdList(player)
	for i, spell_ID in pairs(list) do
		local SpellMagicType = Magic:GetMagicType(spell_ID)
		Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_SPELL_UPDATE_BASE, SpellMagicType, spell_ID, player)
		Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_SPELL_UPDATE, spell_ID, spell_ID, player)
	end
end
--ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Magic.PostSpellUpdate)		--已弃用：ModCallbacks.MC_POST_PLAYER_UPDAT的速度要快一倍
ModRef:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Magic.PostSpellUpdate)

function Magic:ModifyMadouRyoku(player, amount, ignore_sp_charge)
	if ignore_sp_charge == nil then
		ignore_sp_charge = false
	end
	local data = Tools:GetPlayerData(player)
	if amount >= 0 then
		data.MadouRyoku = math.min(Magic:GetMadouJyougen(player), data.MadouRyoku + amount)
	elseif not Magic:HasInfiniteMP(player) then
		if not ignore_sp_charge then
			local fixed_amount = Maths:Fix_Round(math.abs(amount), 1)
			local mp_cost_amount = math.min(data.MadouRyoku, fixed_amount)
			data.MadouRyoku = math.max(0, data.MadouRyoku - mp_cost_amount)
			local sp_cost_amount = math.max(0, fixed_amount - mp_cost_amount)
			local SPChargeData = data.SPChargeData
			local SPChargePriority = data.SPChargePriority
			if SPChargeData and SPChargeData ~= {} then
				if sp_cost_amount > 0 then
					for i, key in pairs(SPChargePriority) do
						if SPChargeData[key] and SPChargeData[key].EffectiveMP then
							local EffectiveMP = SPChargeData[key].EffectiveMP
							local dif = sp_cost_amount - EffectiveMP
							if dif > 0 then
								Isaac.RunCallback(tbomCallbacks.TBOMC_POST_COST_SPCHARGE, player, key, EffectiveMP)
								sp_cost_amount = dif
							else
								Isaac.RunCallback(tbomCallbacks.TBOMC_POST_COST_SPCHARGE, player, key, sp_cost_amount)
								break
							end
						end
					end
				end
			end
		else
			data.MadouRyoku = math.max(0, data.MadouRyoku + amount)
		end
	end
end

function Magic:CostDefaultMadouRyoku(player, spell_ID, ignore_sp_charge)
	local cost = Magic:GetCost(spell_ID)
	Magic:ModifyMadouRyoku(player, -cost, ignore_sp_charge)
end

function Magic:GetMadouRyoku(player)
	local data = Tools:GetPlayerData(player)
	return data.MadouRyoku or 5
end

function Magic:SetMadouRyoku(player, value)
	local data = Tools:GetPlayerData(player)
	if value >= 0 then
		data.MadouRyoku = math.min(data.MadouJyougen, value)
	else
		data.MadouRyoku = 0
	end
end

function Magic:FullMadouRyoku(player)
	local value = Magic:GetMadouJyougen(player)
	Magic:SetMadouRyoku(player, value)
end

function Magic:GetMadouJyougen(player)
	local data = Tools:GetPlayerData(player)
	if data.MadouJyougen then
		local MadouJyougen = math.max(0, data.MadouJyougen)
		if data.MPCapCacheAttribute then
			for i, attribute in pairs(data.MPCapCacheAttribute) do
				MadouJyougen = MadouJyougen + Maths:Fix_Round(attribute, 1)
			end
		end
		return MadouJyougen 
	end
	return 10
end

function Magic:ModifyMadouJyougen(player, amount)
	local data = Tools:GetPlayerData(player)
	data.MadouJyougen = math.max(0, data.MadouJyougen + amount)
end

function Magic:SetMadouJyougen(player, value)
	local data = Tools:GetPlayerData(player)
	data.MadouJyougen = math.max(0, value)
end

function Magic:MadouRyokuUpdate(player)
	local data = Tools:GetPlayerData(player)
	if data.MadouRyoku and data.MadouJyougen then
		data.MadouRyoku = math.max(0, Maths:Fix_Round(data.MadouRyoku, 1))
		data.MadouJyougen = math.max(Maths:Fix_Round(data.MadouJyougen, 1))
		if data.MadouRyoku > Magic:GetMadouJyougen(player) then
			data.MadouRyoku = Magic:GetMadouJyougen(player)
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Magic.MadouRyokuUpdate)

function Magic:MPCapCache_AddAttribute(player, key, starting_value)
	local data = Tools:GetPlayerData(player)
	local MPCapCacheAttribute = data.MPCapCacheAttribute
	if MPCapCacheAttribute and MPCapCacheAttribute[key] == nil and type(key) == "string" and type(starting_value) == "number" then
		MPCapCacheAttribute[key] = starting_value
	end
end

function Magic:MPCapCache_GetAttribute(player, key)
	local data = Tools:GetPlayerData(player)
	local MPCapCacheAttribute = data.MPCapCacheAttribute
	if MPCapCacheAttribute and type(key) == "string" then
		return MPCapCacheAttribute[key]
	end
	return nil
end

function Magic:MPCapCache_SetAttribute(player, key, value)
	local data = Tools:GetPlayerData(player)
	local MPCapCacheAttribute = data.MPCapCacheAttribute
	if MPCapCacheAttribute and type(key) == "string" and type(value) == "number" then
		MPCapCacheAttribute[key] = value
	end
end

function Magic:MPCapCache_ModifyAttribute(player, key, amount)
	local data = Tools:GetPlayerData(player)
	local MPCapCacheAttribute = data.MPCapCacheAttribute
	if MPCapCacheAttribute and type(key) == "string" and type(amount) == "number" then
		MPCapCacheAttribute[key] = MPCapCacheAttribute[key] + amount
	end
end

function Magic:MPCapCache_ClearAttribute(player, key)
	local data = Tools:GetPlayerData(player)
	local MPCapCacheAttribute = data.MPCapCacheAttribute
	if MPCapCacheAttribute and type(key) == "string" and MPCapCacheAttribute[key] ~= nil then
		MPCapCacheAttribute[key] = nil
	end
end

function Magic:GetRecovery(player)
	local data = Tools:GetPlayerData(player)
	return data.Recovery or 5
end

function Magic:ModifyRecovery(player, amount)
	local data = Tools:GetPlayerData(player)
	data.Recovery = math.max(0, data.Recovery + amount)
end

function Magic:SetRecovery(player, value)
	local data = Tools:GetPlayerData(player)
	data.Recovery = math.max(0, value)
end

function Magic:IsMPFullyCharged(player, ignore_inf_mp)
	if ignore_inf_mp == nil then
		ignore_inf_mp = false
	end
	return Magic:GetMadouRyoku(player) >= Magic:GetMadouJyougen(player) or ((not ignore_inf_mp) and Magic:HasInfiniteMP(player))
end

function Magic:GetSpellCD(player, spell_ID)
	local SpellData = Magic:GetSpellDataById(player, spell_ID) or {}
	return SpellData.CD or 0
end

function Magic:SetSpellCD(player, spell_ID, value)
	local SpellData = Magic:GetSpellDataById(player, spell_ID) or {}
	local MaxCD = Magic:GetMaxCD(spell_ID)
	local FormalCD = Magic:GetFormalCD(spell_ID)

	if SpellData.CD then
		if FormalCD > MaxCD then
			if value > FormalCD then	
				
				SpellData.CD = FormalCD
			else
				SpellData.CD = math.max(0, value)
			end
		else
			if value > MaxCD then
				SpellData.CD = MaxCD
			else
				SpellData.CD = math.max(0, value)
			end
		end
	end
end

function Magic:ModifySpellCD(player, spell_ID, amount)
	local SpellData = Magic:GetSpellDataById(player, spell_ID) or {}
	local MaxCD = Magic:GetMaxCD(spell_ID)
	local FormalCD = Magic:GetFormalCD(spell_ID)
	
	if SpellData.CD then
		local target_value = SpellData.CD + amount
		if amount >= 0 then
			if FormalCD > MaxCD then
				SpellData.CD = math.min(FormalCD, target_value)
			else
				SpellData.CD = math.min(MaxCD, target_value)
			end
		else
			SpellData.CD = math.max(0, target_value)
		end
	end
end

function Magic:IncreaseDefaultSpellCD(player, spell_ID)
	local value = Magic:GetMaxCD(spell_ID)
	local SpellMagicType = Magic:GetMagicType(spell_ID)
	if SpellMagicType == MagicType.SPECIAL then
		value = Magic:GetFormalCD(spell_ID)
	end
	Magic:SetSpellCD(player, spell_ID, value)
end

function Magic:GetSpellIdList(player)
	local data = Tools:GetPlayerData(player)
	local list = {}
	if data.UseableSpell ~= nil then
		for _, SpellData in pairs(data.UseableSpell) do
			local ID = SpellData.ID or SpellType.SPELL_INVALID
			table.insert(list, ID)
		end
	end
	return list
end

function Magic:GetUseableSpellNum(player)
	local list = Magic:GetSpellIdList(player)
	return #list
end

function Magic:GetCurrentSpellKey(player)
	local data = Tools:GetPlayerData(player)
	return data.CurrentSpellKey or 1
end

function Magic:SetCurrentSpellKey(player, value)
	local data = Tools:GetPlayerData(player)
	local num = Magic:GetUseableSpellNum(player)
	if value > 0 and value <= num then
		data.CurrentSpellKey = value
	end
end

function Magic:TryMoveCurrentSpellKey(player, move_to_left)		--move_to_left为真则向左移动	
	local UseableSpellNum = Magic:GetUseableSpellNum(player)
	local CurrentSpellID = Magic:GetCurrentSpellId(player)
	local CurrentSpellKey = Magic:GetCurrentSpellKey(player)
	local IsUsingCurrentSpell = Magic:IsUsingSpell(player, CurrentSpellID)
	local value = 1
	
	if UseableSpellNum > 1 and CurrentSpellKey and move_to_left ~= nil then
		if move_to_left == true then
			if CurrentSpellKey == 1 then
				value = UseableSpellNum
			else
				value = CurrentSpellKey - 1
			end
		else
			value = (CurrentSpellKey % UseableSpellNum) + 1
		end
		local TargetSpellMagicType = Magic:GetMagicType(value)
		if IsUsingCurrentSpell == true then
			Magic:SimulatedToggleCurrentSpell(player)
			Magic:SetCurrentSpellKey(player, value)
			if TargetSpellMagicType == MagicType.AGGRESSIVE or TargetSpellMagicType == MagicType.LOCKON then
				Magic:SimulatedToggleCurrentSpell(player)
			end
		else
			Magic:SetCurrentSpellKey(player, value)
		end
	end
end

function Magic:SimulatedToggleCurrentSpell(player)
	local HasBlueGrimoire = (player:GetActiveItem(ActiveSlot.SLOT_POCKET) == modCollectibleType.COLLECTIBLE_BLUE_GRIMOIRE)
	if HasBlueGrimoire then
		player:UseActiveItem(modCollectibleType.COLLECTIBLE_BLUE_GRIMOIRE, UseFlag.USE_OWNED, ActiveSlot.SLOT_POCKET, 0)
	else
		local CurrentSpellID = Magic:GetCurrentSpellId(player)
		Magic:TryToggleCurrentSpell(player, UseFlag.USE_OWNED, Magic:GetSpellRNG(player, CurrentSpellID))
	end
end

function Magic:TrySwitchCurrentSpellKey(player, value, try_enable, try_use)
	local UseableSpellNum = Magic:GetUseableSpellNum(player)
	local TargetSpellMagicType = Magic:GetMagicType(value)
	if UseableSpellNum > 1 and value > 0 and value <= UseableSpellNum then
		local CurrentSpellKey = Magic:GetCurrentSpellKey(player)
		if CurrentSpellKey then
			if value == CurrentSpellKey then
				Magic:SimulatedToggleCurrentSpell(player)
			else
				local CurrentSpellID = Magic:GetCurrentSpellId(player)
				local IsUsingCurrentSpell = Magic:IsUsingSpell(player, CurrentSpellID)
				if IsUsingCurrentSpell == true then
					Magic:SimulatedToggleCurrentSpell(player)
					Magic:SetCurrentSpellKey(player, value)
					if (try_enable 
						and (TargetSpellMagicType == MagicType.AGGRESSIVE 
							or TargetSpellMagicType == MagicType.LOCKON))
					or (try_use 
						and not (TargetSpellMagicType == MagicType.AGGRESSIVE 
							or TargetSpellMagicType == MagicType.LOCKON)) then
						Magic:SimulatedToggleCurrentSpell(player)
					end
				else
					Magic:SetCurrentSpellKey(player, value)
					if (try_enable 
						and (TargetSpellMagicType == MagicType.AGGRESSIVE 
							or TargetSpellMagicType == MagicType.LOCKON))
					or (try_use 
						and not (TargetSpellMagicType == MagicType.AGGRESSIVE 
							and TargetSpellMagicType == MagicType.LOCKON)) then
						Magic:SimulatedToggleCurrentSpell(player)
					end
				end
			end
		end
	end
end

function Magic:GetCurrentSpellData(player)
	local data = Tools:GetPlayerData(player)
	local UseableSpell = data.UseableSpell or {}
	local CurrentSpellKey = data.CurrentSpellKey
	return UseableSpell[CurrentSpellKey] or nil
end

function Magic:GetCurrentSpellId(player)
	local data = Tools:GetPlayerData(player)
	local UseableSpell = data.UseableSpell
	local CurrentSpellKey = data.CurrentSpellKey
	if UseableSpell then
		local CurrentSpellData = UseableSpell[CurrentSpellKey] or {}
		return CurrentSpellData.ID or SpellType.SPELL_INVALID
	else
		return SpellType.SPELL_INVALID
	end
end

function Magic:GetSpellDataById(player, spell_ID)
	local data = Tools:GetPlayerData(player)
	local UseableSpell = data.UseableSpell or {}
	for _, SpellData in pairs(UseableSpell) do
		if SpellData.ID == spell_ID then
			return SpellData
		end
	end
	return nil
end

function Magic:BuildSpellIconPosOffsetList(player)	--这个函数只在渲染时调用，返回值为矢量数组，其中已考虑图标本身的大小
	local list = {}
	local num = Magic:GetUseableSpellNum(player)
	local OffsetX = 18
	local OffsetY = 18
	local UnitOffset = Vector(OffsetX, OffsetY)		--单位图标的偏移量矢量，向第一象限（右下方）偏移
	local head = UnitOffset * -1					--首节点位置矢量
	--此处认为锚点位置矢量为(0, 0)
	if num <= 5 then
		head = head + Vector(-OffsetX / 2, 0) * (num - 1)
		for i = 1, num do
			list[i] = head + Vector(OffsetX, 0) * (i - 1)
		end
	else
		head = head + Vector(0, -OffsetY) + Vector(-OffsetX / 2, 0) * (math.max(num / 2) - 1)
		for i = 1, num do
			if i <= math.max(num / 2) then
				list[i] = head + Vector(OffsetX, 0) * (i - 1)
			else
				local j = i - math.max(num / 2)
				list[i] = head + Vector(0, OffsetY) + Vector(OffsetX, 0) * (j - 1)
			end
		end
	end
	return list
end

function Magic:SetDisplayMPIcon(player, value)
	local data = Tools:GetPlayerData(player)
	if data.DisplayMPIcon ~= nil then
		data.DisplayMPIcon = value
	end
end

function Magic:SetDisplaySpellIcon(player, value)
	local data = Tools:GetPlayerData(player)
	if data.DisplaySpellIcon ~= nil then
		data.DisplaySpellIcon = value
	end
end

function Magic:SetDisplaySpellText(player, value)
	local data = Tools:GetPlayerData(player)
	if data.DisplaySpellText ~= nil then
		data.DisplaySpellText = value
	end
end

function Magic:MPIconAreaUpdate(player)	--//
	--local hud_offset = Options.HUDOffset
	--local MP_X = 50 + 20 * hud_offset
	--local MP_Y = 33 + 12 * hud_offset

	local data = Tools:GetPlayerData(player)
	--local offset_X = 50 + 20 * hud_offset
	--local offset_Y = 33 + 12 * hud_offset
	local offset_X = 50
	local offset_Y = 33
	local MPOffset = Vector(0, 0)
	local UserIdx = Tools:GetUserIdx(player)
	if UserIdx == 1 or UserIdx == 3 then
		offset_X = Isaac.GetScreenWidth() * 0.75
		offset_Y = offset_Y + 12
	end
	if UserIdx > 1 then
		offset_Y = Isaac.GetScreenHeight() * 0.8
	end
	if data.MPIconArea then
		data.MPIconArea = Vector(offset_X, offset_Y)
		if data.MPIconAreaOffset then
			for _, vec in pairs(data.MPIconAreaOffset) do
				if vec ~= nil then
					MPOffset = MPOffset + vec
				end
			end
		end
		data.MPIconArea = data.MPIconArea + MPOffset
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Magic.MPIconAreaUpdate)

function Magic:AddMPIconAreaOffset(player, key, offset_X, offset_Y)
	local data = Tools:GetPlayerData(player)
	if type(key) == "string" then
		data.MPIconAreaOffset = data.MPIconAreaOffset or {}
		data.MPIconAreaOffset[key] = Vector(offset_X, offset_Y)
	end
end

function Magic:RemoveMPIconAreaOffset(player, key)
	local data = Tools:GetPlayerData(player)
	if type(key) == "string" and data.MPIconAreaOffset then
		data.MPIconAreaOffset[key] = nil
	end
end

function Magic:AddSpellIconAreaOffset(player, key, offset_X, offset_Y)
	local data = Tools:GetPlayerData(player)
	if type(key) == "string" then
		data.SpellIconAreaOffset = data.SpellIconAreaOffset or {}
		data.SpellIconAreaOffset[key] = Vector(offset_X, offset_Y)
	end
end

function Magic:RemoveSpellIconAreaOffset(player, key)
	local data = Tools:GetPlayerData(player)
	if type(key) == "string" and data.SpellIconAreaOffset then
		data.SpellIconAreaOffset[key] = nil
	end
end

function Magic:AddSpellTextAreaOffset(player, key, offset_X, offset_Y)
	local data = Tools:GetPlayerData(player)
	if type(key) == "string" then
		data.SpellTextAreaOffset = data.SpellTextAreaOffset or {}
		data.SpellTextAreaOffset[key] = Vector(offset_X, offset_Y)
	end
end

function Magic:RemoveSpellTextAreaOffset(player, key)
	local data = Tools:GetPlayerData(player)
	if type(key) == "string" and data.SpellTextAreaOffset then
		data.SpellTextAreaOffset[key] = nil
	end
end

function Magic:SpellIconAreaUpdate()
	local NumPlayers = Game():GetNumPlayers()
	if Tools:GetUserNum() <= 1 then
		local player = Isaac.GetPlayer(0)
		local data = Tools:GetPlayerData(player)
		local OffsetX = 18
		local OffsetY = 18
		local num = Magic:GetUseableSpellNum(player)
		if num == 0 then
			OffsetX = 0
			OffsetY = 0
		elseif num <= 5 then
			OffsetX = (OffsetX / 2) * num
			OffsetY = OffsetY / 2
		else
			OffsetX = (OffsetX / 2) * math.ceil(num / 2)
			OffsetY = OffsetY * 1.5
		end

		local AnchorX = Isaac.GetScreenWidth() * 0.15 + OffsetX
		local AnchorY = Isaac.GetScreenHeight() * 0.94

		if data.SpellIconArea then
			data.SpellIconArea = Vector(AnchorX, AnchorY)
			local IconOffset = Vector(0, 0)
			if data.SpellIconAreaOffset then
				for _, vec in pairs(data.SpellIconAreaOffset) do
					if vec ~= nil then
						IconOffset = IconOffset + vec
					end
				end
			end
			data.SpellIconArea = data.SpellIconArea + IconOffset
		end

		local TextOffset = Vector(0, 0)
		if data.SpellTextArea then
			data.SpellTextArea = Vector(AnchorX, AnchorY) + Vector(-24, -10)
			if data.SpellTextAreaOffset then	--\\
				for _, vec in pairs(data.SpellTextAreaOffset) do	--引入某件新道具后即可启用
					if vec ~= nil then
						TextOffset = TextOffset + vec
					end
				end
			end
			data.SpellTextArea = data.SpellTextArea + TextOffset
		end
	else
		for p = 0, NumPlayers - 1 do
			local player = Isaac.GetPlayer(p)
			local OffsetY = -95
			local num = Magic:GetUseableSpellNum(player)
			if num <= 5 then
				OffsetY = OffsetY + 18
			end
			local data = Tools:GetPlayerData(player)

			if data.SpellIconArea then
				local IconOffset = Vector(18, -24)
				if data.SpellIconAreaOffset then
					for _, vec in pairs(data.SpellIconAreaOffset) do
						if vec ~= nil then
							IconOffset = IconOffset + vec
						end
					end
				end
				data.SpellIconArea = Tools:GetEntityRenderScreenPos(player) + IconOffset
			end

			if data.SpellTextArea then
				local TextOffset = Vector(-4, OffsetY)
				if data.SpellTextAreaOffset then
					for _, vec in pairs(data.SpellTextAreaOffset) do
						if vec ~= nil then
							TextOffset = TextOffset + vec
						end
					end
				end
				data.SpellTextArea = Tools:GetEntityRenderScreenPos(player) + TextOffset
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_RENDER, Magic.SpellIconAreaUpdate)

function Magic:HasSpell(player, spell_ID)
	local SpellData = Magic:GetSpellDataById(player, spell_ID)
	return SpellData ~= nil
end

function Magic:BuildSpellData(spell_ID, starting_reberu, allowed)
	local SpellData = {}
	SpellData.ID = spell_ID
	if starting_reberu > 0 then
		SpellData.Reberu = math.min(Magic:GetMaxReberu(spell_ID), starting_reberu)
	else
		SpellData.Reberu = 0
	end
	SpellData.IsAllowed = allowed
	local SpellMagicType = Magic:GetMagicType(spell_ID)
	if SpellMagicType == MagicType.AGGRESSIVE or SpellMagicType == MagicType.LOCKON then
		SpellData.Using = false
	elseif SpellMagicType ~= MagicType.NONE then
		SpellData.CD = 0
	end
	local new_rng = RNG()
	new_rng:SetSeed(Game():GetSeeds():GetStartSeed(), 35)
	SpellData.RNG = new_rng
	return SpellData
end

function Magic:PlayerDataInit(player, starting_mp, starting_mp_cap, starting_recovery)
	local data = Tools:GetPlayerData(player)
	if data.MadouRyoku == nil then
		data.MadouRyoku = starting_mp
	end
	if data.MadouJyougen == nil then
		data.MadouJyougen = starting_mp_cap
	end
	if data.CurrentSpellKey == nil then
		data.CurrentSpellKey = 1
	end
	if data.Recovery == nil then
		data.Recovery = starting_recovery
	end
	if data.MPIconArea == nil then
		data.MPIconArea = Vector(0, 0)
	end
	if data.SpellIconArea == nil then
		data.SpellIconArea = Vector(0, 0)
	end
	if data.SpellTextArea == nil then
		data.SpellTextArea = Vector(0, 0)
	end
	if data.SpellIconTransparencyLv == nil then
		data.SpellIconTransparencyLv = 1
	end
	if data.SpellIconOpacity == nil then
		data.SpellIconOpacity = 1
	end
	if data.ChangeSpellCountDown == nil then
		data.ChangeSpellCountDown = 0
	end
	if data.HasInfiniteMP == nil then
		data.HasInfiniteMP = false
	end
	if data.NoSpellCD == nil then
		data.NoSpellCD = false
	end
	if data.DisplayMPIcon == nil then
		data.DisplayMPIcon = false
	end
	if data.DisplaySpellIcon == nil then
		data.DisplaySpellIcon = false
	end
	if data.DisplaySpellText == nil then
		data.DisplaySpellText = false
	end
	if data.MagicFlag == nil then
		data.MagicFlag = 0
	end
	
	if data.MPIconAreaOffset == nil then
		data.MPIconAreaOffset = {}
	end
	if data.SpellIconAreaOffset == nil then
		data.SpellIconAreaOffset = {}
	end
	if data.SpellTextAreaOffset == nil then
		data.SpellTextAreaOffset = {}
	end
	Magic:BaseSpellDataInit(player, spell_ID)
	if data.UseableSpell == nil then
		data.UseableSpell = {}
	end
	if data.SPChargeData == nil then
		data.SPChargeData = {}
	end
	if data.SPChargePriority == nil then
		data.SPChargePriority = {}
	end
	if data.MPCapCacheAttribute == nil then
		data.MPCapCacheAttribute = {}
	end
end

function Magic:BaseSpellDataInit(player, spell_ID)
	local data = Tools:GetPlayerData(player)
	local SpellMagicType = Magic:GetMagicType(spell_ID)
	if data.BaseSpellData == nil then
		data.BaseSpellData = {}
		data.BaseSpellData[MagicType.NONE] = {}
		data.BaseSpellData[MagicType.AGGRESSIVE] = {
			["UsedInCurrentRoom"] = false,
			["MagicCircle"] = nil,
			["TearFlagSeed"] = 0,
			["ChargeData"] = {
				State = 0,
				ChargingSpellCache = {
					Type = SpellType.SPELL_INVALID,
					Reberu = 0,
				},
				CurrentCharge = 0,
				Timeout = 0,
				DisplayChargeBar = false,
				ChargeBarPos = Vector(0, 0),
				ChargeBarPosOffset = {},
			},
		}
		data.BaseSpellData[MagicType.DEFENSIVE] = {}
		data.BaseSpellData[MagicType.SPECIAL] = {}
		data.BaseSpellData[MagicType.LOCKON] = {
			["LaserSight"] = nil,
			["TargetHeap"] = {},
			["TargetNum"] = 0,
			["LockonCD"] = 0,	--注：此处指玩家实际使用时的计数器，每次使用后要将MaxLockonCD的值赋给它
		}
		data.BaseSpellData[MagicType.HELPER] = {}
	end
end

function Magic:AddSpell(player, spell_ID, starting_reberu, allowed)
	local data = Tools:GetPlayerData(player)
	if data.UseableSpell == nil then
		data.UseableSpell = {}
		data.CurrentSpellKey = 1
	end
	local SpellData = Magic:BuildSpellData(spell_ID, starting_reberu, allowed)
	local SpellMagicType = Magic:GetMagicType(spell_ID)
	table.insert(data.UseableSpell, SpellData)

	Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_POST_SPELL_INIT, spell_ID, spell_ID, player)
	Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_POST_SPELL_INIT_BASE, SpellMagicType, spell_ID, player)
end

function Magic:TryAddSpell(player, spell_ID, starting_reberu, allowed)
	if Magic:IsValidSpell(spell_ID) and (not Magic:HasSpell(player, spell_ID)) then
		Magic:AddSpell(player, spell_ID, starting_reberu, allowed)
	end
end

function Magic:GetSpellReberu(player, spell_ID)
	local SpellData = Magic:GetSpellDataById(player, spell_ID)
	if SpellData then
		return SpellData.Reberu
	end
	return 0
end

function Magic:SetSpellReberu(player, spell_ID, reberu)
	local SpellData = Magic:GetSpellDataById(player, spell_ID)
	if SpellData then
		local MaxReberu = Magic:GetMaxReberu(spell_ID)
		if reberu > 0 then
			SpellData.Reberu = math.min(MaxReberu, reberu)
		end
	end
end

function Magic:IsSpellAllowed(player, spell_ID)
	local SpellData = Magic:GetSpellDataById(player, spell_ID)
	return SpellData ~= nil and SpellData.IsAllowed == true
end

function Magic:IsSpellUnlocked(player, spell_ID)
	local SpellData = Magic:GetSpellDataById(player, spell_ID)
	return SpellData ~= nil and SpellData.Reberu > 0
end

function Magic:IsMadouRyokuEnough(player, spell_ID, ignore_sp_charge, ignore_inf_mp)
	if ignore_sp_charge == nil then
		ignore_sp_charge = false
	end
	if ignore_inf_mp == nil then
		ignore_inf_mp = false
	end
	local data = Tools:GetPlayerData(player)
	local cost = Magic:GetCost(spell_ID)
	local sp_charge = Magic:GetEffectiveSPCharge(player)
	if ignore_sp_charge then
		sp_charge = 0
	end
	return ((not ignore_inf_mp) and Magic:HasInfiniteMP(player)) or (data.MadouRyoku + sp_charge >= cost)
end

function Magic:IsSpellRecharged(player, spell_ID, ignore_special_spell)
	local SpellData = Magic:GetSpellDataById(player, spell_ID) or {}
	local SpellMagicType = Magic:GetMagicType(spell_ID)
	if not (SpellMagicType == MagicType.NONE or SpellMagicType == MagicType.AGGRESSIVE or SpellMagicType == MagicType.LOCKON) then
		if SpellMagicType == MagicType.SPECIAL then
			if ignore_special_spell then
				return SpellData.CD == 0
			else
				return SpellData.CD == 0 
					or (SpellData.CD and SpellData.CD >= Magic:GetMaxCD(spell_ID))
			end
		else
			return SpellData.CD == 0
		end
	else
		return true
	end
end

function Magic:IsUsingSpell(player, spell_ID)	--如果不是攻击性/瞄准-锁定型法术，则返回nil
	local CurrentSpellID = Magic:GetCurrentSpellId(player)
	if not Magic:IsValidSpell(spell_ID) then
		return nil
	end
	local CurrentSpellData = Magic:GetCurrentSpellData(player) or {}
	if CurrentSpellData.Using == nil then
		return nil
	end
	return Magic:IsSpellUnlocked(player, spell_ID) 
		and CurrentSpellID == spell_ID 
		and CurrentSpellData.Using
end

function Magic:IsSpellReberuFull(player, spell_ID)
	local SpellData = Magic:GetSpellDataById(player, spell_ID)
	if SpellData and SpellData.Reberu then
		return SpellData.Reberu >= Magic:GetMaxReberu(spell_ID)
	end
	return true
end

function Magic:UpgradeSpell(player, spell_ID)
	local SpellData = Magic:GetSpellDataById(player, spell_ID)
	if SpellData and SpellData.Reberu then
		if not Magic:IsSpellReberuFull(player, spell_ID) then
			SpellData.Reberu = SpellData.Reberu + 1
		end
	end
end

function Magic:CanUpgradeSpell(player, spell_ID)
	return Magic:IsValidSpell(spell_ID) and Magic:IsSpellAllowed(player, spell_ID) and (not Magic:IsSpellReberuFull(player, spell_ID))
end

function Magic:TryUpgradeSpell(player, spell_ID)		--解锁法术时亦使用此函数
	if Magic:CanUpgradeSpell(player, spell_ID) then
		Magic:UpgradeSpell(player, spell_ID)
	end
end

function Magic:GetUpgradeText(player, spell_ID_list, lang)	--spell_ID_list可以是单个法术ID，亦可是由多个法术ID组成的数组
	local lang_fixed = Translation:FixLanguage(lang)
	local unlock_list = {["en"] = {}, ["zh"] = {},}
	local upgrade_list = {["en"] = {}, ["zh"] = {},}
	local list = {}
	if type(spell_ID_list) == "number" then
		list = {spell_ID_list}
	elseif type(spell_ID_list) == "table" then
		list = spell_ID_list
	else
		return ""
	end
	for i, spell_ID in pairs(list) do
		if Magic:IsValidSpell(spell_ID) then
			local name = Magic:GetName(spell_ID, "en")
			local name_zh = Magic:GetName(spell_ID, "zh")
			if Magic:IsSpellUnlocked(player, spell_ID) 
			or (Common:IsInTable('"' .. name .. '"', unlock_list["en"]) and Common:IsInTable("“" .. name_zh .. "”", unlock_list["zh"])) then
				table.insert(upgrade_list["en"], '"' .. name .. '"')
				table.insert(upgrade_list["zh"], "“" .. name_zh .. "”")
			else
				table.insert(unlock_list["en"], '"' .. name .. '"')
				table.insert(unlock_list["zh"], "“" .. name_zh .. "”")
			end
		end
	end
	local display_unlock = (not Common:IsTableEmpty(unlock_list[lang_fixed]))
	local display_upgrade = (not Common:IsTableEmpty(upgrade_list[lang_fixed]))
	local PAUSE = {["en"] = ", ", ["zh"] = "",}
	local CONJ1 = {["en"] = " and ", ["zh"] = "和",}
	local ULK_INI = {["en"] = "You unlocked ", ["zh"] = "你解锁了",}
	local ULK_FIN = {["en"] = "", ["zh"] = "",}
	local COMMA = {["en"] = ", ", ["zh"] = "，",}
	local CONJ2 = {["en"] = " and ", ["zh"] = "和",}
	local UPG_INI = {["en"] = "", ["zh"] = "",}
	local UPG_FIN = {["en"] = " has upgraded", ["zh"] = "已升级",}
	local EXCL = {["en"] = "!", ["zh"] = "！",}
	if #(unlock_list[lang_fixed]) == 1 then
		ULK_FIN[lang_fixed] = unlock_list[lang_fixed][1]
	elseif display_unlock then
		if #(unlock_list[lang_fixed]) > 2 then
			CONJ1["en"] = ", and "
		end
		ULK_FIN[lang_fixed] = (table.concat(unlock_list[lang_fixed], PAUSE[lang_fixed], 1, #(unlock_list[lang_fixed]) - 1)) .. (CONJ1[lang_fixed]) .. (unlock_list[lang_fixed][#(unlock_list[lang_fixed])])
	end
	if #(upgrade_list[lang_fixed]) == 1 then
		UPG_INI[lang_fixed] = upgrade_list[lang_fixed][1]
	elseif display_upgrade then
		if #(upgrade_list[lang_fixed]) > 2 then
			CONJ2["en"] = ", and "
		end
		UPG_INI[lang_fixed] = (table.concat(upgrade_list[lang_fixed], PAUSE[lang_fixed], 1, #(upgrade_list[lang_fixed]) - 1)) .. (CONJ2[lang_fixed]) .. (upgrade_list[lang_fixed][#(upgrade_list[lang_fixed])])
	end
	if not (display_unlock and display_upgrade) then
		COMMA[lang_fixed] = ""
		if not display_unlock then
			ULK_INI[lang_fixed] = ""
		end
		if not display_upgrade then
			UPG_FIN[lang_fixed] = ""
		end
	end
	local text = {ULK_INI[lang_fixed], ULK_FIN[lang_fixed], COMMA[lang_fixed], UPG_INI[lang_fixed], UPG_FIN[lang_fixed], EXCL[lang_fixed],}
	return table.concat(text)
end

function Magic:AllowSpell(player, spell_ID)
	local SpellData = Magic:GetSpellDataById(player, spell_ID)
	if SpellData.IsAllowed == nil or SpellData.IsAllowed == false then
		SpellData.IsAllowed = true
	end
end

function Magic:ForbidSpell(player, spell_ID)
	local SpellData = Magic:GetSpellDataById(player, spell_ID)
	if SpellData.IsAllowed == nil or SpellData.IsAllowed == true then
		SpellData.IsAllowed = false
	end
end

function Magic:GetSpellRNG(player, spell_ID)
	local SpellData = Magic:GetSpellDataById(player, spell_ID)
	if SpellData then
		return SpellData.RNG
	end
	local new_rng = RNG()
	new_rng:SetSeed(Game():GetSeeds():GetStartSeed(), 35)
	return new_rng
end

function Magic:CanToggleSpell(player, spell_ID, ignore_sp_charge)
	local SpellMagicType = Magic:GetMagicType(spell_ID)
	if SpellMagicType == MagicType.LOCKON then
		if not Magic:IsUsingSpell(player, spell_ID) then
			return Magic:IsSpellAllowed(player, spell_ID) 
				and Magic:IsSpellUnlocked(player, spell_ID) 
				and (Magic:IsMadouRyokuEnough(player, spell_ID, ignore_sp_charge))
		else
			return true
		end
	elseif SpellMagicType == MagicType.HELPER then
		return Magic:IsSpellAllowed(player, spell_ID) 
			and Magic:IsSpellUnlocked(player, spell_ID) 
			and Magic:IsSpellRecharged(player, spell_ID, false)
	else
		return Magic:IsValidSpell(spell_ID) 
			and Magic:IsSpellAllowed(player, spell_ID) 
			and Magic:IsSpellUnlocked(player, spell_ID) 
			and Magic:IsMadouRyokuEnough(player, spell_ID, ignore_sp_charge) 
			and Magic:IsSpellRecharged(player, spell_ID, false)
	end
end

function Magic:TryEnableSpell(player, spell_ID, use_flags, rng)
	local SpellData = Magic:GetSpellDataById(player, spell_ID) or {}
	local SpellMagicType = Magic:GetMagicType(spell_ID)
	if SpellMagicType == MagicType.AGGRESSIVE or SpellMagicType == MagicType.LOCKON then
		if SpellData.Using ~= nil and SpellData.Using == false then
			SpellData.Using = true
			Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_ENABLE_SPELL_BASE, SpellMagicType, spell_ID, rng, player, use_flags)
			return Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_ENABLE_SPELL, spell_ID, spell_ID, rng, player, use_flags)
		end
	end
end

function Magic:TryDisableSpell(player, spell_ID, use_flags, rng)
	local SpellData = Magic:GetSpellDataById(player, spell_ID) or {}
	local SpellMagicType = Magic:GetMagicType(spell_ID)
	if SpellMagicType == MagicType.AGGRESSIVE or SpellMagicType == MagicType.LOCKON then
		if SpellData.Using ~= nil and SpellData.Using == true then
			SpellData.Using = false
			Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_DISABLE_SPELL_BASE, SpellMagicType, spell_ID, rng, player, use_flags)
			return Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_DISABLE_SPELL, spell_ID, spell_ID, rng, player, use_flags)
		end
	end
end

function Magic:TryUseSpell(player, spell_ID, use_flags, rng)
	local SpellData = Magic:GetSpellDataById(player, spell_ID) or {}
	local SpellMagicType = Magic:GetMagicType(spell_ID)
	if not (SpellMagicType == MagicType.AGGRESSIVE or SpellMagicType == MagicType.LOCKON) then
		Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_USE_SPELL_BASE, SpellMagicType, spell_ID, rng, player, use_flags)
		return Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_USE_SPELL, spell_ID, spell_ID, rng, player, use_flags)
	end
end

function Magic:TryToggleCurrentSpell(player, use_flags, rng)
	Magic:SetChangeSpellCountDown(player, 120)
	local CurrentSpellID = Magic:GetCurrentSpellId(player)
	local IsUsingCurrentSpell = Magic:IsUsingSpell(player, CurrentSpellID)
	local CanToggle = Magic:CanToggleSpell(player, CurrentSpellID, false) or use_flags & UseFlag.USE_VOID > 0
	if CanToggle then
		if IsUsingCurrentSpell == true then
			return Magic:TryDisableSpell(player, CurrentSpellID, use_flags, rng)
		elseif IsUsingCurrentSpell == false then
			return Magic:TryEnableSpell(player, CurrentSpellID, use_flags, rng)
		else
			return Magic:TryUseSpell(player, CurrentSpellID, use_flags, rng)
		end
	else
		return false
	end
end

function Magic:BaseSpell_AddAttribute(player, magic_type, key, starting_value)
	local data = Tools:GetPlayerData(player)
	if data.BaseSpellData then
		local BaseSpellDataByType = data.BaseSpellData[magic_type]
		if BaseSpellDataByType and BaseSpellDataByType[key] == nil and type(key) == "string" then
			BaseSpellDataByType[key] = starting_value
		end
	end
end

function Magic:BaseSpell_GetAttribute(player, magic_type, key)
	local data = Tools:GetPlayerData(player)
	if data.BaseSpellData then
		local BaseSpellDataByType = data.BaseSpellData[magic_type]
		if BaseSpellDataByType and type(key) == "string" then
			return BaseSpellDataByType[key]
		end
	end
	return nil
end

function Magic:BaseSpell_SetAttribute(player, magic_type, key, value)
	local data = Tools:GetPlayerData(player)
	if data.BaseSpellData then
		local BaseSpellDataByType = data.BaseSpellData[magic_type]
		if BaseSpellDataByType and type(key) == "string" then
			BaseSpellDataByType[key] = value
		end
	end
end

function Magic:BaseSpell_ModifyAttribute(player, magic_type, key, amount)
	local data = Tools:GetPlayerData(player)
	if data.BaseSpellData then
		local BaseSpellDataByType = data.BaseSpellData[magic_type]
		if BaseSpellDataByType and type(key) == "string" and type(BaseSpellDataByType[key]) == "number" then
			BaseSpellDataByType[key] = BaseSpellDataByType[key] + amount
		end
	end
end

function Magic:BaseSpell_ClearAttribute(player, magic_type, key)
	local data = Tools:GetPlayerData(player)
	if data.BaseSpellData then
		local BaseSpellDataByType = data.BaseSpellData[magic_type]
		if BaseSpellDataByType and type(key) == "string" and BaseSpellDataByType[key] ~= nil then
			BaseSpellDataByType[key] = nil
		end
	end
end

function Magic:Spell_AddAttribute(player, spell_ID, key, starting_value)
	local SpellData = Magic:GetSpellDataById(player, spell_ID)
	if SpellData and SpellData[key] == nil and type(key) == "string" then
		SpellData[key] = starting_value
	end
end

function Magic:Spell_GetAttribute(player, spell_ID, key)
	local SpellData = Magic:GetSpellDataById(player, spell_ID)
	if SpellData and type(key) == "string" then
		return SpellData[key]
	end
	return nil
end

function Magic:Spell_SetAttribute(player, spell_ID, key, value)
	local SpellData = Magic:GetSpellDataById(player, spell_ID)
	if SpellData and type(key) == "string" then
		SpellData[key] = value
	end
end

function Magic:Spell_ModifyAttribute(player, spell_ID, key, amount)
	local SpellData = Magic:GetSpellDataById(player, spell_ID)
	if SpellData and type(key) == "string" and type(SpellData[key]) == "number" then
		SpellData[key] = SpellData[key] + amount
	end
end

function Magic:Spell_ClearAttribute(player, spell_ID, key)
	local SpellData = Magic:GetSpellDataById(player, spell_ID)
	if SpellData and type(key) == "string" and SpellData[key] ~= nil then
		SpellData[key] = nil
	end
end

function Magic:SPCharge_AddAttribute(player, key, exchange_rate)
	local data = Tools:GetPlayerData(player)
	local SPChargeData = data.SPChargeData
	local SPChargePriority = data.SPChargePriority
	if SPChargeData == nil then
		SPChargeData = {}
	end
	if SPChargePriority == nil then
		SPChargePriority = {}
	end
	if type(key) == "string" and (not Magic:SPCharge_HasAttribute(player, key)) then
		SPChargeData[key] = {
			Value = 0,
			ExchangeRate = exchange_rate,
			EffectiveMP = 0,
		}
		table.insert(SPChargePriority, key)
	end
end

function Magic:SPCharge_HasAttribute(player, key)
	local data = Tools:GetPlayerData(player)
	local SPChargeData = data.SPChargeData or {}
	if type(key) == "string" then
		if SPChargeData[key] ~= nil then
			return true
		else
			return false
		end
	end
	return nil
end

function Magic:SPCharge_GetValue(player, key)
	local data = Tools:GetPlayerData(player)
	local SPChargeData = data.SPChargeData or {}
	if type(key) == "string" then
		if SPChargeData[key] ~= nil then
			return SPChargeData[key].Value
		end
	end
	return nil
end

function Magic:SPCharge_SetValue(player, key, value)
	local data = Tools:GetPlayerData(player)
	local SPChargeData = data.SPChargeData
	if SPChargeData and type(key) == "string" then
		SPChargeData[key].Value = math.max(0, value)
	end
end

function Magic:SPCharge_ModifyValue(player, key, amount)
	local data = Tools:GetPlayerData(player)
	local SPChargeData = data.SPChargeData or {}
	if type(key) == "string" and SPChargeData[key] ~= nil then
		SPChargeData[key].Value = math.max(0, SPChargeData[key].Value + amount)
	end
end

function Magic:SPCharge_GetExchangeRate(player, key)
	local data = Tools:GetPlayerData(player)
	local SPChargeData = data.SPChargeData or {}
	if type(key) == "string" then
		if SPChargeData[key] ~= nil then
			return SPChargeData[key].ExchangeRate
		end
	end
	return nil
end

function Magic:SPCharge_SetExchangeRate(player, key, value)
	local data = Tools:GetPlayerData(player)
	local SPChargeData = data.SPChargeData or {}
	if type(key) == "string" and SPChargeData[key] ~= nil then
		SPChargeData[key].ExchangeRate = math.max(0, value)
	end
end

function Magic:SPCharge_GetEffectiveMP(player, key)
	local data = Tools:GetPlayerData(player)
	local SPChargeData = data.SPChargeData or {}
	if type(key) == "string" then
		if SPChargeData[key] ~= nil then
			return SPChargeData[key].EffectiveMP
		end
	end
	return nil
end

function Magic:SPCharge_SetEffectiveMP(player, key, value)
	local data = Tools:GetPlayerData(player)
	local SPChargeData = data.SPChargeData or {}
	if type(key) == "string" and SPChargeData[key] ~= nil then
		SPChargeData[key].EffectiveMP = math.max(0, value)
	end
end

function Magic:SPCharge_ModifyEffectiveMP(player, key, amount)
	local data = player:GetData()
	local SPChargeData = data.SPChargeData or {}
	if type(key) == "string" and SPChargeData[key] ~= nil then
		SPChargeData[key].EffectiveMP = math.max(0, SPChargeData[key].EffectiveMP + amount)
	end
end

function Magic:SPCharge_SetTopPriority(player, key)
	local data = Tools:GetPlayerData(player)
	local SPChargePriority = data.SPChargePriority or {}
	if #SPChargePriority > 1 then
		local tmp = {}
		for i, j in pairs(SPChargePriority) do
			if j == key then
				table.remove(SPChargePriority, i)
			end
		end
		table.insert(tmp, key)
		for i, j in pairs(SPChargePriority) do
			table.insert(tmp, j)
		end
		SPChargePriority = tmp
	end
end

function Magic:SPCharge_ClearAllAttribute(player)
	local data = Tools:GetPlayerData(player)
	local SPChargePriority = data.SPChargePriority
	local SPChargeData = data.SPChargeData
	SPChargeData = {}
	SPChargePriority = {}
end

function Magic:SPCharge_RemoveAttribute(player, key)
	local data = Tools:GetPlayerData(player)
	local SPChargePriority = data.SPChargePriority
	local SPChargeData = data.SPChargeData
	if SPChargeData ~= nil then
		if SPChargeData[key] ~= nil then
			SPChargeData[key] = nil
		end
	end
	if SPChargePriority ~= nil then
		for i , j in pairs(SPChargePriority) do
			if j == key then
				table.remove(SPChargePriority, i)
			end
		end
	end
end

function Magic:GetEffectiveSPCharge(player)
	local data = Tools:GetPlayerData(player)
	local SPChargeData = data.SPChargeData or {}
	local sum = 0
	for key, sp_charge_data in pairs(SPChargeData) do
		sum = sum + sp_charge_data.EffectiveMP
	end
	return sum
end

function Magic:ClearMagicData(player)
	local data = Tools:GetPlayerData(player)
	data.MadouRyoku = nil					--魔导力（浮点数）
	data.MadouJyougen = nil					--魔导力上限（浮点数）
	data.CurrentSpellKey = nil				--当前法术序号（整数）
	data.Recovery = nil						--回复力（浮点数）
	data.MPIconArea = nil					--魔导力图标锚点位置矢量（矢量）
	data.SpellIconArea = nil				--法术图标锚点位置矢量（矢量）
	data.SpellTextArea = nil				--法术文字锚点位置矢量（矢量）
	data.HasInfiniteMP = nil				--拥有无限魔导力（逻辑）
	data.NoSpellCD = nil					--法术无冷却时间（逻辑）
	data.DisplayMPIcon = nil				--显示魔导力图标（逻辑）
	data.IsMageCharacter = nil				--角色是否为魔导师（逻辑）
	data.DisplaySpellIcon = nil				--显示法术图标（逻辑）
	data.DisplaySpellText = nil				--显示法术文字（逻辑）
	data.SpellIconTransparencyLv = nil		--法术图标透明度等级（整数）
	data.SpellIconOpacity = nil				--法术图标不透明度（浮点数）
	data.ChangeSpellCountDown = nil			--切换法术计时器（整数）
	data.MagicFlag = nil					--魔法相关标记（整数）
	------
	data.MPIconAreaOffset = nil				--魔导力图标锚点偏移（散列表）
	data.SpellIconAreaOffset = nil			--法术图标锚点偏移（散列表）
	data.SpellTextAreaOffset = nil			--法术文字锚点偏移（散列表）
	data.BaseSpellData = nil				--基类法术数据（数组）
	data.UseableSpell = nil					--可用法术列表（数组）
	data.SPChargeData = nil					--特殊充能数据（散列表）
	data.SPChargePriority = nil				--特殊充能优先级（数组）
	data.MPCapCacheAttribute = nil			--魔导力上限加成缓存（散列表）
end

function Magic:EnableInfiniteMP(player)
	local data = Tools:GetPlayerData(player)
	data.HasInfiniteMP = true
end

function Magic:DisableInfiniteMP(player)
	local data = Tools:GetPlayerData(player)
	data.HasInfiniteMP = false
end

function Magic:ToggleInfiniteMP(player)
	if Magic:HasInfiniteMP(player) then
		Magic:DisableInfiniteMP(player)
	else
		Magic:EnableInfiniteMP(player)
	end
end

function Magic:HasInfiniteMP(player)
	local data = Tools:GetPlayerData(player)
	return data.HasInfiniteMP == true
end

function Magic:EnableNoSpellCD(player)
	local data = Tools:GetPlayerData(player)
	data.NoSpellCD = true
end

function Magic:DisableNoSpellCD(player)
	local data = Tools:GetPlayerData(player)
	data.NoSpellCD = false
end

function Magic:ToggleNoSpellCD(player)
	if Magic:NoSpellCD(player) then
		Magic:DisableNoSpellCD(player)
	else
		Magic:EnableNoSpellCD(player)
	end
end

function Magic:NoSpellCD(player)
	local data = Tools:GetPlayerData(player)
	return data.NoSpellCD == true
end

function Magic:RemoveSpellCD(player)
	if Magic:NoSpellCD(player) then
		local list = Magic:GetSpellIdList(player)
		for i, spell_ID in pairs(list) do
			Magic:SetSpellCD(player, spell_ID, 0)
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Magic.RemoveSpellCD)

function Magic:HasFlag(player, flag)
	local data = Tools:GetPlayerData(player)
	return data.MagicFlag and (data.MagicFlag & flag > 0)
end

function Magic:AddFlag(player, flag)
	local data = Tools:GetPlayerData(player)
	if data.MagicFlag then
		data.MagicFlag = data.MagicFlag | flag
	end
end

function Magic:ClearFlag(player, flag)
	local data = Tools:GetPlayerData(player)
	if data.MagicFlag then
		data.MagicFlag = data.MagicFlag & (~flag)
	end
end

function Magic:IsMageCharacter(player)
	local player_type = player:GetPlayerType()
	local data = Tools:GetPlayerData(player)
	return data.IsMageCharacter == true
		or player_type == modPlayerType.PLAYER_ARLENADJA 
		or player_type == modPlayerType.PLAYER_DOPPELGANGERARLE
end

function Magic:SetMageCharacter(player, value)
	local data = Tools:GetPlayerData(player)
	data.IsMageCharacter = value
end

function Magic:TrySetMageCharacter(player, value)
	local data = Tools:GetPlayerData(player)
	if data.IsMageCharacter == nil then
		Magic:SetMageCharacter(player, value)
	end
end

function Magic:MageCharacterUpdate(player)
	if Magic:IsMageCharacter(player) and (not player:IsCoopGhost()) then
		Magic:SetDisplaySpellIcon(player, true)
		Magic:SetDisplaySpellText(player, true)
	else
		Magic:SetDisplaySpellIcon(player, false)
		Magic:SetDisplaySpellText(player, false)
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Magic.MageCharacterUpdate, 0)

function Magic:MPIconOffsetUpdate(player)
	local player_type = player:GetPlayerType()
	local UserIdx = Tools:GetUserIdx(player)
	local hearts = player:GetEffectiveMaxHearts() + player:GetSoulHearts() + (player:GetBrokenHearts() * 2)
	if UserIdx == 0 then
		if Game():IsGreedMode() then
			Magic:AddMPIconAreaOffset(player, "GreedMode", 8, 0)
		else
			Magic:RemoveMPIconAreaOffset(player, "GreedMode")
		end
		if player_type ~= PlayerType.PLAYER_ESAU then
			if hearts > 24 then
				Magic:AddMPIconAreaOffset(player, "AdditionalHPBar", 0, (-2 + math.ceil(hearts / 12)) * 10)
			else
				Magic:RemoveMPIconAreaOffset(player, "AdditionalHPBar")
			end
		end
	else
		local main_player = player
		if player_type == PlayerType.PLAYER_ESAU then
			main_player = player:GetOtherTwin()
			if main_player ~= nil then
				hearts = main_player:GetEffectiveMaxHearts() + main_player:GetSoulHearts() + (main_player:GetBrokenHearts() * 2)
			end
		end
		if UserIdx == 1 then
			if hearts > 18 then
				Magic:AddMPIconAreaOffset(player, "AdditionalHPBar", 0, (-3 + math.ceil(hearts / 6)) * 10)
			else
				Magic:RemoveMPIconAreaOffset(player, "AdditionalHPBar")
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Magic.MPIconOffsetUpdate, 0)

function Magic:GetSpellIconSubNumber(player, spell_ID)
	local SpellReberu = Magic:GetSpellReberu(player, spell_ID)
	if SpellReberu == 0 then
		return ""
	end
	local data = Tools:GetPlayerData(player)
	local SpellMagicType = Magic:GetMagicType(spell_ID)
	local SpellData = Magic:GetSpellDataById(player, spell_ID)
	if SpellMagicType ~= MagicType.DEFENSIVE then
		if SpellMagicType == MagicType.LOCKON then
			local TargetNum = Magic:BaseSpell_GetAttribute(player, MagicType.LOCKON, "TargetNum")
			if TargetNum then
				return math.max(0, Magic:GetMaxTargetNum(spell_ID) - TargetNum)
			end
		elseif SpellMagicType == MagicType.SPECIAL then
			if spell_ID == SpellType.SPELL_DIACUTE then
				local orbs_num = Magic:Spell_GetAttribute(player, spell_ID, "OrbsNum")
				if orbs_num then
					return math.max(0, SpellReberu - orbs_num)
				else
					return SpellReberu
				end
			end
		elseif SpellMagicType == MagicType.AGGRESSIVE then
			return SpellReberu
		end
	end
	return ""
end

function Magic:TransparencyLvToOpacity(TransparencyLv)
	if TransparencyLv < 1 then
		return 1
	end
	local Opacity = {
		[1] = 0.8,
		[2] = 0.65,
		[3] = 0.35,
		[4] = 0.2,
		[5] = 0.1,
		[6] = 0,
	}
	TransparencyLv = math.floor(math.min(TransparencyLv, #Opacity))
	return Opacity[TransparencyLv] or Opacity[1]
end

function Magic:GetSpellIconTransparencyLv(player)
	local data = Tools:GetPlayerData(player)
	return data.SpellIconTransparencyLv or 1
end

function Magic:SetSpellIconTransparencyLv(player, value)
	local data = Tools:GetPlayerData(player)
	data.SpellIconTransparencyLv = value
end

function Magic:SpellIconTransparencyLvUpdate(player)	
	local data = Tools:GetPlayerData(player)
	local UserNum = Tools:GetUserNum()
	if player:GetCard(0) > 0 or player:GetPill(0) > 0 or player:HasCurseMistEffect() then		--待解决：骰子袋提供的临时副手主动如何处理？
		if UserNum > 1 then
			Magic:SetSpellIconTransparencyLv(player, 6)
		else
			Magic:SetSpellIconTransparencyLv(player, 5)
		end
	elseif UserNum > 1 then
		if Magic:GetChangeSpellCountDown(player) <= 0 then
			Magic:SetSpellIconTransparencyLv(player, 4)
		else
			Magic:SetSpellIconTransparencyLv(player, 2)
		end
	else--[[if (Tools:GetEntityRenderScreenPos(player)):Distance(data.SpellIconArea + Vector(4, -24) + Tools:GetHUDOffsetPos(false, true)) <= 44 then
		Magic:SetSpellIconTransparencyLv(player, 3)
	else]]
		Magic:SetSpellIconTransparencyLv(player, 1)
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Magic.SpellIconTransparencyLvUpdate, 0)

function Magic:GetSpellIconOpacity(player)
	local data = Tools:GetPlayerData(player)
	return data.SpellIconOpacity or 0.8
end

function Magic:SetSpellIconOpacity(player, value)
	local data = Tools:GetPlayerData(player)
	data.SpellIconOpacity = math.max(0, math.min(value, 1))
end

function Magic:ModifySpellIconOpacity(player, amount)
	local data = Tools:GetPlayerData(player)
	if data.SpellIconOpacity then
		data.SpellIconOpacity = math.max(0, math.min(data.SpellIconOpacity + amount, 1))
	end
end

function Magic:GetChangeSpellCountDown(player)
	local data = Tools:GetPlayerData(player)
	return data.ChangeSpellCountDown
end

function Magic:SetChangeSpellCountDown(player, value)
	local data = Tools:GetPlayerData(player)
	data.ChangeSpellCountDown = math.max(0, value)
end

function Magic:ModifyChangeSpellCountDown(player, amount)
	local data = Tools:GetPlayerData(player)
	if data.ChangeSpellCountDown then
		data.ChangeSpellCountDown = math.max(0, data.ChangeSpellCountDown + amount)
	end
end

function Magic:SpellIconOpacityUpdate(player)
	local change_rate = 0.05
	local TransparencyLv = Magic:GetSpellIconTransparencyLv(player)
	local FormalOpacity = Magic:TransparencyLvToOpacity(TransparencyLv)
	local RealOpacity = Magic:GetSpellIconOpacity(player, value)
	if math.abs(RealOpacity - FormalOpacity) > 0.01 then
		if RealOpacity > FormalOpacity then
			Magic:ModifySpellIconOpacity(player, -change_rate)
		elseif RealOpacity < FormalOpacity then
			Magic:ModifySpellIconOpacity(player, change_rate)
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Magic.SpellIconOpacityUpdate, 0)

local RenderFlash = 0

local function TryRenderSpellIcon(player)
	local game = Game()
	local ScreenShakeOffset = game.ScreenShakeOffset

	local data = Tools:GetPlayerData(player)
	local num_font = Fonts["number"]
	local SpellIdList = Magic:GetSpellIdList(player)
	local SpellIconArea = data.SpellIconArea or Vector(0, 0)
	if Tools:GetUserNum() == 1 then
		SpellIconArea = SpellIconArea + Tools:GetHUDOffsetPos(false, true) * 0.5
	end
	local SpellIconPath = "gfx/tbom/ui/hud_spell_icon.anm2"
	if data.DisplaySpellIcon then
		local SpellIconColor = Color(1, 1, 1, 0.8, 0, 0, 0)
		local SpellIconKColor = KColor(1, 1, 1, 0.8, 0, 0, 0)
		local alpha = Magic:GetSpellIconOpacity(player)
		SpellIconColor.A = alpha
		SpellIconKColor.Alpha = alpha
		local SpellIconPosOffsetList = Magic:BuildSpellIconPosOffsetList(player)
		local SpellIconList = {}
		for i, ID in pairs(SpellIdList) do
			SpellIconList[i] = {
				icon = Sprite(),
				shade = Sprite(),
				pos = SpellIconArea + (SpellIconPosOffsetList[i] or Vector(0, 0))
			}
		end
		for i, ID in pairs(SpellIdList) do
			local icon = SpellIconList[i].icon
			local shade = SpellIconList[i].shade
			icon:Load(SpellIconPath)
			icon:Play("Icon")
			icon.Color = SpellIconColor
			if Magic:IsSpellUnlocked(player, ID) then
				icon:SetFrame(1)
			else
				icon:SetFrame(0)
			end
			icon:ReplaceSpritesheet(0, Magic:GetGFX(ID))
			icon:LoadGraphics()
			icon:Render(SpellIconList[i].pos)
			shade:Load(SpellIconPath)
			shade:Play("Shade")
			shade.Color = SpellIconColor
			if not Magic:CanToggleSpell(player, ID, false) then
				if not Magic:IsSpellUnlocked(player, ID) then
					shade:SetFrame(0)
				elseif Magic:IsSpellRecharged(player, ID, true) then
					shade:SetFrame(1)
				elseif Magic:GetFormalCD(ID) ~= 0 then
					shade:SetFrame(math.ceil((Magic:GetSpellCD(player, ID) / Magic:GetFormalCD(ID)) * 33))
				else
					shade:SetFrame(1)
				end
			else
				if not Magic:IsSpellRecharged(player, ID, true) then
					shade:SetFrame(math.ceil((Magic:GetSpellCD(player, ID) / Magic:GetFormalCD(ID)) * 33))
				else
					shade:SetFrame(0)
				end
			end
			shade:Render(SpellIconList[i].pos)
			local sub_num = Magic:GetSpellIconSubNumber(player, ID)
			num_font:DrawString(sub_num, SpellIconList[i].pos.X + 1.5 + ScreenShakeOffset.X, SpellIconList[i].pos.Y - 4 + ScreenShakeOffset.Y, SpellIconKColor, 0, true)
		end
		local CurrentSpellKey = Magic:GetCurrentSpellKey(player)
		local CurrentSpellID = Magic:GetCurrentSpellId(player)
		local IsUsingCurrentSpell = Magic:IsUsingSpell(player, CurrentSpellID)
		local SpellIconCursor = Sprite()
		SpellIconCursor:Load(SpellIconPath)
		SpellIconCursor:Play("Cursor")
		SpellIconCursor.Color = SpellIconColor
		SpellIconCursor:SetFrame(0)
		if IsUsingCurrentSpell == true then
			SpellIconCursor:SetFrame(1)
		end
		SpellIconCursor:Render(SpellIconList[CurrentSpellKey].pos or Vector(0, 0))
	end
end

local function TryRenderSpellText(player)
	local game = Game()
	local ScreenShakeOffset = game.ScreenShakeOffset

	local data = Tools:GetPlayerData(player)
	local text_font = Fonts[Options.Language] or Fonts["en"]
	local SpellTextArea = data.SpellTextArea or Vector(0, 0)
	if Tools:GetUserNum() == 1 then
		SpellTextArea = SpellTextArea + Tools:GetHUDOffsetPos(false, true) * 0.5
	end
	if data.DisplaySpellText then
		local scale = 1
		local scale_smol = 0.75
		local scale_offsetY = 14
		local CurrentSpellKey = Magic:GetCurrentSpellKey(player)
		local CurrentSpellID = Magic:GetCurrentSpellId(player)
		local SpellTextKColor = KColor(1, 1, 1, 0.8, 0, 0, 0)
		local SpellTextKColor_Red = KColor(1, 0, 0, 0.8, 0, 0, 0)
		local SpellTextKColor_Flash = SpellTextKColor
		if Magic:IsUsingSpell(player, CurrentSpellID) then
			SpellTextKColor_Flash = KColor(1 - math.abs(math.sin(RenderFlash * (math.pi / 60))), 1 ,1 - math.abs(math.sin(RenderFlash * (math.pi / 60))), 0.8)
		end
		local alpha = Magic:GetSpellIconOpacity(player, value)
		SpellTextKColor.Alpha = alpha
		SpellTextKColor_Red.Alpha = alpha
		SpellTextKColor_Flash.Alpha = alpha
		if Tools:GetUserNum() > 1 then
			scale = 0.8
			scale_smol = 0.75
			scale_offsetY = 12
		end
		text_font:DrawStringScaledUTF8(Magic:GetActualName(player, CurrentSpellID, Options.Language), 
										SpellTextArea.X + ScreenShakeOffset.X, SpellTextArea.Y + ScreenShakeOffset.Y, 
										scale, scale, 
										SpellTextKColor_Flash, 10, true)

		if Magic:CanToggleSpell(player, CurrentSpellID, false) then
			SpellTextKColor_Red = SpellTextKColor 
		end
		text_font:DrawStringScaledUTF8(Magic:GetActualDesc(player, CurrentSpellID, Options.Language), 
										SpellTextArea.X + ScreenShakeOffset.X, SpellTextArea.Y + scale_offsetY + ScreenShakeOffset.Y, 
										scale_smol, scale_smol, 
										SpellTextKColor_Red, 10, true)
	end
end

function Magic:OnRender()
	local game = Game()
	local ScreenShakeOffset = game.ScreenShakeOffset
	local NumPlayers = game:GetNumPlayers()
	if Tools:CanShowHUD() then
		for p = 0, NumPlayers - 1 do
			local player = game:GetPlayer(p)
			local data = Tools:GetPlayerData(player)
			local text_font = Fonts[Options.Language] or Fonts["en"]
			local num_font = Fonts["number"]
			local SpellIdList = Magic:GetSpellIdList(player)
			local MPIconArea = (data.MPIconArea or Vector(0, 0)) + Tools:GetPlayerHUDOffsetPos(player)
			local SpellIconArea = data.SpellIconArea or Vector(0, 0)
			local SpellTextArea = data.SpellTextArea or Vector(0, 0)
			if Tools:GetUserNum() == 1 then
				SpellIconArea = SpellIconArea + Tools:GetHUDOffsetPos(false, true)
				SpellTextArea = SpellTextArea + Tools:GetHUDOffsetPos(false, true)
			end
			local MPIconPath = "gfx/tbom/ui/hud_mana_icon.anm2"
		
			if data.DisplayMPIcon then
				local MPIconPos = MPIconArea + Vector(-8, 8)
				local MPTextPos = MPIconArea + ScreenShakeOffset
				local MPIconColor = Color(1, 1, 1, 0.65, 0, 0, 0)
				local MPIconKColor = KColor(1, 1, 1, 0.65, 0, 0, 0)
				local MPIcon = Sprite()
				MPIcon:Load(MPIconPath)
				MPIcon:Play("Idle")
				MPIcon.Color = MPIconColor
				MPIcon:Render(MPIconPos)

				local CurrentMadouRyoku = tostring(Maths:Fix_Round(data.MadouRyoku, 1))
				local CurrentMadouJyougen = tostring(Maths:Fix_Round(Magic:GetMadouJyougen(player), 1))
				if Magic:HasInfiniteMP(player) then
					CurrentMadouRyoku = "INF"
					CurrentMadouJyougen = "INF"
				end
				num_font:DrawString(CurrentMadouRyoku.."/"..CurrentMadouJyougen, MPTextPos.X, MPTextPos.Y, MPIconKColor, 0, true)
			end
			--if Tools:GetUserNum() == 1 then
				TryRenderSpellIcon(player)
				TryRenderSpellText(player)
			--end
		end
	end
	if not game:IsPaused() then
		RenderFlash = (RenderFlash + 0.5) % 120
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_RENDER, Magic.OnRender)

--function Magic:PostPlayerRender(player, offset)
--	if Tools:GetUserNum() > 1 then
--		TryRenderSpellIcon(player)
--		TryRenderSpellText(player)
--	end
--end
--ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, Magic.PostPlayerRender, 0)

function Magic:Input_GetTiggeredKey_Switch(player)	--//
	local SpellNum = Magic:GetUseableSpellNum(player)
	local idx = player.ControllerIndex
	local key = {
		[1] = Input.IsButtonTriggered(Keyboard.KEY_1, idx), 
		[2] = Input.IsButtonTriggered(Keyboard.KEY_2, idx), 
		[3] = Input.IsButtonTriggered(Keyboard.KEY_3, idx), 
		[4] = Input.IsButtonTriggered(Keyboard.KEY_4, idx), 
		[5] = Input.IsButtonTriggered(Keyboard.KEY_5, idx), 
		[6] = Input.IsButtonTriggered(Keyboard.KEY_6, idx), 
		[7] = Input.IsButtonTriggered(Keyboard.KEY_7, idx), 
		[8] = Input.IsButtonTriggered(Keyboard.KEY_8, idx), 
		[9] = Input.IsButtonTriggered(Keyboard.KEY_9, idx), 
		[10] = Input.IsButtonTriggered(Keyboard.KEY_0, idx), 
		[11] = Input.IsButtonTriggered(Keyboard.KEY_MINUS, idx), 
		[12] = Input.IsButtonTriggered(Keyboard.KEY_EQUAL, idx), 
	}
	for i = 1, #key do
		if i <= SpellNum and key[i] then
			return i
		end
	end
	return nil
end

function Magic:Input_GetKeyConfigByPlayer(player)	--//
	local prefix = "P"..tostring(Tools:GetUserIdx(player) + 1).." "
	local cfg = {
		left_keybord = KeyConfig[prefix.."change spell 1 (Keyboard)"] or Keyboard.KEY_LEFT_ALT,
		right_keybord = KeyConfig[prefix.."change spell 2 (Keyboard)"] or Keyboard.KEY_RIGHT_CONTROL,
		left_controller = KeyConfig[prefix.."change spell 1 (Controller)"] or 0,
		right_controller = KeyConfig[prefix.."change spell 2 (Controller)"] or 1,
	}
	return cfg
end

function Magic:Input_GetTiggeredKey_Move(player)	--返回值为真则向左移动
	local cfg = Magic:Input_GetKeyConfigByPlayer(player)
	local idx = player.ControllerIndex
	if Input.IsButtonTriggered(cfg.left_keybord, idx) or Input.IsButtonTriggered(cfg.left_controller, idx) then
		return true
	elseif Input.IsButtonTriggered(cfg.right_keybord, idx) or Input.IsButtonTriggered(cfg.right_controller, idx) then
		return false
	end
	return nil
end

function Magic:Input_PostPlayerUpdate(player)
	--local NumPlayers = Game():GetNumPlayers()
	if Magic:IsMageCharacter(player) then
		local TiggeredKey_Switch = Magic:Input_GetTiggeredKey_Switch(player)
		if TiggeredKey_Switch and (not Magic:HasFlag(player, MagicFlag.FLAG_NUMBER_KEY_DISABLED)) then
			local try_enable = true
			local try_use = false
			if Magic:GetMagicType(TiggeredKey_Switch) == MagicType.SPECIAL then
				try_use = true
			end
			Magic:TrySwitchCurrentSpellKey(player, TiggeredKey_Switch, try_enable, try_use)
			Magic:SetChangeSpellCountDown(player, 120)
		end

		local TiggeredKey_Move = Magic:Input_GetTiggeredKey_Move(player)
		if TiggeredKey_Move ~= nil and (not Magic:HasFlag(player, MagicFlag.FLAG_CANNOT_SWITCH_SPELL)) then
			Magic:TryMoveCurrentSpellKey(player, TiggeredKey_Move)
			Magic:SetChangeSpellCountDown(player, 120)
		end
	end

	Magic:ModifyChangeSpellCountDown(player, -1)
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Magic.Input_PostPlayerUpdate)

return Magic