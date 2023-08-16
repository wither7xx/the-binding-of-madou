local IceStorm = {}
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
local Aggressive = tbom.BaseSpell[MagicType.AGGRESSIVE]

function IceStorm:CanShootSlowTears(player)
	local spell_ID = SpellType.SPELL_ICE_STORM
	local Reberu = Magic:GetSpellReberu(player, spell_ID)
	local TearFlagSeed = (Magic:BaseSpell_GetAttribute(player, MagicType.AGGRESSIVE, "TearFlagSeed") or 100)
	return (Reberu == 1 and TearFlagSeed < 25) 
		or (Reberu == 2 and TearFlagSeed < 50) 
		or (Reberu == 3 and TearFlagSeed < 75) 
		or Reberu >= 4
end

function IceStorm:CanShootIceTears(player)
	local spell_ID = SpellType.SPELL_ICE_STORM
	local Reberu = Magic:GetSpellReberu(player, spell_ID)
	local TearFlagSeed = (Magic:BaseSpell_GetAttribute(player, MagicType.AGGRESSIVE, "TearFlagSeed") or 100)
	return (Reberu == 2 and TearFlagSeed < 24) 
		or (Reberu == 3 and TearFlagSeed < 50) 
		or Reberu >= 4
end

function IceStorm:OnEnable(spell_ID, rng, player, use_flag)
	SFXManager():Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12)
	return false
end
ModRef:AddCallback(tbomCallbacks.TBOMC_ENABLE_SPELL, IceStorm.OnEnable, SpellType.SPELL_ICE_STORM)

function IceStorm:PostTriggerEffect(spell_ID, rng, player, use_flag)
	local Reberu = Magic:GetSpellReberu(player, spell_ID)
	if Reberu >= 3 then
		for _,entity in pairs(Isaac.GetRoomEntities()) do
			if entity:IsActiveEnemy() and entity:IsVulnerableEnemy() then
				entity:AddFreeze(EntityRef(player), 30 * 3)
			end
		end
		SFXManager():Play(SoundEffect.SOUND_DEVILROOM_DEAL)
	end
end
ModRef:AddCallback(tbomCallbacks.TBOMC_POST_TRIGGER_ATK_EFFECT, IceStorm.PostTriggerEffect, SpellType.SPELL_ICE_STORM)

function IceStorm:OnDisable(spell_ID, rng, player, use_flag)
	player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_TEARFLAG | CacheFlag.CACHE_TEARCOLOR)
	player:EvaluateItems()
	SFXManager():Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12)
	return false
end
ModRef:AddCallback(tbomCallbacks.TBOMC_DISABLE_SPELL, IceStorm.OnDisable, SpellType.SPELL_ICE_STORM)

function IceStorm:PostUpdate(spell_ID, player)
	if Magic:IsUsingSpell(player, spell_ID) then
		player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_TEARFLAG | CacheFlag.CACHE_TEARCOLOR)
		player:EvaluateItems()
	end
end
ModRef:AddCallback(tbomCallbacks.TBOMC_SPELL_UPDATE, IceStorm.PostUpdate, SpellType.SPELL_ICE_STORM)

function IceStorm:EvaluateCache(player, caflag)
	local spell_ID = SpellType.SPELL_ICE_STORM
	local Reberu = Magic:GetSpellReberu(player, spell_ID)
	if Magic:IsUsingSpell(player, spell_ID) then
		if IceStorm:CanShootSlowTears(player) then
			if caflag == CacheFlag.CACHE_TEARFLAG then
				player.TearFlags = player.TearFlags | TearFlags.TEAR_SLOW
			end
		end
		if IceStorm:CanShootSlowTears(player) or (not player:HasWeaponType(WeaponType.WEAPON_TEARS)) then
			if caflag == CacheFlag.CACHE_TEARCOLOR then
				player.TearColor = Color(0.518, 0.671, 0.976, 1, 0.14, 0.16, 0.18)
			end
		end
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_URANUS) then
			if IceStorm:CanShootIceTears(player) then
				if caflag == CacheFlag.CACHE_TEARFLAG then
					player.TearFlags = player.TearFlags | TearFlags.TEAR_ICE
				end
			end
			if IceStorm:CanShootIceTears(player) or (Reberu >= 2 and not player:HasWeaponType(WeaponType.WEAPON_TEARS)) then
				if caflag == CacheFlag.CACHE_TEARCOLOR then
					player.TearColor = Color(0.518, 0.671, 0.976, 1, 0.35, 0.4, 0.45)
				end
			end
		else
			if caflag == CacheFlag.CACHE_FIREDELAY then
				player.MaxFireDelay = (30 / (30 / (player.MaxFireDelay + 1) + 1 * (Reberu - 1)) - 1)
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, IceStorm.EvaluateCache)

return IceStorm