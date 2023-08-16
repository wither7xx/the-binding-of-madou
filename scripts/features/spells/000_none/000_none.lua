local None = {}
local ModRef = tbom

local Common = tbom.Global.Common
local Maths = tbom.Global.Maths
local Tools = tbom.Global.Tools
local Translation = tbom.Global.Translation

local tbomCallbacks = tbom.tbomCallbacks
local modCollectibleType = tbom.modCollectibleType
local MagicType = tbom.MagicType
local SpellType = tbom.SpellType
local SpellContent = tbom.SpellContent
local Magic = tbom.Magic
local modSoundEffect = tbom.modSoundEffect

local DefaultSpellAttribute = {
	[1] = "FireCount",
	[2] = "IceCount", 
	[3] = "ThunderCount",
}

function None:IsSimulatingDefaultSpells(sim_spell_ID)
	return sim_spell_ID <= 3
end

function None:PostSpellInit(spell_ID, player)
	for i, attribute in pairs(DefaultSpellAttribute) do
		Magic:Spell_AddAttribute(player, spell_ID, attribute, 0)
	end
	Magic:Spell_AddAttribute(player, spell_ID, "SimulatableSpells", {[1] = 1, [2] = 2, [3] = 3,})
	Magic:Spell_AddAttribute(player, spell_ID, "UseLightSpellName", false)
	Magic:Spell_AddAttribute(player, spell_ID, "UseDarkSpellName", false)
	Magic:Spell_AddAttribute(player, spell_ID, "UseShadowSpellName", false)
	Magic:Spell_AddAttribute(player, spell_ID, "ResetInNewRoom", true)
	Magic:Spell_AddAttribute(player, spell_ID, "ResetInNewLevel", true)
end
ModRef:AddCallback(tbomCallbacks.TBOMC_POST_SPELL_INIT, None.PostSpellInit, SpellType.SPELL_NONE)

function None:TryAddSimulatedSpell(player, sim_spell_ID)
	local SimulatableSpells = Magic:Spell_GetAttribute(player, SpellType.SPELL_NONE, "SimulatableSpells")
	if SimulatableSpells and (not Common:IsInTable(sim_spell_ID, SimulatableSpells)) then
		table.insert(SimulatableSpells, sim_spell_ID)
	end
end

function None:TryRemoveSimulatedSpell(player, sim_spell_ID)
	local SimulatableSpells = Magic:Spell_GetAttribute(player, SpellType.SPELL_NONE, "SimulatableSpells")
	if SimulatableSpells then
		for i, ID in pairs(SimulatableSpells) do
			if ID == sim_spell_ID then
				table.remove(SimulatableSpells, i)
			end
		end
	end
end

function None:GetSimulatedSpellName(player, sim_spell_ID, lang)
	local spell_ID = SpellType.SPELL_NONE
	local lang_fixed = Translation:FixLanguage(lang)
	local texts = {
		[1] = {["en"] = "Fire", ["zh"] = "火炎术"},
		[2] = {["en"] = "Ice", ["zh"] = "冰冻术"},
		[3] = {["en"] = "Thunder", ["zh"] = "闪电术"},
	}
	if Magic:Spell_GetAttribute(player, spell_ID, "UseLightSpellName") then
		texts[2] = {["en"] = "Ice Storm", ["zh"] = "冰霜风暴"}
	elseif Magic:Spell_GetAttribute(player, spell_ID, "UseDarkSpellName") then
		texts[1] = {["en"] = "Abyss", ["zh"] = "狱炎术"}
		texts[2] = {["en"] = "Chaos", ["zh"] = "混沌冰暴"}
	elseif Magic:Spell_GetAttribute(player, spell_ID, "UseShadowSpellName") then
		texts[1] = {["en"] = "Flame Tornado", ["zh"] = "卷炎术"}
		texts[2] = {["en"] = "Dark Blizzard", ["zh"] = "暗夜霜暴"}
		texts[3] = {["en"] = "Heavenly Thunder", ["zh"] = "裂天震电"}
	end
	return texts[sim_spell_ID][lang_fixed] or ""
end

function None:OnUse(spell_ID, rng, player, use_flag)
	local SimulatableSpells = Magic:Spell_GetAttribute(player, spell_ID, "SimulatableSpells") or {[1] = 1, [2] = 2, [3] = 3,}
	local sim_spell_key = Maths:RandomInt(#SimulatableSpells, rng, false, true)
	local sim_spell_ID = SimulatableSpells[sim_spell_key]
	if None:IsSimulatingDefaultSpells(sim_spell_ID) then
		Magic:Spell_ModifyAttribute(player, spell_ID, DefaultSpellAttribute[sim_spell_ID], 1)
		player:AddCacheFlags(CacheFlag.CACHE_LUCK | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_TEARFLAG | CacheFlag.CACHE_TEARCOLOR)
		player:EvaluateItems()

		local SimulatedSpellName = None:GetSimulatedSpellName(player, sim_spell_ID, Options.Language)
		local HUD = Game():GetHUD()
		HUD:ShowItemText(SimulatedSpellName, "")

		local wisp_ID = {
			[1] = CollectibleType.COLLECTIBLE_KAMIKAZE,		--神风魂火
			[2] = CollectibleType.COLLECTIBLE_SPIDER_BUTT,	--蜘蛛魂火
			[3] = 65536 + 4,								--红石魂火
		}
		if Tools:CanAddWisp(player, use_flag) then
			player:AddWisp(wisp_ID[sim_spell_ID], player.Position)			
		end
	end
	Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_POST_USE_SIM_SPELL, sim_spell_ID, sim_spell_ID, rng, player, use_flag)
	return true
