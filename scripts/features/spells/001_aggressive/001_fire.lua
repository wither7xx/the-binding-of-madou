local Fire = {}
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

function Fire:CanShootSpecialTears(player)
	local spell_ID = SpellType.SPELL_FIRE
	local Reberu = Magic:GetSpellReberu(player, spell_ID)
	local TearFlagSeed = (Magic:BaseSpell_GetAttribute(player, MagicType.AGGRESSIVE, "TearFlagSeed") or 100)
	return (Reberu == 1 and TearFlagSeed < 25) 
		or (Reberu == 2 and TearFlagSeed < 50) 
		or (Reberu == 3 and TearFlagSeed < 75) 
		or Reberu >= 4
end

function Fire:CanShootRedFlame(player)
	local spell_ID = SpellType.SPELL_FIRE
	local Reberu = Magic:GetSpellReberu(player, spell_ID)
	local TearFlagSeed = (Magic:BaseSpell_GetAttribute(player, MagicType.AGGRESSIVE, "TearFlagSeed") or 100)
	return ((Reberu == 2 and TearFlagSeed < 10) 
		or (Reberu == 3 and TearFlagSeed < 16) 
		or (Reberu >= 4 and TearFlagSeed < 24))
end

function Fire:OnEnable(spell_ID, rng, player, use_flag)
	SFXManager():Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12)
	return false
end
ModRef:AddCallback(tbomCallbacks.TBOMC_ENABLE_SPELL, Fire.OnEnable, SpellType.SPELL_FIRE)

function Fire:PostTriggerEffect(spell_ID, rng, player, use_flag)
	local Reberu = Magic:GetSpellReberu(player, spell_ID)
	if Reberu >= 3 then
		for _, entity in pairs(Isaac.GetRoomEntities()) do
			if entity:IsActiveEnemy() and entity:IsVulnerableEnemy() then
				entity:AddBurn(EntityRef(player), 30 * 3, player.Damage * 0.25)
			end
		end
		SFXManager():Play(SoundEffect.SOUND_DEVILROOM_DEAL)
	end
end
ModRef:AddCallback(tbomCallbacks.TBOMC_POST_TRIGGER_ATK_EFFECT, Fire.PostTriggerEffect, SpellType.SPELL_FIRE)

function Fire:PreBurstCharge(spell_ID, reberu, rng, player)
	if reberu == 1 then
		local dir = Tools:GetCachedShootingDir(player)
		player:ShootRedCandle(dir)
	end
end
ModRef:AddCallback(tbomCallbacks.TBOMC_PRE_BURST_ATK_CHARGE, Fire.PreBurstCharge, SpellType.SPELL_FIRE)

function Fire:OnDisable(spell_ID, rng, player, use_flag)
	player:AddCacheFlags(CacheFlag.CACHE_LUCK | CacheFlag.CACHE_TEARFLAG | CacheFlag.CACHE_TEARCOLOR)
	player:EvaluateItems()
	SFXManager():Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12)
	return false
end
ModRef:AddCallback(tbomCallbacks.TBOMC_DISABLE_SPELL, Fire.OnDisable, SpellType.SPELL_FIRE)


local PostUpdate_DONE = false

function Fire:PostUpdate(spell_ID, player)
	if Magic:IsUsingSpell(player, spell_ID) then
		if player.FrameCount % (math.max(1, math.floor(player.MaxFireDelay)) * 3) == 0 then
			if not PostUpdate_DONE then
				local dir = Tools:GetActualShootingDir(player)
				local fixed_dir = Tools:GetSwingShotDir(player.Velocity, dir, player.ShotSpeed)
				if dir.X ~= 0 or dir.Y ~= 0 then
					if Fire:CanShootRedFlame(player) then
						player:ShootRedCandle(dir)
					end
				end
				PostUpdate_DONE = true
			end
		else
			PostUpdate_DONE = false
		end
		player:AddCacheFlags(CacheFlag.CACHE_LUCK | CacheFlag.CACHE_TEARFLAG | CacheFlag.CACHE_TEARCOLOR)
		player:EvaluateItems()
	end
end
ModRef:AddCallback(tbomCallbacks.TBOMC_SPELL_UPDATE, Fire.PostUpdate, SpellType.SPELL_FIRE)

function Fire:EvaluateCache(player, caflag)
	local spell_ID = SpellType.SPELL_FIRE
	local Reberu = Magic:GetSpellReberu(player, spell_ID)
	if Magic:IsUsingSpell(player, spell_ID) then
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_FIRE_MIND) then
			if Fire:CanShootSpecialTears(player) then
				if caflag == CacheFlag.CACHE_TEARFLAG then
					player.TearFlags = player.TearFlags | TearFlags.TEAR_BURN
				end
			end
			if Fire:CanShootSpecialTears(player) or (not player:HasWeaponType(WeaponType.WEAPON_TEARS)) then
				if caflag == CacheFlag.CACHE_TEARCOLOR then
					player.TearColor = Color(1, 1, 1, 1, 0.3, 0, 0)
				end
			end
		else
			if caflag == CacheFlag.CACHE_LUCK then
				player.Luck = player.Luck + 2 * Reberu
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Fire.EvaluateCache)

function Fire:OnTakeDMG(took_dmg, dmg_amount, dmg_flags, dmg_source, dmg_cd_frames)
	local player = took_dmg:ToPlayer()
	local spell_ID = SpellType.SPELL_FIRE
	local Reberu = Magic:GetSpellReberu(player, spell_ID)
	if Magic:IsUsingSpell(player, spell_ID) then
		if Reberu >= 2 then
			if dmg_flags & DamageFlag.DAMAGE_FIRE > 0 then
				return false
			end
		end
		if Reberu >= 3 then
			if dmg_flags & DamageFlag.DAMAGE_EXPLOSION > 0 then
				return false
			end
		end
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.EARLY, Fire.OnTakeDMG, EntityType.ENTITY_PLAYER)

return Fire