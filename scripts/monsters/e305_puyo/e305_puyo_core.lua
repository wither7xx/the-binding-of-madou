local Puyo_META = {
	__index = setmetatable({}, include("scripts/monsters/e305_puyo/e305_puyo_constants")),
}
local Puyo = Puyo_META.__index

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
local tbomCallbacks = tbom.tbomCallbacks
local Magic = tbom.Magic
local LevelExp = tbom.LevelExp
local CriticalChance = tbom.CriticalChance

local PuyoVariant = tbom.PuyoVariant
local GelSubType = tbom.GelSubType
local PuyoSkillType = Puyo.PuyoSkillType
local PuyoFlag = Puyo.PuyoFlag
local GelSubTypeList = Puyo.GelSubTypeList
local PuyoTearFuncList = Puyo.PuyoTearFuncList

local function GetPuyoData(npc)
	local data = Tools:GetNPCData(npc)
	data.PuyoData = data.PuyoData or {}
	return data.PuyoData
end

function Puyo:PuyoDataInit(npc)
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
	if data.StackingPuyoNum == nil then
		data.StackingPuyoNum = 1
	end
end

function Puyo:IsPuyo(entity)
	return entity and entity.Type == modEntityType.ENTITY_PUYO and Common:IsInTable(entity.Variant, PuyoVariant)
end

function Puyo:IsSpawnedByPuyo(entity)
	return entity.SpawnerType and entity.SpawnerType == modEntityType.ENTITY_PUYO and Common:IsInTable(entity.SpawnerVariant, PuyoVariant)
end

function Puyo:IsSpawnedByFirePoint(entity)
	return entity.SpawnerType and entity.SpawnerType == EntityType.ENTITY_EFFECT and entity.SpawnerVariant == modEffectVariant.PUYO_FIRE_POINT
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

function Puyo:GetStackingPuyoNum(npc)
	local data = GetPuyoData(npc)
	return data.StackingPuyoNum or 1
end

function Puyo:SetStackingPuyoNum(npc, value)
	local data = GetPuyoData(npc)
	data.StackingPuyoNum = math.max(1, value)
end

function Puyo:ModifyStackingPuyoNum(npc, amount)
	local data = GetPuyoData(npc)
	if data.StackingPuyoNum then
		data.StackingPuyoNum = math.max(1, data.StackingPuyoNum + amount)
	end
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
function Puyo:FireDefaultProjectile(npc, dir, shot_speed, pos, projectile_flags, falling_spd, falling_acl, tear_flags)
	dir = dir or Puyo:GetFireDir(npc)
	shot_speed = shot_speed or Puyo:GetShotSpeed(npc)
	pos = pos or npc.Position
	projectile_flags = projectile_flags or 0
	tear_flags = tear_flags or TearFlags.TEAR_NORMAL
	if not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
		local new_entity = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_NORMAL, 0, 
										pos, dir:Normalized() * shot_speed, 
										Puyo:GetFirePoint(npc))
		local projectile = new_entity:ToProjectile()
		if npc:HasEntityFlags(EntityFlag.FLAG_SLOW) then
			projectile:AddProjectileFlags(ProjectileFlags.SLOWED)
		end
		projectile:AddProjectileFlags(projectile_flags)
		if falling_spd then
			projectile.FallingSpeed = falling_spd
		end
		if falling_acl then
			projectile.FallingAccel = falling_acl
		end
		return new_entity
	else
		local new_entity = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLOOD, 0, 
										pos, dir:Normalized() * shot_speed, 
										Puyo:GetFirePoint(npc))
		new_entity.CollisionDamage = 6
		local tear = new_entity:ToTear()
		if npc:HasEntityFlags(EntityFlag.FLAG_SLOW) then
			tear:AddTearFlags(TearFlags.TEAR_SLOW)
		end
		if not Puyo:HasFlag(npc, PuyoFlag.FLAG_CANNOT_HAS_TEAR_FLAGS) then
			local puyo_variant = npc.Variant
			if PuyoTearFuncList[puyo_variant] and Random() % 12 == 0 then
				PuyoTearFuncList[puyo_variant](tear)
			end
		end
		tear:AddTearFlags(tear_flags)
		if tear:HasTearFlags(TearFlags.TEAR_EXPLOSIVE) then
			tear.CollisionDamage = 50
		end
		if falling_spd then
			tear.FallingSpeed = falling_spd
		end
		if falling_acl then
			tear.FallingAcceleration = falling_acl
		end
		return new_entity
	end
