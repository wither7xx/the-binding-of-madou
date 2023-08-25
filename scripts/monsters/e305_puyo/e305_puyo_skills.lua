local PuyoSkills = {}

local Common = tbom.Global.Common
local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths
local Translation = tbom.Global.Translation

local Puyo = include("scripts/monsters/e305_puyo/e305_puyo_core").__index
local PuyoSkillType = Puyo.PuyoSkillType
local PuyoFlag = Puyo.PuyoFlag

PuyoSkills[PuyoSkillType.SKILL_WINCHESTER] = function (npc)
	Puyo:ClearFlag(npc, PuyoFlag.FLAG_IMMUNE_TO_EXPLOSION)
	local sprite = npc:GetSprite()
	if sprite:IsEventTriggered("Shoot") then
		local fire_delay = 6
		local fire_times = Maths:RandomInt_Ranged(1, 6, nil, true, true)
		local shot_speed = 12
		Puyo:SetFireDelay(npc, fire_delay)
		Puyo:SetSkillTime(npc, fire_delay * fire_times)
		Puyo:SetShotSpeed(npc, shot_speed)
	end
	if Puyo:CanFireProjectile(npc) then
		Puyo:FireDefaultProjectile(npc)
	end
end

PuyoSkills[PuyoSkillType.SKILL_KNIFE] = function (npc)
	Puyo:ClearFlag(npc, PuyoFlag.FLAG_IMMUNE_TO_EXPLOSION)
	local sprite = npc:GetSprite()
	if sprite:IsEventTriggered("Shoot") then
		local fire_delay = 6
		local fire_times = Maths:RandomInt_Ranged(1, 4, nil, true, true)
		local shot_speed = 16
		Puyo:SetFireDelay(npc, fire_delay)
		Puyo:SetSkillTime(npc, fire_delay * fire_times)
		Puyo:SetShotSpeed(npc, shot_speed)
	end
	if Puyo:CanFireProjectile(npc) then
		local pos = npc.Position
		for i = 1, 2 do
			local sign = 1 - (i - 1) * 2
			local pos = npc.Position + Vector(-10 * sign, 0)
			local projectile_flags = ProjectileFlags.SHIELDED
			local tear_flags = TearFlags.TEAR_SHIELDED
			Puyo:FireDefaultProjectile(npc, nil, nil, pos, projectile_flags, nil, nil, tear_flags)
		end
	end
end

PuyoSkills[PuyoSkillType.SKILL_DARTS] = function (npc)
	Puyo:ClearFlag(npc, PuyoFlag.FLAG_IMMUNE_TO_EXPLOSION)
	local sprite = npc:GetSprite()
	if sprite:IsEventTriggered("Shoot") then
		local fire_delay = 4
		local fire_times = 2
		local shot_speed = 18
		Puyo:SetFireDelay(npc, fire_delay)
		Puyo:SetSkillTime(npc, fire_delay * fire_times)
		Puyo:SetShotSpeed(npc, shot_speed)
	end
	if Puyo:CanFireProjectile(npc) then
		Puyo:FireDefaultProjectile(npc)
	end
end

PuyoSkills[PuyoSkillType.SKILL_BOOMERANG] = function (npc)
	Puyo:ClearFlag(npc, PuyoFlag.FLAG_IMMUNE_TO_EXPLOSION)
	local sprite = npc:GetSprite()
	if sprite:IsEventTriggered("Shoot") then
		local fire_delay = 20
		local fire_times = Maths:RandomInt_Ranged(1, 2, nil, true, true)
		local shot_speed = 10
		Puyo:SetFireDelay(npc, fire_delay)
		Puyo:SetSkillTime(npc, fire_delay * fire_times)
		Puyo:SetShotSpeed(npc, shot_speed)
	end
	if Puyo:CanFireProjectile(npc) then
		local projectile_flags = ProjectileFlags.SMART | ProjectileFlags.GHOST | ProjectileFlags.SHIELDED
		local tear_flags = TearFlags.TEAR_HOMING | TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_SHIELDED
		local falling_spd = 0
		local falling_acl = -0.05
		Puyo:FireRepeatedProjectile(npc, nil, nil, 2, 60, nil, projectile_flags, falling_spd, falling_acl, tear_flags)
	end
