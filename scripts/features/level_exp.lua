local LevelExp = {}
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
local Magic = tbom.Magic
local tbomCallbacks = tbom.tbomCallbacks
local modCollectibleType = tbom.modCollectibleType
local modEffectVariant = tbom.modEffectVariant

function LevelExp:PlayerDataInit(player, starting_exp, starting_real_reberu)
	local data = Tools:GetPlayerData(player)
	if data.Exp == nil then
		data.Exp = starting_exp or 0
	end
	if data.FormalReberu == nil then
		data.FormalReberu = 0
	end
	if data.RealReberu == nil then
		data.RealReberu = starting_real_reberu or 0
	end
	if data.ExpMulti == nil then
		data.ExpMulti = 1
	end
	if data.ExpBarArea == nil then
		data.ExpBarArea = Vector(0, 0)
	end
	if data.ExpTextArea == nil then
		data.ExpTextArea = Vector(0, 0)
	end
	if data.HighExpMulti == nil then
		data.HighExpMulti = false
	end
	if data.DisplayExpBar == nil then
		data.DisplayExpBar = false
	end
	if data.StatsCacheFlags == nil then
		data.StatsCacheFlags = {}
	end
	if data.ExpBarAreaOffset == nil then
		data.ExpBarAreaOffset = {}
	end
	if data.ExpTextAreaOffset == nil then
		data.ExpTextAreaOffset = {}
	end
	if data.ExpMultiAttribute == nil then
		data.ExpMultiAttribute = {}
	end
	if data.UnlockableSpellList == nil then
		data.UnlockableSpellList = {}
	end
end

function LevelExp:ClearLevelExpData(player)
	local data = Tools:GetPlayerData(player)
	data.IsRPGCharacter = nil		--角色是否启用等级机制（逻辑）
	data.FormalReberu = nil			--形式等级（每帧刷新）（整数）
	data.RealReberu = nil			--实际等级（整数）
	data.Exp = nil					--经验值（整数）
	--data.ExpMulti = nil			--经验值倍率（每帧刷新）（浮点数）
	data.ExpBarArea = nil			--经验条锚点位置矢量（矢量）
	data.ExpTextArea = nil			--经验条文字位置矢量（矢量）
	data.HighExpMulti = nil			--启用高经验值倍率（逻辑）
	data.DisplayExpBar = nil		--显示经验条（逻辑）
	------
	data.StatsCacheFlags = nil		--属性加成缓存标记（数组）
	data.ExpBarAreaOffset = nil		--经验条锚点偏移（散列表）
	data.ExpTextAreaOffset = nil	--经验条文字偏移（散列表）
	data.ExpMultiAttribute = nil	--经验值倍率缓存（散列表）
	data.UnlockableSpellList = nil	--可解锁法术列表（散列表）
end

function LevelExp:FormalReberu2Exp(Reberu)
	local Exp = 0
	if Reberu > 0 then
		if Reberu <= 16 then
			Exp = Reberu ^ 2 + Reberu * 6
		elseif Reberu <= 31 then
			Exp = (Reberu ^ 2) * 2.5 - Reberu * 40.5 + 360
		else
			Exp = (Reberu ^ 2) * 4.5 - Reberu * 162.5 + 2220
		end
	else
		Exp = 0
	end
	return Exp
end

function LevelExp:Exp2FormalReberu(Exp)
	local Reberu = 0
	if Exp > 0 then
		if Exp <= 390 then
			Reberu = math.sqrt(Exp + 9) - 3
		elseif Exp <= 1623 then
			Reberu = (math.sqrt(40 * Exp - 7839) + 81) / 10
		else
			Reberu = (math.sqrt(72 * Exp - 54215) + 325) / 18
		end
	else
		Reberu = 0
	end
	return math.floor(Reberu)
end

function LevelExp:IsRPGCharacter(player)
	local player_type = player:GetPlayerType()
	local data = Tools:GetPlayerData(player)
	return data.IsRPGCharacter == true
		or player_type == modPlayerType.PLAYER_ARLENADJA 
		or player_type == modPlayerType.PLAYER_DOPPELGANGERARLE
