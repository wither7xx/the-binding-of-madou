local Thunder = {}
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

function Thunder:OnInit(spell_ID, player)
	Magic:Spell_SetAttribute(player, spell_ID, "BurstingTimeout", 0)
	Magic:Spell_SetAttribute(player, spell_ID, "ShockingTimeout", 0)
end
ModRef:AddCallback(tbomCallbacks.TBOMC_POST_SPELL_INIT, Thunder.OnInit, SpellType.SPELL_THUNDER)

function Thunder:CanShootConfusionTears(player)
	local spell_ID = SpellType.SPELL_THUNDER
	local Reberu = Magic:GetSpellReberu(player, spell_ID)
	local TearFlagSeed = (Magic:BaseSpell_GetAttribute(player, MagicType.AGGRESSIVE, "TearFlagSeed") or 100)
	return Reberu >= 3 and TearFlagSeed < 50
	--return false
end

function Thunder:CanShootFrozenTears(player)
	local spell_ID = SpellType.SPELL_THUNDER
	local Reberu = Magic:GetSpellReberu(player, spell_ID)
	local TearFlagSeed = (Magic:BaseSpell_GetAttribute(player, MagicType.AGGRESSIVE, "TearFlagSeed") or 100)
	return Reberu >= 4 and TearFlagSeed % 50 < 25
	--return false
end

function Thunder:OnEnable(spell_ID, rng, player, use_flag)
	SFXManager():Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12)
	return false
end
ModRef:AddCallback(tbomCallbacks.TBOMC_ENABLE_SPELL, Thunder.OnEnable, SpellType.SPELL_THUNDER)

function Thunder:OnDisable(spell_ID, rng, player, use_flag)
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_TEARFLAG | CacheFlag.CACHE_TEARCOLOR)
	player:EvaluateItems()
	SFXManager():Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12)
	return false
end
ModRef:AddCallback(tbomCallbacks.TBOMC_DISABLE_SPELL, Thunder.OnDisable, SpellType.SPELL_THUNDER)

function Thunder:PostUpdate(spell_ID, player)
	if Magic:IsUsingSpell(player, spell_ID) then
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_TEARFLAG | CacheFlag.CACHE_TEARCOLOR)
		player:EvaluateItems()
	end

	local BurstingTimeout = Magic:Spell_GetAttribute(player, spell_ID, "BurstingTimeout")
	local BurstingSeed = Magic:Spell_GetAttribute(player, spell_ID, "BurstingSeed") or 0
	local ShockingTimeout = Magic:Spell_GetAttribute(player, spell_ID, "ShockingTimeout")
	if BurstingTimeout then
		if BurstingTimeout > 0 then
			for _, entity in pairs(Isaac.GetRoomEntities()) do
				if BurstingSeed >= 50 then
					if entity:IsActiveEnemy() and entity:IsVulnerableEnemy() then
						--entity:TakeDamage(50, DamageFlag.DAMAGE_CLONES, EntityRef(player), 0)
						entity:TakeDamage(player.Damage * 0.85, 0, EntityRef(player), 0)
					end
				else
					if entity.Type == EntityType.ENTITY_PROJECTILE then
						entity:Die()
					end
				end
			end
			Magic:Spell_ModifyAttribute(player, spell_ID, "BurstingTimeout", -1)
		end
	end
	if ShockingTimeout and ShockingTimeout > 0 then
		if ShockingTimeout == 60 then
			Game():ShakeScreen(ShockingTimeout)
		end
		Magic:Spell_ModifyAttribute(player, spell_ID, "ShockingTimeout", -1)
	end
end
ModRef:AddCallback(tbomCallbacks.TBOMC_SPELL_UPDATE, Thunder.PostUpdate, SpellType.SPELL_THUNDER)

