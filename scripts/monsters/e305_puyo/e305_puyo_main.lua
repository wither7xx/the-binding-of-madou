local Main = {}
local Puyo = include("scripts/monsters/e305_puyo/e305_puyo_api")
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

local PuyoSkillType = Puyo.PuyoSkillType
local PuyoFlag = Puyo.PuyoFlag 
local GelSubTypeList = Puyo.GelSubTypeList
local PuyoSkills = Puyo.PuyoSkills
local PuyoSpecific = Puyo.PuyoSpecific

function Main:OnInit(npc)
	if Puyo:IsPuyo(npc) then
		local new_effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, modEffectVariant.PUYO_FIRE_POINT, 0, npc.Position, Vector(0, 0), npc):ToEffect()
		new_effect.Parent = npc
		Puyo:SetFirePoint(npc, new_effect)
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_NPC_INIT, Main.OnInit, modEntityType.ENTITY_PUYO)

function Main:RemoveProjectile(npc)
	for i, projectile in pairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do
		if Puyo:IsSpawnedByPuyo(projectile) then
			projectile:Remove()
		end
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_NPC_UPDATE, CallbackPriority.EARLY, Main.RemoveProjectile, modEntityType.ENTITY_PUYO)

function Main:PreProjectileCollision(projectile, other, is_low)
	if Puyo:IsPuyo(other) and Puyo:IsSpawnedByFirePoint(projectile) then
		return true
	end
end
ModRef:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, Main.PreProjectileCollision)

function Main:OnUpdate(npc)
	if Puyo:IsPuyo(npc) then
		local game = Game()

		Puyo:PuyoDataInit(npc)
		Puyo:SetTarget(npc, npc:GetPlayerTarget())
		local target = Puyo:GetTarget(npc)
		if target then
			Puyo:SetFireDir(npc, (target.Position - npc.Position):Normalized())
		end

		Tools:GameData_AddAttribute("PuyoComboInCurrentRoom", 0)

		--注意：有些噗哟免疫冰冻效果。
		local puyo_variant = npc.Variant
		if PuyoSpecific[puyo_variant] ~= nil then
			PuyoSpecific[puyo_variant](npc)
		end
		if Puyo:HasFlag(npc, PuyoFlag.FLAG_IMMUNE_TO_ICE) then
			npc:ClearEntityFlags(EntityFlag.FLAG_ICE)
		end
		--if Puyo:HasFlag(npc, PuyoFlag.FLAG_CAN_STACK) then
		--	local stacking_puyo_num = Puyo:GetStackingPuyoNum(npc)
		--	for i = 2, stacking_puyo_num do
		--		
		--	end
		--end
		--注意：需要区分抗生线和回溯线。
		local level = game:GetLevel()
		local normal_skill_type = Puyo:GetSkillTypeByCurrentStage(level)
		if not Puyo:HasFlag(npc, PuyoFlag.FLAG_DO_NOT_USE_NORMAL_SKILL) then
			Puyo:SetSkillType(npc, normal_skill_type)
		end
		local skill_type = Puyo:GetSkillType(npc)
		if PuyoSkills[skill_type] ~= nil then
			PuyoSkills[skill_type](npc)
		end
		Puyo:ModifySkillTime(npc, -1)
	end
end
ModRef:AddCallback(ModCallbacks.MC_NPC_UPDATE, Main.OnUpdate, modEntityType.ENTITY_PUYO)

local function GetGrimoirePlayerNum()
	local sum = 0
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = Isaac.GetPlayer(p)
		if player:HasCollectible(modCollectibleType.COLLECTIBLE_BLUE_GRIMOIRE, true) then
			sum = sum + 1
		end
	end
	return sum
end