end

function LevelExp:SetRPGCharacter(player, value)
	local data = Tools:GetPlayerData(player)
	data.IsRPGCharacter = value
end

function LevelExp:TrySetRPGCharacter(player, value)
	local data = Tools:GetPlayerData(player)
	if data.IsRPGCharacter == nil then
		LevelExp:SetRPGCharacter(player, value)
	end
end

function LevelExp:SetDisplayExpBar(player, value)
	local data = Tools:GetPlayerData(player)
	if data.DisplayExpBar ~= nil then
		data.DisplayExpBar = value
	end
end

function LevelExp:RPGCharacterUpdate(player)
	if LevelExp:IsRPGCharacter(player) and (not player:IsCoopGhost()) then	--规定：多人模式下死亡后不可显示经验条
		LevelExp:SetDisplayExpBar(player, true)
	else
		LevelExp:SetDisplayExpBar(player, false)
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, LevelExp.RPGCharacterUpdate, 0)

function LevelExp:GetExp(player)
	local data = Tools:GetPlayerData(player)
	return data.Exp or 0
end

function LevelExp:SetExp(player, value)
	local data = Tools:GetPlayerData(player)
	if data.Exp then
		data.Exp = math.max(0, value)
	end
end

function LevelExp:ModifyExp(player, amount)
	local data = Tools:GetPlayerData(player)
	if data.Exp then
		data.Exp = math.max(0, data.Exp + amount)
	end
end

function LevelExp:GetFormalReberu(player)
	local data = Tools:GetPlayerData(player)
	return data.FormalReberu or 0
end

function LevelExp:FormalReberuUpdate(player)
	local data = Tools:GetPlayerData(player)
	local Exp = (data.Exp or 0)
	data.FormalReberu = LevelExp:Exp2FormalReberu(Exp)
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, LevelExp.FormalReberuUpdate)

function LevelExp:GetRealReberu(player)
	local data = Tools:GetPlayerData(player)
	return data.RealReberu or 0
end

function LevelExp:ModifyRealReberu(player, amount)
	local data = Tools:GetPlayerData(player)
	if data.RealReberu and data.FormalReberu then
		data.RealReberu = math.max(0, math.min(data.FormalReberu, data.RealReberu + amount))
	end
end

function LevelExp:EvaluateUpgradeAward(player, award_flag)
	local new_flag = 1
	while new_flag <= award_flag and new_flag <= (1 << 31) do
		if new_flag & award_flag > 0 then
			Isaac.RunCallback(tbomCallbacks.TBOMC_PRE_GET_UPGRADE_AWARD, player, new_flag)
		end
		new_flag = new_flag * 2
	end
end

function LevelExp:TryLevelUp(player, award_flag)
	if LevelExp:IsRPGCharacter(player) then
		if LevelExp:GetRealReberu(player) < LevelExp:GetFormalReberu(player) then
			local HUD = Game():GetHUD()
			local lang = Options.Language
			local lang_fixed = Translation:FixLanguage(lang)
			local texts_name = {["en"] = "Level Up! ", ["zh"] = "等级上升",}
			HUD:ShowItemText(texts_name[lang_fixed], "")
			LevelExp:EvaluateUpgradeAward(player, award_flag)
			LevelExp:ModifyRealReberu(player, 1)
		end
	end
end

function LevelExp:ShowAdditionalText(player)
	local HUD = Game():GetHUD()
	local lang = Options.Language
	local lang_fixed = Translation:FixLanguage(lang)
	if LevelExp:IsRPGCharacter(player) then
		if LevelExp:GetFormalReberu(player) >= 15 and (not Tools:GameData_GetAttribute("BossRushTextShowed")) then
			local texts_name = {["en"] = "Level Up! ", ["zh"] = "等级上升",}
			local texts_desc = {["en"] = "The depth grows restless...", ["zh"] = "深牢变得焦躁不安...",}
			HUD:ShowItemText(texts_name[lang_fixed], texts_desc[lang_fixed])
			Tools:GameData_SetAttribute("BossRushTextShowed", true)
		end
		if LevelExp:GetFormalReberu(player) >= 25 and (not Tools:GameData_GetAttribute("BlueWombTextShowed")) then
			local texts_name = {["en"] = "Level Up! ", ["zh"] = "等级上升",}
			local texts_desc = {["en"] = "Screams are echoing from the womb...", ["zh"] = "子宫中回荡着尖叫声...",}
			HUD:ShowItemText(texts_name[lang_fixed], texts_desc[lang_fixed])
			Tools:GameData_SetAttribute("BlueWombTextShowed", true)
		end
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CallbackPriority.LATE, LevelExp.ShowAdditionalText)

