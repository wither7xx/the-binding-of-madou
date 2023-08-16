local Puyo = {}
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

local PuyoSkillType = {
	SKILL_NONE = 0,
	SKILL_WINCHESTER = 1,
	SKILL_KNIFE = 2,
	SKILL_DARTS = 3,
	SKILL_BOOMERANG = 4,
	SKILL_DYNAMITE = 5,
	SKILL_SHOT_GUN = 6,
	SKILL_DOUBLE_RIFLE = 7,
	SKILL_DOUBLE_PISTOL = 8,
	SKILL_MACHINE_GUN = 9,
	SKILL_RIFLE = 10,
	SKILL_ALT_RIFLE = 11,
	SKILL_ALT_BOOMERANG = 12,
	SKILL_ALT_FIRE_BALL = 13,
	SKILL_ALT_DARTS = 14,
	SKILL_ALT_BOMB_GUN = 15,
	SKILL_ALT_MACHINE_GUN = 16,
	NUM_ARC_VERSION_SKILLS = 10,
	NUM_NES_VERSION_SKILLS = 6,
}
Puyo.PuyoSkillType = PuyoSkillType

local PuyoFlag = {
	FLAG_DO_NOT_SHOOT = (1 << 0),				--不发射弹幕
	FLAG_DO_NOT_USE_NORMAL_SKILL = (1 << 1),	--不根据楼层决定技能
	FLAG_DO_NOT_GRANT_MANA = (1 << 2),			--死亡后不掉落魔导力拾取物
	FLAG_DO_NOT_GRANT_EXP = (1 << 3),			--死亡后不奖励经验值
	FLAG_DO_NOT_GRANT_GEL = (1 << 4),			--死亡后不掉落凝胶拾取物
	FLAG_IMMUNE_TO_BURN = (1 << 5),				--免疫燃烧debuff
	FLAG_IMMUNE_TO_SLOW = (1 << 6),				--免疫减速debuff
}
Puyo.PuyoFlag = PuyoFlag

local GelSubTypeList = {
	[PuyoVariant.PUYO_GREEN] = GelSubType.GEL_GREEN,
	[PuyoVariant.PUYO_PURPLE] = GelSubType.GEL_PURPLE,
	[PuyoVariant.PUYO_RED] = GelSubType.GEL_RED,
	[PuyoVariant.PUYO_YELLOW] = GelSubType.GEL_YELLOW,
	[PuyoVariant.PUYO_BLUE] = GelSubType.GEL_BLUE,
}

local function GetPuyoData(npc)
	local data = Tools:GetNPCData(npc)
	data.PuyoData = data.PuyoData or {}
	return data.PuyoData
end

local function PuyoDataInit(npc)
	local data = GetPuyoData(npc)
	if data.SkillType == nil then
		data.SkillType = PuyoSkillType.SKILL_NONE
	end
	if data.Flag == nil then
		data.Flag = 0
	end
	if data.SkillTime == nil then
		data.SkillTime = 0
	end
	if data.ShotSpeed == nil then
		data.ShotSpeed = 10
	end
	if data.FireDelay == nil then
		data.FireDelay = 6
	end
	if data.FireDir == nil then
		data.FireDir = Vector(0, 0)
	end
end

function Puyo:IsPuyo(entity)
	return entity and entity.Type == modEntityType.ENTITY_PUYO and Common:IsInTable(entity.Variant, PuyoVariant)
end

function Puyo:IsSpawnedByPuyo(entity)
	return entity.SpawnerType and entity.SpawnerType == modEntityType.ENTITY_PUYO and Common:IsInTable(entity.SpawnerVariant, PuyoVariant)
end

function Puyo:GetFlag(npc)
	local data = GetPuyoData(npc)
	return data.Flag
end

function Puyo:HasFlag(npc, flag)
	local data = GetPuyoData(npc)
	return data.Flag and (data.Flag & flag > 0)
end

function Puyo:AddFlag(npc, flag)
	local data = GetPuyoData(npc)
	if data.Flag then
		data.Flag = data.Flag | flag
	end
end

function Puyo:ClearFlag(npc, flag)
	local data = GetPuyoData(npc)
	if data.Flag then
		data.Flag = data.Flag & (~flag)
	end
end

function Puyo:GetSkillType(npc)
	local data = GetPuyoData(npc)
	return data.SkillType or BossSkillType.NONE
end

