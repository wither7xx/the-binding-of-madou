local LightOrb = {}
local ModRef = tbom

local Maths = tbom.Global.Maths
local Tools = tbom.Global.Tools

local tbomCallbacks = tbom.tbomCallbacks
local modFamiliarVariant = tbom.modFamiliarVariant
local MagicType = tbom.MagicType
local SpellType = tbom.SpellType
local SpellContent = tbom.SpellContent
local Magic = tbom.Magic
local Fire = tbom.Spells[SpellType.SPELL_FIRE]

function LightOrb:FamiliarUpdate(familiar)
	local player = familiar.Player
	if (familiar.OrbitLayer < 0) then
		familiar:AddToOrbit(240)
	end
    familiar.OrbitDistance = EntityFamiliar.GetOrbitDistance(1)
    familiar.OrbitSpeed = 0.06
	local parent = familiar.Parent or player
	familiar.Velocity = parent.Position + familiar:GetOrbitPosition(Vector(0, 0)) - familiar.Position

	local spell_ID = SpellType.SPELL_DIACUTE
	local OrbsFireDelay = Magic:Spell_GetAttribute(player, spell_ID, "OrbsFireDelay") or 0
	local dir = Tools:GetActualShootingDir(player)
	local fixed_dir = Tools:GetSwingShotDir(player.Velocity, dir, player.ShotSpeed)
	if dir.X ~= 0 or dir.Y ~= 0 then
		if OrbsFireDelay == 0 then
			local tear = player:FireTear(familiar.Position, fixed_dir, false, true, false, player, 0.5 * (1 + math.min(1, player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BFFS)))):ToTear()
			if player:HasTrinket(TrinketType.TRINKET_BABY_BENDER) then
				tear:AddTearFlags(TearFlags.TEAR_HOMING)
				tear.Color = Color(0.4, 0.15, 0.38, 1, 0.27843, 0, 0.4549)
			end

			if Magic:IsUsingSpell(player, SpellType.SPELL_FIRE) then
				if Fire:CanShootRedFlame(player) then
					if Maths:RandomInt(4, Magic:GetSpellRNG(player, spell_ID)) == 0 then
						local flame = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, 0, familiar.Position, fixed_dir, familiar):ToEffect()
						flame.CollisionDamage = player.Damage * 0.2
						flame:SetTimeout(60)
					end
				end
			end
		end
	end

	local SpellCD = Magic:GetSpellCD(player, spell_ID)
	local FormalCD = Magic:GetFormalCD(spell_ID)
	local MaxCD = Magic:GetMaxCD(spell_ID)
	if SpellCD ~= 0 then
		if SpellCD <= MaxCD then
			if familiar:Exists() then
				local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, familiar.Position, Vector(0, 0), nil):ToEffect()
				poof:GetSprite():Play("Poof_Small")
				poof:GetSprite().Color = Color(1, 1, 1, 1, 0.02, 0.93, 1)
			end
			familiar:Remove()
			Magic:Spell_SetAttribute(player, spell_ID, "OrbsNum", 0)
		elseif SpellCD <= MaxCD + (FormalCD - MaxCD) * 0.1 then
			local sprite = familiar:GetSprite()
			if not sprite:IsPlaying("Dying") then
				sprite:Play("Dying")
			end
			sprite:SetFrame(math.floor(SpellCD % 16))
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, LightOrb.FamiliarUpdate, modFamiliarVariant.LIGHT_ORB)

return LightOrb