function LevelExp:GetExpMulti(player)
	if player:IsCoopGhost() then	--多人模式死亡惩罚
		return 0
	end
	local data = Tools:GetPlayerData(player)
	local sum = 1
	local ExpMultiAttribute = data.ExpMultiAttribute
	if ExpMultiAttribute then
		for i, attribute in pairs(ExpMultiAttribute) do
			if attribute then
				sum = sum + attribute
			end
		end
	end
	return sum
end

function LevelExp:ExpMulti_AddAttribute(player, key, starting_value)
	local data = Tools:GetPlayerData(player)
	local ExpMultiAttribute = data.ExpMultiAttribute
	if ExpMultiAttribute and ExpMultiAttribute[key] == nil and type(key) == "string" and type(starting_value) == "number" then
		ExpMultiAttribute[key] = starting_value
	end
end

function LevelExp:ExpMulti_GetAttribute(player, key)
	local data = Tools:GetPlayerData(player)
	local ExpMultiAttribute = data.ExpMultiAttribute
	if ExpMultiAttribute and type(key) == "string" then
		return ExpMultiAttribute[key]
	end
	return nil
end

function LevelExp:ExpMulti_SetAttribute(player, key, value)
	local data = Tools:GetPlayerData(player)
	local ExpMultiAttribute = data.ExpMultiAttribute
	if ExpMultiAttribute and type(key) == "string" and type(value) == "number" then
		ExpMultiAttribute[key] = value
	end
end

function LevelExp:ExpMulti_ModifyAttribute(player, key, amount)
	local data = Tools:GetPlayerData(player)
	local ExpMultiAttribute = data.ExpMultiAttribute
	if ExpMultiAttribute and type(key) == "string" and type(amount) == "number" then
		ExpMultiAttribute[key] = ExpMultiAttribute[key] + amount
	end
end

function LevelExp:ExpMulti_ClearAttribute(player, key)
	local data = Tools:GetPlayerData(player)
	local ExpMultiAttribute = data.ExpMultiAttribute
	if ExpMultiAttribute and type(key) == "string" and ExpMultiAttribute[key] ~= nil then
		ExpMultiAttribute[key] = nil
	end
end

function LevelExp:EnableHighExpMulti(player)
	local data = Tools:GetPlayerData(player)
	data.HighExpMulti = true
end

function LevelExp:DisableHighExpMulti(player)
	local data = Tools:GetPlayerData(player)
	data.HighExpMulti = false
end

function LevelExp:ToggleHighExpMulti(player)
	if LevelExp:HasHighExpMulti(player) then
		LevelExp:DisableHighExpMulti(player)
	else
		LevelExp:EnableHighExpMulti(player)
	end
end

function LevelExp:HasHighExpMulti(player)
	local data = Tools:GetPlayerData(player)
	return data.HighExpMulti == true
end

function LevelExp:DebugFlagUpdate(player)
	if LevelExp:HasHighExpMulti(player) then
		LevelExp:ExpMulti_SetAttribute(player, "DebugFlag_HighExpMulti", 5)
	else
		LevelExp:ExpMulti_ClearAttribute(player, "DebugFlag_HighExpMulti")
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, LevelExp.DebugFlagUpdate)

function LevelExp:SpawnExp(player, position, amount)
	local multi = LevelExp:GetExpMulti(player)
	for i = 1, amount * multi do
		local velocity = RandomVector() * 30
		local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, modEffectVariant.EXP, 0, position, velocity, player)
		effect.Target = player
		local data = Tools:GetEffectData(effect)
		data.Target = player
	end