end
ModRef:AddCallback(tbomCallbacks.TBOMC_USE_SPELL, None.OnUse, SpellType.SPELL_NONE)

function None:EvaluateCache(player, caflag)
	local spell_ID = SpellType.SPELL_NONE
	if Magic:HasSpell(player, spell_ID) then
		local attribute_count = {[1] = 0, [2] = 0, [3] = 0,}
		local attribute_sum = 0
		for i, attribute in pairs(DefaultSpellAttribute) do
			attribute_count[i] = (Magic:Spell_GetAttribute(player, spell_ID, attribute) or 0)
			attribute_sum = attribute_sum + (Magic:Spell_GetAttribute(player, spell_ID, attribute) or 0)
		end
		if attribute_sum > 0 then
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE) then
				if caflag == CacheFlag.CACHE_DAMAGE then
					player.Damage = player.Damage * 1.3
				end
			end
			if attribute_count[1] > 0 then
				if player:HasCollectible(CollectibleType.COLLECTIBLE_FIRE_MIND) or attribute_count[1] > 1 then
					if caflag == CacheFlag.CACHE_LUCK then
						if player:HasCollectible(CollectibleType.COLLECTIBLE_FIRE_MIND) then
							player.Luck = player.Luck + 2 * attribute_count[1]
						else
							player.Luck = player.Luck + 2 * (attribute_count[1] - 1)
						end
					end
				end
				if not player:HasCollectible(CollectibleType.COLLECTIBLE_FIRE_MIND) then
					if caflag == CacheFlag.CACHE_TEARFLAG then
						player.TearFlags = player.TearFlags | TearFlags.TEAR_BURN
					end
					if caflag == CacheFlag.CACHE_TEARCOLOR then
						player.TearColor = Color(1, 1, 1, 1, 0.3, 0, 0)
					end
				end
			end
			if attribute_count[2] > 0 then
				if caflag == CacheFlag.CACHE_TEARFLAG then
					player.TearFlags = player.TearFlags | TearFlags.TEAR_SLOW
				end
				if player:HasCollectible(CollectibleType.COLLECTIBLE_URANUS) or attribute_count[2] > 1 then
					if caflag == CacheFlag.CACHE_FIREDELAY then
						if player:HasCollectible(CollectibleType.COLLECTIBLE_URANUS) then
							player.MaxFireDelay = (30 / (30 / (player.MaxFireDelay + 1) + 1 * attribute_count[2]) - 1)
						else
							player.MaxFireDelay = (30 / (30 / (player.MaxFireDelay + 1) + 1 * (attribute_count[2] - 1)) - 1)
						end
					end
				end
				if not player:HasCollectible(CollectibleType.COLLECTIBLE_URANUS) then
					if caflag == CacheFlag.CACHE_TEARFLAG then
						player.TearFlags = player.TearFlags | TearFlags.TEAR_ICE
					end
				end
				if caflag == CacheFlag.CACHE_TEARCOLOR then
					player.TearColor = Color(0.518, 0.671, 0.976, 1, 0.35, 0.4, 0.45)
				end
			end
			if attribute_count[3] > 0 then
				if (player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_ZERO) and player:HasCollectible(CollectibleType.COLLECTIBLE_JACOBS_LADDER)) or attribute_count[3] > 1 then
					if caflag == CacheFlag.CACHE_DAMAGE then
						if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_ZERO) and player:HasCollectible(CollectibleType.COLLECTIBLE_JACOBS_LADDER) then
							player.Damage = player.Damage + 2 * attribute_count[3]
						else
							player.Damage = player.Damage + 2 * (attribute_count[3] - 1)
						end
					end
				end
				if not (player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_ZERO) and player:HasCollectible(CollectibleType.COLLECTIBLE_JACOBS_LADDER)) then
					if caflag == CacheFlag.CACHE_TEARFLAG then
						player.TearFlags = player.TearFlags | TearFlags.TEAR_LASER | TearFlags.TEAR_JACOBS
					end
				end
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, None.EvaluateCache)

function None:ResetAttribute(player)
	local spell_ID = SpellType.SPELL_NONE
	local attribute_sum = 0
	for i, attribute in pairs(DefaultSpellAttribute) do
		attribute_sum = attribute_sum + (Magic:Spell_GetAttribute(player, spell_ID, attribute) or 0)
	end

	if attribute_sum > 0 then
		for i, attribute in pairs(DefaultSpellAttribute) do
			Magic:Spell_SetAttribute(player, spell_ID, attribute, 0)
		end
		player:AddCacheFlags(CacheFlag.CACHE_LUCK | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_TEARFLAG | CacheFlag.CACHE_TEARCOLOR)
		player:EvaluateItems()
	end
end

function None:PostNewRoom()
	local spell_ID = SpellType.SPELL_NONE
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = Game():GetPlayer(p)
		if Magic:HasSpell(player, spell_ID) then
			local ResetInNewRoom = Magic:Spell_GetAttribute(player, spell_ID, "ResetInNewRoom")
			if ResetInNewRoom == nil then
				ResetInNewRoom = true
			end
			if ResetInNewRoom then
				None:ResetAttribute(player)
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, None.PostNewRoom)

function None:PostNewLevel()
	local spell_ID = SpellType.SPELL_NONE
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = Game():GetPlayer(p)
		if Magic:HasSpell(player, spell_ID) then
			local ResetInNewLevel = Magic:Spell_GetAttribute(player, spell_ID, "ResetInNewLevel")
			if ResetInNewLevel == nil then
				ResetInNewLevel = true
			end
			if ResetInNewLevel then
				None:ResetAttribute(player)
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, None.PostNewLevel)

return None