end

PuyoSkills[PuyoSkillType.SKILL_DYNAMITE] = function (npc)
	Puyo:AddFlag(npc, PuyoFlag.FLAG_IMMUNE_TO_EXPLOSION)
	local sprite = npc:GetSprite()
	if sprite:IsEventTriggered("Shoot") then
		local fire_delay = 40
		local fire_times = 2
		local shot_speed = 18
		Puyo:SetFireDelay(npc, fire_delay)
		Puyo:SetSkillTime(npc, fire_delay * fire_times)
		Puyo:SetShotSpeed(npc, shot_speed)
	end
	if Puyo:CanFireProjectile(npc) then
		if Puyo:GetRemainingFireTimes(npc) == 2 then
			local projectile_flags = ProjectileFlags.BLUE_FIRE_SPAWN
			local tear_flags = TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP
			Puyo:FireDefaultProjectile(npc, nil, nil, nil, projectile_flags, nil, nil, tear_flags)
		else
			local shot_speed = 8
			local projectile_flags = ProjectileFlags.EXPLODE | ProjectileFlags.ACID_GREEN
			local tear_flags = TearFlags.TEAR_EXPLOSIVE
			local falling_spd = -13
			local falling_acl = 0.6
			local new_entity = Puyo:FireDefaultProjectile(npc, nil, shot_speed, nil, projectile_flags, falling_spd, falling_acl, tear_flags)
			new_entity.Color = Color(0.4, 0.97, 0.5, 1, 0, 0, 0)
		end
	end
end

PuyoSkills[PuyoSkillType.SKILL_SHOT_GUN] = function (npc)
	Puyo:ClearFlag(npc, PuyoFlag.FLAG_IMMUNE_TO_EXPLOSION)
	local sprite = npc:GetSprite()
	if sprite:IsEventTriggered("Shoot") then
		if not Puyo:HasFlag(npc, PuyoFlag.FLAG_DO_NOT_SHOOT) then
			local shot_speed = 16
			Puyo:SetShotSpeed(npc, shot_speed)
			Puyo:FireRepeatedProjectile(npc, nil, nil, 2, 30)
			Puyo:FireDefaultProjectile(npc, nil, 20)
		end
	end
end

PuyoSkills[PuyoSkillType.SKILL_DOUBLE_RIFLE] = function (npc)
	Puyo:ClearFlag(npc, PuyoFlag.FLAG_IMMUNE_TO_EXPLOSION)
	local sprite = npc:GetSprite()
	if sprite:IsEventTriggered("Shoot") then
		local fire_delay = 10
		local fire_times = Maths:RandomInt_Ranged(1, 3, nil, true, true)
		local shot_speed = 12
		Puyo:SetFireDelay(npc, fire_delay)
		Puyo:SetSkillTime(npc, fire_delay * fire_times)
		Puyo:SetShotSpeed(npc, shot_speed)
	end
	if Puyo:CanFireProjectile(npc) then
		local dir = Puyo:GetFireDir(npc)
		for i = 1, 2 do
			local sign = 1 - (i - 1) * 2
			local dir_shifted = dir:Rotated(sign * 10)
			local pos = npc.Position + Vector(-10 * sign, 0):Rotated(dir:GetAngleDegrees() - 90)
			local falling_spd = 0
			local falling_acl = -0.02
			Puyo:FireDefaultProjectile(npc, dir_shifted, nil, pos, nil, falling_spd, falling_acl)
		end
	end
end

PuyoSkills[PuyoSkillType.SKILL_DOUBLE_PISTOL] = function (npc)
	Puyo:ClearFlag(npc, PuyoFlag.FLAG_IMMUNE_TO_EXPLOSION)
	local min_dis = 300
	if Puyo:GetSkillTime(npc) <= 0 then
		local fire_delay = 10
		local fire_times = Maths:RandomInt_Ranged(3, 6, nil, true, true)
		local shot_speed = 12
		Puyo:SetFireDelay(npc, fire_delay)
		Puyo:SetSkillTime(npc, fire_delay * fire_times)
		Puyo:SetShotSpeed(npc, shot_speed)
	elseif Puyo:GetTargetDistance(npc) <= min_dis and Puyo:CanFireProjectile(npc) then
		local dir = Puyo:GetFireDir(npc)
		for i = 1, 2 do
			local sign = 1 - (i - 1) * 2
			local dir_shifted = dir:Rotated(sign * 10 * (3 - (Puyo:GetRemainingFireTimes(npc) % 3)))
			local pos = npc.Position + Vector(-10 * sign, 0):Rotated(dir:GetAngleDegrees() - 90)
			local falling_spd = 0
			local falling_acl = -0.02
			Puyo:FireDefaultProjectile(npc, dir_shifted, nil, pos, nil, falling_spd, falling_acl)
		end
	end