end

function LevelExp:GetFinalBossExp(entity)
	local FinalBosses = {
		[1] = {Type = EntityType.ENTITY_MOM, Variant = 10, ExpAmount = 40,},
		[2] = {Type = EntityType.ENTITY_MOMS_HEART, Variant = 0, AltVariant = 1, ExpAmount = 50,},
		[3] = {Type = EntityType.ENTITY_MOMS_HEART, Variant = 1, AltVariant = 0, ExpAmount = 50,},
		[4] = {Type = EntityType.ENTITY_SATAN, Variant = 10, ExpAmount = 100 / 2,},
		[5] = {Type = EntityType.ENTITY_ISAAC, Variant = 0, AltVariant = 1, ExpAmount = 100,},
		[6] = {Type = EntityType.ENTITY_ISAAC, Variant = 1, AltVariant = 0, ExpAmount = 150,},
		[7] = {Type = EntityType.ENTITY_THE_LAMB, Variant = 0, ExpAmount = 150,},
		[8] = {Type = EntityType.ENTITY_MEGA_SATAN_2, Variant = 0, FalseType = EntityType.ENTITY_MEGA_SATAN, ExpAmount = 200,},
		[9] = {Type = EntityType.ENTITY_HUSH, Variant = 0, ExpAmount = 200,},
		[10] = {Type = EntityType.ENTITY_DELIRIUM, Variant = 0, ExpAmount = 300,},
		[11] = {Type = EntityType.ENTITY_ULTRA_GREED, Variant = 1, ExpAmount = 0,},
		[12] = {Type = EntityType.ENTITY_MOTHER, Variant = 10, ExpAmount = 0,},
		[13] = {Type = EntityType.ENTITY_DOGMA, Variant = 0, ExpAmount = 150,},
		[14] = {Type = EntityType.ENTITY_BEAST, Variant = 0, ExpAmount = 0,},
	}
	for i = 1, #FinalBosses do
		if entity.Type == FinalBosses[i].Type then
			if entity.Variant == FinalBosses[i].Variant then
				return FinalBosses[i].ExpAmount
			elseif FinalBosses[i].AltVariant and (entity.Variant == FinalBosses[i].AltVariant) then
				goto GetFinalBossExp_CONTINUE
			else
				return 0
			end
		elseif FinalBosses[i].FalseType and (entity.Type == FinalBosses[i].FalseType) then
			return 0
		end
		::GetFinalBossExp_CONTINUE::
	end
	return nil
end

function LevelExp:GetStatsCacheFlags(player)
	local data = Tools:GetPlayerData(player)
	return data.StatsCacheFlags or {}
end

function LevelExp:AddStatsCacheFlags(player, caflag)
	local data = Tools:GetPlayerData(player)
	table.insert(data.StatsCacheFlags, caflag)
	player:AddCacheFlags(caflag)
	player:EvaluateItems()
end

function LevelExp:GetUnlockableSpellList(player)
	local data = Tools:GetPlayerData(player)
	return data.UnlockableSpellList or {}
end

function LevelExp:SetUnlockableSpellList(player, spell_ID_list)
	local data = Tools:GetPlayerData(player)
	local list = {}
	if type(spell_ID_list) == "table" then
		list = spell_ID_list
	end
	data.UnlockableSpellList = list
end

function LevelExp:TrySetUnlockableSpellList(player, spell_ID_list)
	local data = Tools:GetPlayerData(player)
	if Common:IsTableEmpty(data.UnlockableSpellList) then
		LevelExp:SetUnlockableSpellList(player, spell_ID_list)
	end
end