function Puyo:IsUsingSkill(npc, skill_type)
	if skill_type == BossSkillType.NONE then
		return false
	end
	return Puyo:GetSkillType(npc) == skill_type
end

function Puyo:SetSkillType(npc, value)
	local data = GetPuyoData(npc)
	data.SkillType = value
end

function Puyo:GetFireDelay(npc)
	local data = GetPuyoData(npc)
	return data.FireDelay or 0
end

function Puyo:SetFireDelay(npc, value)
	local data = GetPuyoData(npc)
	data.FireDelay = math.max(0, value)
end

function Puyo:ModifyFireDelay(npc, amount)
	local data = GetPuyoData(npc)
	if data.FireDelay then
		data.FireDelay = math.max(0, data.FireDelay + amount)
	end
end

function Puyo:GetFireDir(npc)
	local data = GetPuyoData(npc)
	return data.FireDir or Vector(0, 0)
end

function Puyo:SetFireDir(npc, value)
	local data = GetPuyoData(npc)
	data.FireDir = value
end

function Puyo:ModifyFireDir(npc, amount)
	local data = GetPuyoData(npc)
	if data.FireDir then
		data.FireDir = (data.FireDir):Rotated(amount)
	end
end

function Puyo:GetShotSpeed(npc)
	local data = GetPuyoData(npc)
	return data.ShotSpeed or 10
end

function Puyo:SetShotSpeed(npc, value)
	local data = GetPuyoData(npc)
	data.ShotSpeed = math.max(0, value)
end

function Puyo:ModifyShotSpeed(npc, amount)
	local data = GetPuyoData(npc)
	if data.ShotSpeed then
		data.ShotSpeed = math.max(0, data.ShotSpeed + amount)
	end
end

function Puyo:GetSkillTime(npc)
	local data = GetPuyoData(npc)
	return data.SkillTime or 0
end

function Puyo:SetSkillTime(npc, value)
	local data = GetPuyoData(npc)
	data.SkillTime = math.max(0, value)
end

function Puyo:ModifySkillTime(npc, amount)
	local data = GetPuyoData(npc)
	if data.SkillTime then
		data.SkillTime = math.max(0, data.SkillTime + amount)
	end
end

function Puyo:GetTarget(npc)
	local data = GetPuyoData(npc)
	return data.Target or npc:GetPlayerTarget()
end

function Puyo:SetTarget(npc, value)
	local data = GetPuyoData(npc)
	data.Target = value
end

function Puyo:GetFirePoint(npc)
	local data = GetPuyoData(npc)
	return data.FirePoint
end

function Puyo:SetFirePoint(npc, value)
	local data = GetPuyoData(npc)
	data.FirePoint = value
end

function Puyo:CanFireProjectile(npc, fire_delay_multi)
	local fire_delay = math.floor(Puyo:GetFireDelay(npc))
	local skill_time = math.floor(Puyo:GetSkillTime(npc))
	if fire_delay_multi == nil or fire_delay_multi == 0 then
		fire_delay_multi = 1
	end
	if fire_delay and skill_time then
		if fire_delay ~= 0 and skill_time ~= 0 and (not Puyo:HasFlag(npc, PuyoFlag.FLAG_DO_NOT_SHOOT)) then
			return skill_time % (fire_delay * fire_delay_multi) == 0
		end
	end
	return false
end

function Puyo:GetRemainingFireTimes(npc, fire_delay_multi)
	if fire_delay_multi == nil or fire_delay_multi == 0 then
		fire_delay_multi = 1
	end
	local fire_delay = math.floor(Puyo:GetFireDelay(npc))
	local skill_time = math.floor(Puyo:GetSkillTime(npc))
	if fire_delay and skill_time then
		if fire_delay ~= 0 and (not Puyo:HasFlag(npc, PuyoFlag.FLAG_DO_NOT_SHOOT)) then
			return math.floor(skill_time / (fire_delay * fire_delay_multi))
		end
	end
	return 0
end

function Puyo:OnInit(npc)
	if Puyo:IsPuyo(npc) then
		local new_effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, modEffectVariant.PUYO_FIRE_POINT, 0, npc.Position, Vector(0, 0), npc):ToEffect()
		Puyo:SetFirePoint(npc, new_effect)
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_NPC_INIT, Puyo.OnInit, modEntityType.ENTITY_PUYO)