end

function Puyo:FireRepeatedProjectile(npc, dir, shot_speed, repeat_times, repeat_shift, pos, projectile_flags, falling_spd, falling_acl, tear_flags)
	dir = dir or Puyo:GetFireDir(npc)
	if repeat_times == nil or repeat_times < 1 then
		repeat_times = 1
	end
	repeat_shift = repeat_shift or 0
	local projectile_table = {}
	for i = 0, (repeat_times - 1) do
		local projectile = Puyo:FireDefaultProjectile(npc, dir:Rotated((-repeat_shift * (repeat_times - 1) / 2) + repeat_shift * i), shot_speed, pos, projectile_flags, falling_spd, falling_acl, tear_flags)
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
function Puyo:GetSkillTypeByStage(stage, difficulty)
	local skill_type = PuyoSkillType.SKILL_NONE
	if difficulty == Difficulty.DIFFICULTY_NORMAL then
		skill_type = math.min(math.ceil(stage / 2), PuyoSkillType.NUM_NES_VERSION_SKILLS)
		skill_type = skill_type + PuyoSkillType.NUM_ARC_VERSION_SKILLS
	elseif difficulty == Difficulty.DIFFICULTY_HARD then
		if stage == LevelStage.STAGE5 or stage == LevelStage.STAGE4_3 then
			skill_type = PuyoSkillType.SKILL_MACHINE_GUN
		elseif stage >= LevelStage.STAGE6 then
			skill_type = PuyoSkillType.SKILL_RIFLE
		else
			skill_type = stage
		end
	elseif difficulty == Difficulty.DIFFICULTY_GREED then
		skill_type = math.min(stage, PuyoSkillType.NUM_NES_VERSION_SKILLS)
		skill_type = skill_type + PuyoSkillType.NUM_ARC_VERSION_SKILLS
	elseif difficulty == Difficulty.DIFFICULTY_GREEDIER then
		local SkillTypeList = {
			[LevelStage.STAGE1_GREED] = PuyoSkillType.SKILL_WINCHESTER,
			[LevelStage.STAGE2_GREED] = PuyoSkillType.SKILL_BOOMERANG,
			[LevelStage.STAGE3_GREED] = PuyoSkillType.SKILL_SHOT_GUN,
			[LevelStage.STAGE4_GREED] = PuyoSkillType.SKILL_DARTS,
			[LevelStage.STAGE5_GREED] = PuyoSkillType.SKILL_MACHINE_GUN,
		}
		if stage >= LevelStage.STAGE6_GREED then
			skill_type = PuyoSkillType.SKILL_DOUBLE_PISTOL
		else
			skill_type = SkillTypeList[stage] or PuyoSkillType.SKILL_NONE
		end
	end
	return skill_type
end


function Puyo:GetSkillTypeByCurrentStage(level)
	local game = Game()
	level = level or game:GetLevel()
	local stage = level:GetStage()
	local stage_type = level:GetStageType()
	local skill_type = PuyoSkillType.SKILL_NONE
	if not game:IsGreedMode() then
		if level:IsPreAscent() then
			stage = LevelStage.STAGE4_1
		elseif level:IsAscent() then
			stage = LevelStage.STAGE4_1 + (4 - math.ceil(stage / 2))
			if stage == LevelStage.STAGE5 then
				stage = LevelStage.STAGE6
			end
		elseif stage_type == StageType.STAGETYPE_REPENTANCE or stage_type == StageType.STAGETYPE_REPENTANCE_B then
			stage = stage + 1
		end
	end
	return Puyo:GetSkillTypeByStage(stage, game.Difficulty)