function LevelExp:TryUpgradeUnlockableSpell(player)		--列表中包含所需等级和法术ID时才可使用此函数
	local data = Tools:GetPlayerData(player)
	local UnlockableSpellList = (data.UnlockableSpellList or {})
	local RealReberu = data.RealReberu
	local key = tostring(RealReberu + 1)
	if RealReberu and key then
		local spell_ID = (UnlockableSpellList[key] or SpellType.SPELL_INVALID)
		if Magic:CanUpgradeSpell(player, spell_ID) then
			local texts_name = {["en"] = "Level up! ", ["zh"] = "等级上升",}
			local HUD = Game():GetHUD()
			local lang = Options.Language
			local lang_fixed = Translation:FixLanguage(lang)
			HUD:ShowItemText(texts_name[lang_fixed], Magic:GetUpgradeText(player, spell_ID, lang_fixed))
			Magic:TryUpgradeSpell(player, spell_ID)
		end
	end
end

function LevelExp:GetHighestExpPlayer()
	local NumPlayers = Game():GetNumPlayers()
	local player0 = Isaac.GetPlayer(0)
	local exp0 = LevelExp:GetExp(player0)
	for p = 1, NumPlayers - 1 do
		local player = Isaac.GetPlayer(p)
		local exp = LevelExp:GetExp(player)
		if exp > exp0 then
			player0 = player
			exp0 = exp
		end
	end
	return player0
end

function LevelExp:CanOpenBossRush(include_boss_exp)
	local MomExpAmount = 40
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = Isaac.GetPlayer(p)
		if LevelExp:IsRPGCharacter(player) then
			local exp = LevelExp:GetExp(player)
			local required_exp = LevelExp:FormalReberu2Exp(15)
			if include_boss_exp == true then
				required_exp = required_exp - (MomExpAmount * LevelExp:GetExpMulti(player))
			end
			if exp >= required_exp then
				return true
			end
		end
	end
	return false
end

function LevelExp:CanOpenBlueWomb(include_boss_exp)
	local MomsHeartExpAmount = 50
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = Isaac.GetPlayer(p)
		if LevelExp:IsRPGCharacter(player) then
			local exp = LevelExp:GetExp(player)
			local required_exp = LevelExp:FormalReberu2Exp(25)
			if include_boss_exp == true then
				required_exp = required_exp - (MomsHeartExpAmount * LevelExp:GetExpMulti(player))
			end
			if exp >= required_exp then
				return true
			end
		end
	end
	return false
end

function LevelExp:PostNPCDeath(npc)
	local NumPlayers = Game():GetNumPlayers()
	local room = Game():GetRoom()
	local hp = npc.MaxHitPoints
	local amount = math.max(1, math.floor(hp / 20))

	--不要把判断妈腿是否死亡放在这里，否则BOSS战音乐不会停止

	if npc:IsBoss() then
		local amount_fixed = LevelExp:GetFinalBossExp(npc)
		if amount_fixed ~= nil then
			amount = amount_fixed
			for p = 0, NumPlayers - 1 do
				local player = Isaac.GetPlayer(p)
				if LevelExp:IsRPGCharacter(player) then
					LevelExp:SpawnExp(player, npc.Position, amount)
				end
			end
			return
		end
	end
	if not npc:HasEntityFlags(EntityFlag.FLAG_ICE_FROZEN) then
		if not (npc.ParentNPC) and (not EntityRef(npc).IsFriendly) then
			if (not npc.SpawnerType) or npc.SpawnerType == 0 then
				if npc:IsChampion() then
					amount = amount + 1
				end
				for p = 0, NumPlayers - 1 do
					local player = Isaac.GetPlayer(p)
					if LevelExp:IsRPGCharacter(player) then
						LevelExp:SpawnExp(player, npc.Position, amount)
					end
				end
				return
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, LevelExp.PostNPCDeath, nil)

function LevelExp:PostEntityKill(entity)
	local NumPlayers = Game():GetNumPlayers()
	if entity:IsActiveEnemy(true) and entity:HasEntityFlags(EntityFlag.FLAG_ICE) and (not entity:HasEntityFlags(EntityFlag.FLAG_ICE_FROZEN)) then
		local npc = entity:ToNPC()
		local hp = npc.MaxHitPoints
		local amount = math.max(1, math.floor(hp / 20))

		if (not EntityRef(npc).IsFriendly) then
			if (not npc.SpawnerType) or npc.SpawnerType == 0 then
				if npc:IsChampion() then
					amount = amount + 1
				end
				for p = 0, NumPlayers - 1 do
					local player = Isaac.GetPlayer(p)
					if LevelExp:IsRPGCharacter(player) then
						LevelExp:SpawnExp(player, npc.Position, amount)
					end
				end
				return
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, LevelExp.PostEntityKill, nil)