function Puyo:RemoveProjectile(npc)
	--local data = GetPuyoData(npc)
	--local fire_point = data.FirePoint
	--local entities = Isaac.GetRoomEntities()
	for i, projectile in pairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do
		if Puyo:IsSpawnedByPuyo(projectile) then
			projectile:Remove()
		end
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_NPC_UPDATE, CallbackPriority.EARLY, Puyo.RemoveProjectile, modEntityType.ENTITY_PUYO)

--[[
function GetNearestPlayer(other)
	local player0 = Isaac.GetPlayer(0)
	local dis0 = (player0.Position - other.Position):Length()
	for p = 1, Game():GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(p)
		local dis = (player.Position - other.Position):Length()
		if dis < dis0 then
			dis0 = dis
			player0 = player
		end
	end
	return player0
end

function GetNearestPlayerDistance(other)
	local player0 = Isaac.GetPlayer(0)
	local dis0 = (player0.Position - other.Position):Length()
	for p = 1, Game():GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(p)
		local dis = (player.Position - other.Position):Length()
		if dis < dis0 then
			dis0 = dis
		end
	end
	return dis0
end
]]
function Puyo:FireDefaultProjectile(npc, dir, shot_speed, pos, projectile_flags, falling_spd, falling_acl)
	dir = dir or Puyo:GetFireDir(npc)
	shot_speed = shot_speed or Puyo:GetShotSpeed(npc)
	pos = pos or npc.Position
	local projectile = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_NORMAL, 0, 
									pos, dir:Normalized() * shot_speed, 
									Puyo:GetFirePoint(npc)):ToProjectile()
	if npc:HasEntityFlags(EntityFlag.FLAG_SLOW) then
		projectile:AddProjectileFlags(ProjectileFlags.SLOWED)
	end
	if projectile_flags then
		projectile:AddProjectileFlags(projectile_flags)
	end
	if falling_spd then
		projectile.FallingSpeed = falling_spd
	end
	if falling_acl then
		projectile.FallingAccel = falling_acl
	end
	return projectile
end

function Puyo:FireRepeatedProjectile(npc, dir, shot_speed, repeat_times, repeat_shift, pos, projectile_flags, falling_spd, falling_acl)
	dir = dir or Puyo:GetFireDir(npc)
	if repeat_times == nil or repeat_times < 1 then
		repeat_times = 1
	end
	repeat_shift = repeat_shift or 0
	local projectile_table = {}
	for i = 0, (repeat_times - 1) do
		local projectile = Puyo:FireDefaultProjectile(npc, dir:Rotated((-repeat_shift * (repeat_times - 1) / 2) + repeat_shift * i), shot_speed, pos, projectile_flags, falling_spd, falling_acl)
		table.insert(projectile_table, projectile)
	end
	return projectile_table
end
--[[
function Puyo:shoot(npc, projectile_pos, projectile_dir)
	local data = GetPuyoData(npc)
	local fire_point = data.FirePoint
	local projectile = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, projectile_pos, projectile_dir, fire_point):ToProjectile()
	if npc:HasEntityFlags(EntityFlag.FLAG_SLOW) then
		projectile:AddProjectileFlags(ProjectileFlags.SLOWED)
	end
	return projectile
end
]]
function Puyo:GetSkillTypeByCurrentStage(stage)
	local game = Game()
	local skill_type = PuyoSkillType.SKILL_NONE
	if game.Difficulty == Difficulty.DIFFICULTY_NORMAL then
		skill_type = math.min(math.ceil(stage / 2), PuyoSkillType.NUM_NES_VERSION_SKILLS)
		skill_type = skill_type + PuyoSkillType.NUM_ARC_VERSION_SKILLS
	elseif game.Difficulty == Difficulty.DIFFICULTY_HARD then
		if stage == LevelStage.STAGE5 or stage == LevelStage.STAGE4_3 then
			skill_type = PuyoSkillType.SKILL_MACHINE_GUN
		elseif stage >= LevelStage.STAGE6 then
			skill_type = PuyoSkillType.SKILL_RIFLE
		else
			skill_type = stage
		end
	elseif game.Difficulty == Difficulty.DIFFICULTY_GREED then
		skill_type = math.min(stage, PuyoSkillType.NUM_NES_VERSION_SKILLS)
		skill_type = skill_type + PuyoSkillType.NUM_ARC_VERSION_SKILLS
	else
		local SkillTypeList = {
			[LevelStage.STAGE1_GREED] = PuyoSkillType.SKILL_WINCHESTER,
			[LevelStage.STAGE2_GREED] = PuyoSkillType.SKILL_BOOMERANG,
			[LevelStage.STAGE3_GREED] = PuyoSkillType.SKILL_SHOT_GUN,
			[LevelStage.STAGE4_GREED] = PuyoSkillType.SKILL_DARTS,
			[LevelStage.STAGE5_GREED] = PuyoSkillType.SKILL_MACHINE_GUN,
		}
		if stage >= LevelStage.STAGE6_GREED then
			skill_type = PuyoSkillType.SKILL_RIFLE
		else
			skill_type = SkillTypeList[stage] or PuyoSkillType.SKILL_NONE
		end
	end
	return skill_type