end

function Puyo:GetTargetDistance(npc)
	local target = Puyo:GetTarget(npc)
	return target.Position:Distance(npc.Position)
end

function Puyo:IsLinked(entity_A, entity_B)
	local max_dis = 40
	return entity_A.Position:Distance(entity_B.Position) <= max_dis
end

function Puyo:GetSFXByCurrentCombo(combo)
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

--[[
function Puyo:ShouldOwanimo(npc_list)
	local sum = 0
	for _, npc in ipairs(npc_list) do
		sum = sum + Puyo:GetStackingPuyoNum(npc)
		if sum >= 4 then
			return true
		end
	end
	return false
end
]]

function Puyo:Owanimo(npc)
	local effect = Tools:PlayUniqueAnimation(npc, "Owanimo")
	local data = Tools:GetEffectData(effect)
	data.PuyoOwanimoData = data.PuyoOwanimoData or {}
	data.PuyoOwanimoData.Variant = npc.Variant
	data.PuyoOwanimoData.Flag = Puyo:GetFlag(npc)
	npc:Remove()
end

local BasePuyoChance = Puyo.BasePuyoChance

function Puyo:AddPuyoChanceCache(key, value)
	local data = Tools:GameData_GetAttribute("PuyoChanceCache", true)
	if data[key] ~= value then
		data[key] = value
	end
end

function Puyo:ClearPuyoChanceCache(key)
	local data = Tools:GameData_GetAttribute("PuyoChanceCache", true)
	if data[key] ~= nil then
		data[key] = nil
	end
end

function Puyo:GetPuyoChance()
	local data = Tools:GameData_GetAttribute("PuyoChanceCache", true)
	local sum = BasePuyoChance
	for _, cache in pairs(data) do
		sum = sum + cache
	end
	return sum
end

function Puyo:CanSpawnPuyo(room, level)
	local room_desc = level:GetCurrentRoomDesc()
	local starting_room_idx = level:GetStartingRoomIndex()
	local stage = level:GetStage()
	local room_cfg_room = room_desc.Data
	local room_type = room_cfg_room.Type
	local puyo_chance = Puyo:GetPuyoChance()
	return Tools:RoomCanTriggerEvent(room_desc, puyo_chance) 
		and room:IsFirstVisit() 
		and room_desc.GridIndex ~= starting_room_idx 
		and room_type == RoomType.ROOM_DEFAULT 
		and stage ~= LevelStage.STAGE8
end

function Puyo:SpawnRandomPuyo(room, level, seed, max_amount)
	max_amount = max_amount or 4
	max_amount = math.min(max_amount, 31)
	local PuyoVariantList = {
		[1] = PuyoVariant.PUYO_GREEN,
		[2] = PuyoVariant.PUYO_PURPLE,
		[3] = PuyoVariant.PUYO_RED,
		[4] = PuyoVariant.PUYO_YELLOW,
		[5] = PuyoVariant.PUYO_BLUE,
	}
	local puyo_list = {}
	local room_desc = level:GetCurrentRoomDesc()
	if seed == nil then
		seed = room_desc.SpawnSeed
		if Game():IsGreedMode() then
			seed = Random()
		end
	end
	local amount = 1 + max_amount - math.floor(math.sqrt((seed % (max_amount * max_amount - 1)) + 1))
	local margin = 80
	for i = 1, amount do
		local puyo_variant = PuyoVariantList[(math.floor(seed  / (10 ^ (i - 1))) % #PuyoVariantList) + 1]
		local pos = room:GetRandomPosition(margin)
		local new_puyo = Isaac.Spawn(tbom.modEntityType.ENTITY_PUYO, puyo_variant, 0, pos, Vector(0, 0), nil)
		table.insert(puyo_list, new_puyo)
	end
	return puyo_list
end

return Puyo_META