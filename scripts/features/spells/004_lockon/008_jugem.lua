local Jugem = {}
local ModRef = tbom

local Maths = tbom.Global.Maths
local Tools = tbom.Global.Tools

local tbomCallbacks = tbom.tbomCallbacks
local modCollectibleType = tbom.modCollectibleType
local MagicType = tbom.MagicType
local SpellType = tbom.SpellType
local SpellContent = tbom.SpellContent
local Magic = tbom.Magic
local modSoundEffect = tbom.modSoundEffect

function Jugem:OnEnable(spell_ID, rng, player, use_flag)
	return true
end
ModRef:AddCallback(tbomCallbacks.TBOMC_ENABLE_SPELL, Jugem.OnEnable, SpellType.SPELL_JUGEM)

function Jugem:OnFire(spell_ID, player, target)
	local rocket = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCKET, 0, target.Position, Vector(0, 0), player):ToEffect()
	rocket.LifeSpan = 2
	rocket.Timeout = 2
end
ModRef:AddCallback(tbomCallbacks.TBOMC_POST_FIRE_LOCKON_WEAPON, Jugem.OnFire, SpellType.SPELL_JUGEM)

function Jugem:OnDisable(spell_ID, rng, player, use_flag)
	return true
end
ModRef:AddCallback(tbomCallbacks.TBOMC_DISABLE_SPELL, Jugem.OnDisable, SpellType.SPELL_JUGEM)

function Jugem:OnTakeDMG(took_dmg, dmg_amount, dmg_flags, dmg_source, dmg_cd_frames)
	local player = took_dmg:ToPlayer()
	local spell_ID = SpellType.SPELL_JUGEM
	local Diacute_OrbsNum = (Magic:Spell_GetAttribute(player, SpellType.SPELL_DIACUTE, "OrbsNum") or 0)
	if Magic:IsSpellUnlocked(player, spell_ID) then
		if Diacute_OrbsNum > 0 or player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) then
			if dmg_flags & DamageFlag.DAMAGE_EXPLOSION > 0 then
				return false
			end
		end
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.EARLY, Jugem.OnTakeDMG, EntityType.ENTITY_PLAYER)

return Jugem