function LevelExp:PostMomKill(entity)
	local room = Game():GetRoom()
	if entity:IsBoss() and entity.Variant == 10 and (not Tools:GameData_GetAttribute("MonKilled")) then
		if LevelExp:CanOpenBossRush(true) then
			room:TrySpawnBossRushDoor(true)
		end
		Tools:GameData_SetAttribute("MonKilled", true)
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, LevelExp.PostMomKill, EntityType.ENTITY_MOM)

function LevelExp:PostMomsHeartDeath(npc)
	local room = Game():GetRoom()
	local NumPlayers = Game():GetNumPlayers()
	if npc:IsBoss() and (not Tools:GameData_GetAttribute("MomsHeartKilled")) then
		for p = 0, NumPlayers - 1 do
			local player = Isaac.GetPlayer(p)
			if LevelExp:IsRPGCharacter(player) then
				local HUD = Game():GetHUD()
				local texts_name = {["en"] = "Magic power up! ", ["zh"] = "魔法强化",}
				local lang_fixed = Translation:FixLanguage(Options.Language)
				if player:GetPlayerType() == modPlayerType.PLAYER_ARLENADJA then
					local spell_ID = SpellType.SPELL_DIACUTE
					if Magic:CanUpgradeSpell(player, spell_ID) then
						HUD:ShowItemText(texts_name[lang_fixed], Magic:GetUpgradeText(player, spell_ID, lang_fixed))
						Magic:TryUpgradeSpell(player, spell_ID)
					end
				end
			end
		end
		if LevelExp:CanOpenBlueWomb(true) == true then
			room:TrySpawnBlueWombDoor(false, true)
		end
		Tools:GameData_SetAttribute("MomsHeartKilled", true)
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, LevelExp.PostMomsHeartDeath, EntityType.ENTITY_MOMS_HEART)

function LevelExp:TrySpawnDoor()
	local level = Game():GetLevel()
	local stage = level:GetStage()
	if Tools:GameData_GetAttribute("BossRushTextShowed") and (stage == LevelStage.STAGE3_1 or stage == LevelStage.STAGE3_2) then	--考虑迷宫诅咒
		local room = level:GetCurrentRoom()
		if room:IsClear() and room:GetBossID() == 6 then
			room:TrySpawnBossRushDoor(true)
		end
	end
	if Tools:GameData_GetAttribute("BlueWombTextShowed") and (stage == LevelStage.STAGE4_1 or stage == LevelStage.STAGE4_2) then
		local room = level:GetCurrentRoom()
		if room:IsClear() then
			room:TrySpawnBlueWombDoor(true, true)
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, LevelExp.TrySpawnDoor)

function LevelExp:AddExpBarAreaOffset(player, key, offset_X, offset_Y)
	local data = Tools:GetPlayerData(player)
	if type(key) == "string" then
		data.ExpBarAreaOffset = data.ExpBarAreaOffset or {}
		data.ExpBarAreaOffset[key] = Vector(offset_X, offset_Y)
	end
end

function LevelExp:RemoveExpBarAreaOffset(player, key)
	local data = Tools:GetPlayerData(player)
	if type(key) == "string" and data.ExpBarAreaOffset then
		data.ExpBarAreaOffset[key] = nil
	end
end

function LevelExp:AddExpTextAreaOffset(player, key, offset_X, offset_Y)
	local data = Tools:GetPlayerData(player)
	if type(key) == "string" then
		data.ExpTextAreaOffset = data.ExpTextAreaOffset or {}
		data.ExpTextAreaOffset[key] = Vector(offset_X, offset_Y)
	end
end

function LevelExp:RemoveExpTextAreaOffset(player, key)
	local data = Tools:GetPlayerData(player)
	if type(key) == "string" and data.ExpTextAreaOffset then
		data.ExpTextAreaOffset[key] = nil
	end