function Main:LinkedPuyoUpdate()
	local GrimoirePlayerNum = GetGrimoirePlayerNum()
	local NumPlayers = Game():GetNumPlayers()
	local can_play_sfx = false
	local prev_combo = Tools:GameData_GetAttribute("PuyoComboInCurrentRoom")
	if prev_combo == nil then
		Tools:GameData_SetAttribute("PuyoComboInCurrentRoom", 0)
		prev_combo = 0
	end
	local combo = prev_combo + 1
	--第一步：构造实体对象数组（注：并非NPC实体对象数组，使用前应先用Entity.ToNPC()转换）
	local PuyoArrays = {
		Green = {},
		Purple = {},
		Red = {},
		Yellow = {},
		Blue = {},
	}
	for _, puyo in pairs(Isaac.FindByType(modEntityType.ENTITY_PUYO)) do
		local variant = puyo.Variant
		if variant == PuyoVariant.PUYO_GREEN then
			table.insert(PuyoArrays.Green, puyo)
		elseif variant == PuyoVariant.PUYO_PURPLE then
			table.insert(PuyoArrays.Purple, puyo)
		elseif variant == PuyoVariant.PUYO_RED then
			table.insert(PuyoArrays.Red, puyo)
		elseif variant == PuyoVariant.PUYO_YELLOW then
			table.insert(PuyoArrays.Yellow, puyo)
		elseif variant == PuyoVariant.PUYO_BLUE then
			table.insert(PuyoArrays.Blue, puyo)
		end
	end
	--第二步：遍历各个数组，构造相容类
	for id, array in pairs(PuyoArrays) do
		if #(array) >= 4 then
			local LinkedPuyoHeap = {}
			for i = 2, #array do
				for j = 1, (i - 1) do
					if Puyo:IsLinked(array[i], array[j]) then
						if #LinkedPuyoHeap == 0 then
							table.insert(LinkedPuyoHeap, {[1] = i, [2] = j,})
						else
							for k = 1, #LinkedPuyoHeap do
								local is_new_pair = true
								if Common:IsInTable(i, LinkedPuyoHeap[k]) then
									is_new_pair = false
									if not Common:IsInTable(j, LinkedPuyoHeap[k]) then
										table.insert(LinkedPuyoHeap[k], j)
									end
								elseif Common:IsInTable(j, LinkedPuyoHeap[k]) then
									is_new_pair = false
									table.insert(LinkedPuyoHeap[k], i)
								end
								if is_new_pair then
									table.insert(LinkedPuyoHeap, {[1] = i, [2] = j,})
								end
							end
						end
					end
				end
			end
			--第三步：对符合要求的相容类内部元素触发“消除”函数
			for k = 1, #LinkedPuyoHeap do
				--local should_owanimo = false
				--local puyo_sum = 0
				--for m, n in ipairs(LinkedPuyoHeap[k]) do
				--	local npc = (array[n]):ToNPC()
				--	if npc and npc:Exists() then
				--		puyo_sum = puyo_sum + Puyo:GetStackingPuyoNum(npc)
				--		if puyo_sum >= 4 then
				--			should_owanimo = true
				--			break
				--		end
				--	end
				--end
				--if should_owanimo then
				if #(LinkedPuyoHeap[k]) >= 4 then
					can_play_sfx = true
					for m, n in ipairs(LinkedPuyoHeap[k]) do
						--Puyo:owanimo(array[n])
						--array[n]:Remove()
						local npc = (array[n]):ToNPC()
						if npc and npc:Exists() then
							Puyo:Owanimo(npc)
							if m <= GrimoirePlayerNum and (not Puyo:HasFlag(npc, PuyoFlag.FLAG_DO_NOT_GRANT_MANA)) then
								Isaac.Spawn(EntityType.ENTITY_PICKUP, modPickupVariant.PICKUP_MANA, 0, npc.Position, Vector(0, 0), npc)
							end
						end
						if m == 1 then
							for p = 0, NumPlayers - 1 do
								local player = Isaac.GetPlayer(p)
								if LevelExp:IsRPGCharacter(player) and (not Puyo:HasFlag(npc, PuyoFlag.FLAG_DO_NOT_GRANT_EXP)) then
									LevelExp:SpawnExp(player, npc.Position, 3 + (prev_combo + 1) * 2)
								end
							end
							if k == 1 then
								local lang = Translation:FixLanguage()
								local text_list = {
									["zh"] = "连消！",
									["en"] = "-chain!",
								}
								local text = tostring(combo) .. (text_list[lang] or text_list["en"])
								Translation:RenderFloatingText(text, npc.Position)
							end
						end
					end
				end
			end
		end
	end
	if can_play_sfx then
		Tools:GameData_ModifyAttribute("PuyoComboInCurrentRoom", 1)
		SFXManager():Play(Puyo:GetSFXByCurrentCombo(combo))
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_UPDATE, Main.LinkedPuyoUpdate)

function Main:PostEntityKill(entity)
	if Puyo:IsPuyo(entity) then
		local gel_subtype = GelSubTypeList[entity.Variant]
		if gel_subtype and (not Puyo:HasFlag(entity, PuyoFlag.FLAG_DO_NOT_GRANT_GEL)) and (not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, modPickupVariant.PICKUP_GEL, gel_subtype, entity.Position, Vector(0, 0), entity)
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, Main.PostEntityKill, modEntityType.ENTITY_PUYO)

function Main:PostNewRoom()
	Tools:GameData_SetAttribute("PuyoComboInCurrentRoom", 0)
	local game = Game()
	local room = game:GetRoom()
	local level = game:GetLevel()
	if Puyo:CanSpawnPuyo(room, level) and (not game:IsGreedMode()) then
		Puyo:SpawnRandomPuyo(room, level)
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Main.PostNewRoom)

function Main:PostNewLevel()
	Tools:GameData_SetAttribute("PuyoComboInCurrentRoom", 0)
end
ModRef:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Main.PostNewLevel)