function Thunder:EvaluateCache(player, caflag)
	local spell_ID = SpellType.SPELL_THUNDER
	local Reberu = Magic:GetSpellReberu(player, spell_ID)
	if Magic:IsUsingSpell(player, spell_ID) then
		if Reberu >= 1 then
			if (not player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_ZERO)) then
				if caflag == CacheFlag.CACHE_TEARFLAG then
					player.TearFlags = player.TearFlags | TearFlags.TEAR_LASER
				end
			end
			if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_ZERO) or (not player:HasWeaponType(WeaponType.WEAPON_TEARS)) then
				if caflag == CacheFlag.CACHE_DAMAGE then
					player.Damage = player.Damage + 2
				end
			end
		end
		if Reberu >= 2 then
			if (not player:HasCollectible(CollectibleType.COLLECTIBLE_JACOBS_LADDER)) then
				if caflag == CacheFlag.CACHE_TEARFLAG then
					player.TearFlags = player.TearFlags | TearFlags.TEAR_JACOBS
				end
			else
				if caflag == CacheFlag.CACHE_DAMAGE then
					player.Damage = player.Damage + 2
				end
			end
		end
		if Thunder:CanShootConfusionTears(player) then
			if caflag == CacheFlag.CACHE_TEARFLAG then
				player.TearFlags = player.TearFlags | TearFlags.TEAR_CONFUSION
			end
		end
		if Thunder:CanShootConfusionTears(player) or (Reberu >= 3 and not player:HasWeaponType(WeaponType.WEAPON_TEARS)) then
			if caflag == CacheFlag.CACHE_TEARCOLOR then
				player.TearColor = Color(1, 1, 0, 1, 0.5, 0.5, 0)
			end
		end
		if Thunder:CanShootFrozenTears(player) then
			if caflag == CacheFlag.CACHE_TEARFLAG then
				player.TearFlags = player.TearFlags | TearFlags.TEAR_FREEZE
			end
		end
		if Thunder:CanShootConfusionTears(player) or (Reberu >= 4 and not player:HasWeaponType(WeaponType.WEAPON_TEARS)) then
			if caflag == CacheFlag.CACHE_TEARCOLOR then
				player.TearColor = Color(1, 1, 0, 1, 0.5, 0.5, 0.5)
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Thunder.EvaluateCache)

function Thunder:PreBurstCharge(spell_ID, reberu, rng, player)
	if reberu >= 3 then
		Magic:Spell_SetAttribute(player, spell_ID, "BurstingTimeout", 20)
		Magic:Spell_SetAttribute(player, spell_ID, "BurstingSeed", Maths:RandomInt(100, rng, true, false))
		for _, entity in pairs(Isaac.GetRoomEntities()) do
			if entity:IsActiveEnemy() and entity:IsVulnerableEnemy() then
				entity:AddFreeze(EntityRef(player), 30 * 2 + 20)
				entity:AddConfusion(EntityRef(player), 30 * 5, true)
			end
		end
		if reberu == 4 then
			local ShockingTimeout = 30 * 2 + 20
			Magic:Spell_SetAttribute(player, spell_ID, "ShockingTimeout", ShockingTimeout)
		end
		SFXManager():Play(modSoundEffect.SOUND_THUNDER_BURSTING)
	end
end
--ModRef:AddCallback(tbomCallbacks.TBOMC_PRE_BURST_ATK_CHARGE, Thunder.PreBurstCharge, SpellType.SPELL_THUNDER)

local thunder_bursting = Sprite()
thunder_bursting:Load("gfx/tbom/thunder_bursting.anm2")

function Thunder:OnRender()
	local game = Game()
	local HUD = game:GetHUD()
	--local ScreenShakeOffset = game.ScreenShakeOffset
	local NumPlayers = game:GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = game:GetPlayer(p)
		local BurstingTimeout = Magic:Spell_GetAttribute(player, SpellType.SPELL_THUNDER, "BurstingTimeout")
		if BurstingTimeout and BurstingTimeout > 0 then
			local ScreenWidth = Isaac.GetScreenWidth()
			local ScreenHeight = Isaac.GetScreenHeight()
			--print("ScreenWidth" .. ScreenWidth)
			--print("ScreenHeight" .. ScreenHeight)
			thunder_bursting:Play("Idle")
			thunder_bursting.Scale = Vector(ScreenWidth / 256, ScreenHeight / 240)
			thunder_bursting:SetFrame(20 - BurstingTimeout)
			thunder_bursting:Render(Vector(ScreenWidth * 0.5, ScreenHeight * 0.5))
			--if BurstingTimeout == 1 then
			--	HUD:SetVisible(true)
			--end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_RENDER, Thunder.OnRender)

return Thunder