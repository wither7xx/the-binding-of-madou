local Diacute = {}
local ModRef = tbom

local Maths = tbom.Global.Maths
local Tools = tbom.Global.Tools
local tbomCallbacks = tbom.tbomCallbacks
local modCollectibleType = tbom.modCollectibleType
local modFamiliarVariant = tbom.modFamiliarVariant
local MagicType = tbom.MagicType
local SpellType = tbom.SpellType
local SpellContent = tbom.SpellContent
local Magic = tbom.Magic
local modSoundEffect = tbom.modSoundEffect

function Diacute:PostSpellInit(spell_ID, player)
	Magic:Spell_AddAttribute(player, spell_ID, "OrbsNum", 0)
	Magic:Spell_AddAttribute(player, spell_ID, "OrbsFireDelay", 0)
end
ModRef:AddCallback(tbomCallbacks.TBOMC_POST_SPELL_INIT, Diacute.PostSpellInit, SpellType.SPELL_DIACUTE)

function Diacute:OnUse(spell_ID, rng, player, use_flag)
	local OrbsNum = (Magic:Spell_GetAttribute(player, spell_ID, "OrbsNum") or 0)
	local Reberu = (Magic:GetSpellReberu(player, spell_ID) or 0)
	if OrbsNum == 0 and Tools:CanAddWisp(player, use_flag) then
		player:AddWisp(CollectibleType.COLLECTIBLE_EVERYTHING_JAR, player.Position)			
	end
	if OrbsNum < Reberu then
		Magic:CostDefaultMadouRyoku(player, spell_ID, false)
		Magic:Spell_ModifyAttribute(player, spell_ID, "OrbsNum", 1)
		player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
		player:EvaluateItems()
		return true
	else
		return false
	end
end
ModRef:AddCallback(tbomCallbacks.TBOMC_USE_SPELL, Diacute.OnUse, SpellType.SPELL_DIACUTE)

function Diacute:PostUpdate(spell_ID, player)
	local TrinketMulti = math.max(0, math.min(2, player:GetTrinketMultiplier(TrinketType.TRINKET_FORGOTTEN_LULLABY)))
	local OrbsFireDelay_prev = (Magic:Spell_GetAttribute(player, spell_ID, "OrbsFireDelay") or 0)
	local OrbsFireDelay_new = (OrbsFireDelay_prev + 1) % (math.max(1, math.floor(player.MaxFireDelay)) * (3 - TrinketMulti))
	Magic:Spell_SetAttribute(player, spell_ID, "OrbsFireDelay", OrbsFireDelay_new)
end
ModRef:AddCallback(tbomCallbacks.TBOMC_SPELL_UPDATE, Diacute.PostUpdate, SpellType.SPELL_DIACUTE)

function Diacute:EvaluateCache(player, caflag)
	local spell_ID = SpellType.SPELL_DIACUTE
	local OrbsNum = (Magic:Spell_GetAttribute(player, spell_ID, "OrbsNum") or 0)
	if caflag == CacheFlag.CACHE_FAMILIARS then
		player:CheckFamiliar(modFamiliarVariant.LIGHT_ORB, OrbsNum, (Magic:GetSpellRNG(player, spell_ID) or RNG()), nil)
	end
end
ModRef:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Diacute.EvaluateCache)

return Diacute