function Main:PostNewGreedModeWave(current_wave)
	local game = Game()
	if game:IsGreedMode() then
		local room = game:GetRoom()
		local level = game:GetLevel()
		local puyo_chance = Puyo:GetPuyoChance()
		if current_wave < game:GetGreedBossWaveNum() and Tools:RoomCanTriggerEvent(nil, puyo_chance) then
			Puyo:SpawnRandomPuyo(room, level)
		end
	end
end
ModRef:AddCallback(tbomCallbacks.TBOMC_POST_NEW_GREED_MODE_WAVE, Main.PostNewGreedModeWave)

function Main:PuyoTakeDMG(took_dmg, dmg_amount, dmg_flags, dmg_source, dmg_cd_frames)
	local npc = took_dmg:ToNPC()
	if Puyo:IsPuyo(npc) and Puyo:HasFlag(npc, PuyoFlag.FLAG_IMMUNE_TO_EXPLOSION) then
		if dmg_flags & DamageFlag.DAMAGE_EXPLOSION > 0 then
			return false
		end
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.EARLY, Main.PuyoTakeDMG, modEntityType.ENTITY_PUYO)

--[[
function Puyo:OnRender(npc, offset)
	local font = tbom.Fonts[Options.Language] or tbom.Fonts["en"]
	local texts = {
		[1] = "State: ".. tostring(npc.State),
		[2] = "FireDir: (" .. Maths:Fix_Round(Puyo:GetFireDir(npc).X, 2) .. ", " .. Maths:Fix_Round(Puyo:GetFireDir(npc).Y, 2) .. ")" ,
		[3] = "FireDelay: " .. Puyo:GetFireDelay(npc),
		[4] = "SkillTime: ".. Puyo:GetSkillTime(npc),
		[5] = "ShotSpeed: " .. Puyo:GetShotSpeed(npc),
	}
	local pos = Isaac.WorldToScreen(npc.Position)
	for i=1, #texts do
		font:DrawStringUTF8(texts[i], pos.X - 200, pos.Y - 5 * #texts + i * 15, KColor(1,1,1,0.8), 400, true)
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, Puyo.OnRender, modEntityType.ENTITY_PUYO)
]]

function Main:Effect_OnUpdate(effect)
	local data = Tools:GetEffectData(effect)
	if data.PuyoOwanimoData then
		local puyo_variant = data.PuyoOwanimoData.Variant
		local puyo_flag = data.PuyoOwanimoData.Flag
		local effect_sprite = effect:GetSprite()
		if effect_sprite:IsEventTriggered("Burst") then

			local gel_subtype = GelSubTypeList[puyo_variant]
			if gel_subtype and not (puyo_flag & PuyoFlag.FLAG_DO_NOT_GRANT_GEL > 0) then
				Isaac.Spawn(EntityType.ENTITY_PICKUP, modPickupVariant.PICKUP_GEL, gel_subtype, effect.Position, Vector(0, 0), effect)
			end

			for i = 1, 8 do
				local dis = Vector(5, 0):Rotated(22.5)
				local gibs = Isaac.Spawn(EntityType.ENTITY_EFFECT, modEffectVariant.PUYO_GIBS, 0, effect.Position, dis:Rotated(45 * i), effect):ToEffect()
				local GibsAnimNameList = {
					[PuyoVariant.PUYO_GREEN] = "Green",
					[PuyoVariant.PUYO_PURPLE] = "Purple",
					[PuyoVariant.PUYO_RED] = "Red",
					[PuyoVariant.PUYO_YELLOW] = "Yellow",
					[PuyoVariant.PUYO_BLUE] = "Blue",
				}
				local gibs_anim_name = GibsAnimNameList[puyo_variant]
				if gibs_anim_name then
					gibs:GetSprite():Play(gibs_anim_name)
				end
			end

			SFXManager():Play(modSoundEffect.SOUND_PUYO_BURST)
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Main.Effect_OnUpdate, modEffectVariant.BLANK_ANIM)

function Main:PostProjectileUpdate(projectile)
	if Puyo:IsSpawnedByFirePoint(projectile) then
		if projectile:HasProjectileFlags(ProjectileFlags.SHIELDED) then
			local sprite = projectile:GetSprite()
			sprite:Load("gfx/tbom/projectile_shielded_tear.anm2", true)
			sprite:Play("RegularTear6", true)
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, Main.PostProjectileUpdate)

function Main:PostTearUpdate(tear)
	if Puyo:IsSpawnedByFirePoint(tear) then
		if tear:HasTearFlags(TearFlags.TEAR_SHIELDED) then
			local sprite = tear:GetSprite()
			sprite:Load("gfx/tbom/projectile_shielded_tear.anm2", true)
			sprite:Play("RegularTear6", true)
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, Main.PostTearUpdate)

return Main