end

function LevelExp:ExpBarAreaUpdate(player)
	local data = Tools:GetPlayerData(player)
	local AnchorX = 158
	local AnchorY = 20
	local BarOffset = Vector(0, 0)
	local UserIdx = Tools:GetUserIdx(player)
	if UserIdx >= 1 and data.MPIconArea then
		if UserIdx >= 2 then
			AnchorY = (data.MPIconArea.Y or 0) - 4
		else
			AnchorY = (data.MPIconArea.Y or 0) + 20
		end
		AnchorX = (data.MPIconArea.X or 0) + 8
	end
	if data.ExpBarArea then
		data.ExpBarArea = Vector(AnchorX, AnchorY)
		if data.ExpBarAreaOffset then
			for _, vec in pairs(data.ExpBarAreaOffset) do
				if vec ~= nil then
					BarOffset = BarOffset + vec
				end
			end
		end
		data.ExpBarArea = data.ExpBarArea + BarOffset
	end
	local TextOffset = Vector(0, 0)
	if data.ExpTextArea then
		if UserIdx >= 1 then
			data.ExpTextArea = Vector(AnchorX, AnchorY) + Vector(-4, -7)
		else
			data.ExpTextArea = Vector(AnchorX, AnchorY) + Vector(-4, -16)
		end
		if data.ExpTextAreaOffset then
			for _, vec in pairs(data.ExpTextAreaOffset) do
				if vec ~= nil then
					TextOffset = TextOffset + vec
				end
			end
		end
		data.ExpTextArea = data.ExpTextArea + TextOffset
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, LevelExp.ExpBarAreaUpdate)

function LevelExp:OnRender()	--经验值进度条
	local game = Game()
	local ScreenShakeOffset = game.ScreenShakeOffset
	local NumPlayers = Game():GetNumPlayers()
	if Tools:CanShowHUD() then
		for p = 0, NumPlayers - 1 do
			local player = Game():GetPlayer(p)
			local data = Tools:GetPlayerData(player)
			local ExpBarArea = (data.ExpBarArea or Vector(0, 0)) + Tools:GetPlayerHUDOffsetPos(player)
			local ExpTextArea = (data.ExpTextArea or Vector(0, 0)) + Tools:GetPlayerHUDOffsetPos(player)
			if data.DisplayExpBar then
				local ExpBarColor = Color(1, 1, 1, 0.8, 0, 0, 0)
				local ExpBar = Sprite()
				ExpBar:Load("gfx/tbom/ui/hud_exp_bar.anm2")
				ExpBar:Play("Idle")
				ExpBar.Color = ExpBarColor
				local FormalReberu = LevelExp:GetFormalReberu(player)
				local ExpRate = Maths:Fix_Round(((LevelExp:GetExp(player) - LevelExp:FormalReberu2Exp(FormalReberu)) / (LevelExp:FormalReberu2Exp(FormalReberu + 1) - LevelExp:FormalReberu2Exp(FormalReberu))), 3)
				local frame = math.floor(ExpRate * 20)
				ExpBar:SetFrame(frame)
				ExpBar:Render(Vector(ExpBarArea.X, ExpBarArea.Y))

				local ExpTextKColor = KColor(1, 1, 1, 0.8, 0, 0, 0)
				local font = Fonts["number"]
				font:DrawString("Lv. "..tostring(FormalReberu), 
					ExpTextArea.X + ScreenShakeOffset.X, ExpTextArea.Y + ScreenShakeOffset.Y, 
					ExpTextKColor, 10, true)
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_RENDER, LevelExp.OnRender)

function LevelExp:ResetData(isContinued)
	if not isContinued then
		Tools:GameData_ClearAttribute("BossRushTextShowed")
		Tools:GameData_ClearAttribute("BlueWombTextShowed")
		Tools:GameData_ClearAttribute("MonKilled")
		Tools:GameData_ClearAttribute("MomsHeartKilled")
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, LevelExp.ResetData)


return LevelExp