end

function Puyo:GetTargetDistance(npc)
	local target = Puyo:GetTarget(npc)
	return target.Position:Distance(npc.Position)
end

local PuyoSkills = {}
PuyoSkills[PuyoSkillType.SKILL_WINCHESTER] = function (npc)
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
			Puyo:FireDefaultProjectile(npc, nil, nil, pos, ProjectileFlags.SHIELDED)
		end
	end
end

PuyoSkills[PuyoSkillType.SKILL_DARTS] = function (npc)
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
		local falling_spd = 0
		local falling_acl = -0.05
		Puyo:FireRepeatedProjectile(npc, nil, nil, 2, 60, nil, projectile_flags, falling_spd, falling_acl)
	end
end

PuyoSkills[PuyoSkillType.SKILL_DYNAMITE] = function (npc)
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
			Puyo:FireDefaultProjectile(npc, nil, nil, nil, projectile_flags)
		else
			local shot_speed = 8
			local projectile_flags = ProjectileFlags.EXPLODE | ProjectileFlags.ACID_GREEN
			local falling_spd = -13
			local falling_acl = 0.6
			Puyo:FireDefaultProjectile(npc, nil, shot_speed, nil, projectile_flags, falling_spd, falling_acl)
		end
	end
end

PuyoSkills[PuyoSkillType.SKILL_SHOT_GUN] = function (npc)
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
	local sprite = npc:GetSprite()
	if sprite:IsEventTriggered("Shoot") then
		if not Puyo:HasFlag(npc, PuyoFlag.FLAG_DO_NOT_SHOOT) then
			local shot_speed = 14
			Puyo:SetShotSpeed(npc, shot_speed)
			local projectile_flags = ProjectileFlags.SMART | ProjectileFlags.GHOST | ProjectileFlags.SHIELDED -- | ProjectileFlags.TURN_HORIZONTAL
			local falling_spd = 0
			local falling_acl = -0.05
			Puyo:FireRepeatedProjectile(npc, nil, nil, 2, 60, nil, projectile_flags, falling_spd, falling_acl)
		end
	end
end

PuyoSkills[PuyoSkillType.SKILL_ALT_FIRE_BALL] = function (npc)
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
	local sprite = npc:GetSprite()
	if sprite:IsEventTriggered("Shoot") then
		if not Puyo:HasFlag(npc, PuyoFlag.FLAG_DO_NOT_SHOOT) then
			local shot_speed = 12
			Puyo:SetShotSpeed(npc, shot_speed)
			local projectile_flags = ProjectileFlags.BURST
			local falling_acl = 0.1
			Puyo:FireDefaultProjectile(npc, nil, nil, nil, projectile_flags, nil, falling_acl)
		end
	end
end

PuyoSkills[PuyoSkillType.SKILL_ALT_BOMB_GUN] = function (npc)
	local sprite = npc:GetSprite()
	if sprite:IsEventTriggered("Shoot") then
		if not Puyo:HasFlag(npc, PuyoFlag.FLAG_DO_NOT_SHOOT) then
			local shot_speed = 16
			Puyo:SetShotSpeed(npc, shot_speed)
			local projectile_flags = ProjectileFlags.EXPLODE | ProjectileFlags.ACID_GREEN
			local falling_acl = 0.1
			Puyo:FireDefaultProjectile(npc, nil, nil, nil, projectile_flags, nil, falling_acl)
		end
	end
end

PuyoSkills[PuyoSkillType.SKILL_ALT_MACHINE_GUN] = function (npc)
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

local PuyoSpecific = {}
PuyoSpecific[PuyoVariant.PUYO_BLUE] = function (npc)
	local amplitude = 3.6		--振幅
	local angular_freq = 26 * 0.004 * (2 * math.pi)	--角频率
	local offset_Y = amplitude * math.cos(math.deg(angular_freq * npc.FrameCount))
	npc.SpriteOffset = Vector(0, offset_Y)
	npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