end

PuyoSkills[PuyoSkillType.SKILL_MACHINE_GUN] = function (npc)
	Puyo:ClearFlag(npc, PuyoFlag.FLAG_IMMUNE_TO_EXPLOSION)
	local min_dis = 300
	if Puyo:GetSkillTime(npc) <= 0 then
		local fire_delay = 10
		local fire_times = Maths:RandomInt_Ranged(4, 8, nil, true, true)
		local shot_speed = 16
		Puyo:SetFireDelay(npc, fire_delay)
		Puyo:SetSkillTime(npc, fire_delay * fire_times)
		Puyo:SetShotSpeed(npc, shot_speed)
	elseif Puyo:GetTargetDistance(npc) <= min_dis and Puyo:CanFireProjectile(npc) then
		local dir = Puyo:GetFireDir(npc)
		for i = 1, 2 do
			local sign = 1 - (i - 1) * 2
			local dir_shifted = dir:Rotated(sign * 5)
			local pos = npc.Position + Vector(-10 * sign, 0):Rotated(dir:GetAngleDegrees() - 90)
			local falling_spd = 0
			local falling_acl = -0.1
			Puyo:FireDefaultProjectile(npc, dir_shifted, nil, pos, nil, falling_spd, falling_acl)
		end
	end
end

PuyoSkills[PuyoSkillType.SKILL_RIFLE] = function (npc)
	Puyo:ClearFlag(npc, PuyoFlag.FLAG_IMMUNE_TO_EXPLOSION)
	local sprite = npc:GetSprite()
	if sprite:IsEventTriggered("Shoot") then
		if not Puyo:HasFlag(npc, PuyoFlag.FLAG_DO_NOT_SHOOT) then
			local shot_speed = 14
			Puyo:SetShotSpeed(npc, shot_speed)
			local dir = Puyo:GetFireDir(npc)
			for i = 1, 5 do
				local dir_shifted = dir + Vector(-0.577, 0) + Vector(0.577 / 2, 0) * (i - 1)
				local angle_abs = math.abs(dir:GetAngleDegrees())
				if angle_abs < 45 or angle_abs > 135 then
					dir_shifted = dir + Vector(0, -0.577) + Vector(0, 0.577 / 2) * (i - 1)
				end
				local pos = npc.Position
				local falling_spd = 0
				local falling_acl = -0.02
				Puyo:FireDefaultProjectile(npc, dir_shifted, shot_speed * dir_shifted:Length(), nil, nil, falling_spd, falling_acl)
			end
		end
	end
end

PuyoSkills[PuyoSkillType.SKILL_ALT_RIFLE] = function (npc)
	Puyo:ClearFlag(npc, PuyoFlag.FLAG_IMMUNE_TO_EXPLOSION)
	local sprite = npc:GetSprite()
	if sprite:IsEventTriggered("Shoot") then
		local fire_delay = 6
		local fire_times = 4
		local shot_speed = 10
		Puyo:SetFireDelay(npc, fire_delay)
		Puyo:SetSkillTime(npc, fire_delay * fire_times)
		Puyo:SetShotSpeed(npc, shot_speed)
	end
	if Puyo:CanFireProjectile(npc) then
		Puyo:FireDefaultProjectile(npc)
	end
end

PuyoSkills[PuyoSkillType.SKILL_ALT_BOOMERANG] = function (npc)
	Puyo:ClearFlag(npc, PuyoFlag.FLAG_IMMUNE_TO_EXPLOSION)
	local sprite = npc:GetSprite()
	if sprite:IsEventTriggered("Shoot") then
		if not Puyo:HasFlag(npc, PuyoFlag.FLAG_DO_NOT_SHOOT) then
			local shot_speed = 14
			Puyo:SetShotSpeed(npc, shot_speed)
			--local projectile_flags = ProjectileFlags.SMART | ProjectileFlags.GHOST | ProjectileFlags.SHIELDED -- | ProjectileFlags.TURN_HORIZONTAL
			local projectile_flags = ProjectileFlags.SMART | ProjectileFlags.GHOST | ProjectileFlags.SHIELDED
			local tear_flags = TearFlags.TEAR_HOMING | TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_SHIELDED
			local falling_spd = 0
			local falling_acl = -0.05
			Puyo:FireRepeatedProjectile(npc, nil, nil, 2, 60, nil, projectile_flags, falling_spd, falling_acl, tear_flags)
		end
	end
end

PuyoSkills[PuyoSkillType.SKILL_ALT_FIRE_BALL] = function (npc)
	Puyo:ClearFlag(npc, PuyoFlag.FLAG_IMMUNE_TO_EXPLOSION)
	local sprite = npc:GetSprite()
	if sprite:IsEventTriggered("Shoot") then
		if not Puyo:HasFlag(npc, PuyoFlag.FLAG_DO_NOT_SHOOT) then
			local shot_speed = 14
			Puyo:SetShotSpeed(npc, shot_speed)
			local repeat_times = 3
			if Maths:RandomInt(1, nil, true, true) == 0 then
				repeat_times = 5
			end
			Puyo:FireRepeatedProjectile(npc, nil, nil, repeat_times, 20)
		end
	end
end

PuyoSkills[PuyoSkillType.SKILL_ALT_DARTS] = function (npc)
	Puyo:ClearFlag(npc, PuyoFlag.FLAG_IMMUNE_TO_EXPLOSION)
	local sprite = npc:GetSprite()
	if sprite:IsEventTriggered("Shoot") then
		if not Puyo:HasFlag(npc, PuyoFlag.FLAG_DO_NOT_SHOOT) then
			local shot_speed = 12
			Puyo:SetShotSpeed(npc, shot_speed)
			local projectile_flags = ProjectileFlags.BURST
			local tear_flags = TearFlags.TEAR_QUADSPLIT
			local falling_acl = 0.1
			Puyo:FireDefaultProjectile(npc, nil, nil, nil, projectile_flags, nil, falling_acl, tear_flags)
		end
	end
end

PuyoSkills[PuyoSkillType.SKILL_ALT_BOMB_GUN] = function (npc)
	Puyo:AddFlag(npc, PuyoFlag.FLAG_IMMUNE_TO_EXPLOSION)
	local sprite = npc:GetSprite()
	if sprite:IsEventTriggered("Shoot") then
		if not Puyo:HasFlag(npc, PuyoFlag.FLAG_DO_NOT_SHOOT) then
			local shot_speed = 16
			Puyo:SetShotSpeed(npc, shot_speed)
			local projectile_flags = ProjectileFlags.EXPLODE | ProjectileFlags.ACID_GREEN
			local tear_flags = TearFlags.TEAR_EXPLOSIVE
			local falling_acl = 0.1
			local new_entity = Puyo:FireDefaultProjectile(npc, nil, nil, nil, projectile_flags, nil, falling_acl, tear_flags)
			new_entity.Color = Color(0.4, 0.97, 0.5, 1, 0, 0, 0)
		end
	end
end

PuyoSkills[PuyoSkillType.SKILL_ALT_MACHINE_GUN] = function (npc)
	Puyo:ClearFlag(npc, PuyoFlag.FLAG_IMMUNE_TO_EXPLOSION)
	local min_dis = 300
	if Puyo:GetSkillTime(npc) <= 0 then
		local fire_delay = 8
		local fire_times = Maths:RandomInt_Ranged(3, 8, nil, true, true)
		local shot_speed = 12
		Puyo:SetFireDelay(npc, fire_delay)
		Puyo:SetSkillTime(npc, fire_delay * fire_times)
		Puyo:SetShotSpeed(npc, shot_speed)
	elseif Puyo:GetTargetDistance(npc) <= min_dis and Puyo:CanFireProjectile(npc) then
		Puyo:FireDefaultProjectile(npc)
	end
end

return PuyoSkills