end

function Puyo:OnUpdate(npc)
	if Puyo:IsPuyo(npc) then
		local game = Game()
		local data = GetPuyoData(npc)
		

		PuyoDataInit(npc)
		Puyo:SetTarget(npc, npc:GetPlayerTarget())
		local target = Puyo:GetTarget(npc)
		if target then
			Puyo:SetFireDir(npc, (target.Position - npc.Position):Normalized())
		end

		Tools:GameData_AddAttribute("PuyoComboInCurrentRoom", 0)

		--注意：有些噗哟免疫火焰或冰冻。
		local puyo_variant = npc.Variant
		if PuyoSpecific[puyo_variant] ~= nil then
			PuyoSpecific[puyo_variant](npc)
		end

		local normal_skill_type = Puyo:GetSkillTypeByCurrentStage(game:GetLevel():GetStage())
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
ModRef:AddCallback(ModCallbacks.MC_NPC_UPDATE, Puyo.OnUpdate, modEntityType.ENTITY_PUYO)

function Puyo:IsLinked(entity_A, entity_B)
	local max_dis = 40
	return entity_A.Position:Distance(entity_B.Position) <= max_dis
end

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

local function GetSFXByCurrentCombo(combo)
	combo = combo or 1
	combo = math.max(1, math.min(combo, 7))
	local PuyoChainSFXList = {
		[1] = modSoundEffect.SOUND_PUYO_1_CHAIN,
		[2] = modSoundEffect.SOUND_PUYO_2_CHAIN,
		[3] = modSoundEffect.SOUND_PUYO_3_CHAIN,
		[4] = modSoundEffect.SOUND_PUYO_4_CHAIN,
		[5] = modSoundEffect.SOUND_PUYO_5_CHAIN,
		[6] = modSoundEffect.SOUND_PUYO_6_CHAIN,
		[7] = modSoundEffect.SOUND_PUYO_7_CHAIN,
	}
	return PuyoChainSFXList[combo]
end

function Puyo:Owanimo(npc)
	local effect = Tools:PlayUniqueAnimation(npc, "Owanimo")
	local data = Tools:GetEffectData(effect)
	data.PuyoOwanimoData = data.PuyoOwanimoData or {}
	data.PuyoOwanimoData.Variant = npc.Variant
	data.PuyoOwanimoData.Flag = Puyo:GetFlag(npc)
	npc:Remove()
end

function Puyo:CheckIfLinked()
	local GrimoirePlayerNum = GetGrimoirePlayerNum()
	local NumPlayers = Game():GetNumPlayers()
	local CanPlaySFX = false
	local prev_combo = Tools:GameData_GetAttribute("PuyoComboInCurrentRoom")
	if prev_combo == nil then
		Tools:GameData_SetAttribute("PuyoComboInCurrentRoom", 0)
		prev_combo = 0
	end
	local combo = prev_combo + 1
	--第一步：构造实体对象数组（注：并非NPC实体对象数组，使用前应先转换）
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
				if #(LinkedPuyoHeap[k]) >= 4 then
					CanPlaySFX = true
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
	if CanPlaySFX then
		Tools:GameData_ModifyAttribute("PuyoComboInCurrentRoom", 1)
		SFXManager():Play(GetSFXByCurrentCombo(combo))
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_UPDATE, Puyo.CheckIfLinked)

function Puyo:PostEntityKill(entity)
	if Puyo:IsPuyo(entity) then
		local gel_subtype = GelSubTypeList[entity.Variant]
		if gel_subtype and (not Puyo:HasFlag(entity, PuyoFlag.FLAG_DO_NOT_GRANT_GEL)) then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, modPickupVariant.PICKUP_GEL, gel_subtype, entity.Position, Vector(0, 0), entity)
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, Puyo.PostEntityKill, modEntityType.ENTITY_PUYO)

function Puyo:PostNewRoom()
	Tools:GameData_SetAttribute("PuyoComboInCurrentRoom", 0)

	local level = Game():GetLevel()
	local room_desc = level:GetCurrentRoomDesc()
	local base_chance = 0.02
	local chance = base_chance
	if Tools:RoomCanTriggerEvent(room_desc, chance) then
		--//生成噗哟
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Puyo.PostNewRoom)

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

function Puyo:Effect_OnUpdate(effect)
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
ModRef:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Puyo.Effect_OnUpdate, modEffectVariant.BLANK_ANIM)

return Puyo