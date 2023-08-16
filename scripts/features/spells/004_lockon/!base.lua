local Lockon = {}
local ModRef = tbom

local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths

local tbomCallbacks = tbom.tbomCallbacks
local modEffectVariant = tbom.modEffectVariant
local MagicType = tbom.MagicType
local Magic = tbom.Magic
local modSoundEffect = tbom.modSoundEffect

function Lockon:IsTargetInLaserSight(player, other)
	local sight_dir = Vector.FromAngle(player:GetSmoothBodyRotation()):Normalized()
	if (other.Position - player.Position):Length() > 500 then
		return false
	end
	local target_dir = (other.Position - player.Position):Normalized()
	local angle = math.deg(math.acos(sight_dir:Dot(target_dir)))
	return angle <= 15 and angle >= 0
end

function Lockon:CanLockonTarget(player, spell_ID)
	local TargetNum = (Magic:BaseSpell_GetAttribute(player, MagicType.LOCKON, "TargetNum") or 0)
	local MaxTargetNum = Magic:GetMaxTargetNum(spell_ID)
	return Magic:IsMadouRyokuEnough(player, spell_ID, false, false) 
		and (TargetNum < MaxTargetNum)
end

function Lockon:CanLockonSpecificTarget(player, entity, spell_ID)
	local LockonCD = Magic:BaseSpell_GetAttribute(player, MagicType.LOCKON, "LockonCD")
	local BonusDMGMulti = (Magic:Spell_GetAttribute(player, spell_ID, "BonusDMGMulti") or 1)
	local LockonDMG = player.Damage * Magic:GetDMGMulti(spell_ID) * BonusDMGMulti
	local entity_data = entity:GetData()
	return Lockon:CanLockonTarget(player, spell_ID)								--角色能够锁定目标
		and entity:IsVulnerableEnemy()											--敌人可被伤害
		and (not EntityRef(entity).IsFriendly)									--敌人未被永久魅惑
		and Lockon:IsTargetInLaserSight(player, entity)							--敌人在激光束瞄准范围内
		and (entity_data.LockonMarksAmount == nil								
			or entity.HitPoints >= entity_data.LockonMarksAmount * LockonDMG)	--敌人目前叠的标记数不足以杀死它
		and LockonCD == 0														--每次标记的时间间隔（计数器）归零
end

function Lockon:OnEnable(spell_ID, rng, player, use_flags)
	local magic_type = MagicType.LOCKON
	local LaserSight_prev = Magic:BaseSpell_GetAttribute(player, magic_type, "LaserSight")
	if (not LaserSight_prev or not LaserSight_prev:Exists()) then
		local LaserSight = Isaac.Spawn(EntityType.ENTITY_EFFECT, modEffectVariant.LASER_SIGHT, 0, player.Position, Vector(0, 0), player):ToEffect()
		LaserSight.Parent = player
		LaserSight:GetSprite().Color = Color(0, 1, 0, 0.3, 0, 0, 0)
		LaserSight.SpriteScale = Vector(0.5, 1)
		LaserSight.Rotation = player:GetSmoothBodyRotation() - 90
		LaserSight.SpriteRotation = LaserSight.Rotation
		LaserSight.Position = player.Position
		LaserSight.Velocity = player.Velocity
		LaserSight:FollowParent(LaserSight.Parent)
		Magic:BaseSpell_SetAttribute(player, magic_type, "LaserSight", LaserSight)
		SFXManager():Play(modSoundEffect.SOUND_LASER_SIGHT)
	end
end
ModRef:AddCallback(tbomCallbacks.TBOMC_ENABLE_SPELL_BASE, Lockon.OnEnable, MagicType.LOCKON)

function Lockon:PostUpdate(spell_ID, player)
	local magic_type = MagicType.LOCKON
	local TargetHeap = Magic:BaseSpell_GetAttribute(player, magic_type, "TargetHeap")
	local LockonCD = Magic:BaseSpell_GetAttribute(player, MagicType.LOCKON, "LockonCD")
	local MaxTargetNum = Magic:GetMaxTargetNum(spell_ID)
	if LockonCD and LockonCD > 0 then
		Magic:BaseSpell_ModifyAttribute(player, magic_type, "LockonCD", -1)
	end
	if Magic:IsUsingSpell(player, spell_ID) then
		local LaserSight_prev = Magic:BaseSpell_GetAttribute(player, magic_type, "LaserSight")
		if (not LaserSight_prev or not LaserSight_prev:Exists()) then
			local LaserSight = Isaac.Spawn(EntityType.ENTITY_EFFECT, modEffectVariant.LASER_SIGHT, 0, player.Position, Vector(0, 0), player):ToEffect()
			LaserSight.Parent = player
			LaserSight:GetSprite().Color = Color(0, 1, 0, 0.3, 0, 0, 0)
			LaserSight.SpriteScale = Vector(0.5, 1)
			LaserSight.Rotation = player:GetSmoothBodyRotation() - 90
			LaserSight.SpriteRotation = LaserSight.Rotation
			LaserSight.Position = player.Position
			LaserSight.Velocity = player.Velocity
			LaserSight:FollowParent(LaserSight.Parent)
			Magic:BaseSpell_SetAttribute(player, magic_type, "LaserSight", LaserSight)
		end
		
		for i, entity in pairs(Isaac.GetRoomEntities()) do
			if entity:IsVulnerableEnemy() then
				if Lockon:CanLockonSpecificTarget(player, entity, spell_ID) then
					local entity_data = entity:GetData()
					if entity_data.LockonMarksAmount == nil then
						entity_data.LockonMarksAmount = 0
					end
					entity_data.LockonMarksAmount = entity_data.LockonMarksAmount + 1
					Magic:BaseSpell_ModifyAttribute(player, magic_type, "TargetNum", 1)
					Magic:CostDefaultMadouRyoku(player, spell_ID, false)
					if TargetHeap then
						table.insert(TargetHeap, entity)
					end

					local mark = Isaac.Spawn(EntityType.ENTITY_EFFECT, modEffectVariant.LOCKON_MARK, 0, entity.Position, Vector(0, 0), entity):ToEffect()
					SFXManager():Play(modSoundEffect.SOUND_LOCKON_MARK)
					mark.Parent = entity
					mark:FollowParent(mark.Parent)

					Magic:BaseSpell_ModifyAttribute(player, magic_type, "LockonCD", 5)
				end
			elseif (entity.Type == EntityType.ENTITY_EFFECT and entity.Variant == modEffectVariant.LOCKON_MARK) then
				if entity.Parent == nil then
					entity:Remove()
					Magic:BaseSpell_ModifyAttribute(player, magic_type, "TargetNum", -1)
				end
			end
		end
	elseif TargetHeap then
		for i = 1, MaxTargetNum do
			local target = TargetHeap[1]
			if target and target:Exists() then
				Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_POST_FIRE_LOCKON_WEAPON, spell_ID, spell_ID, player, target)
				if target and target:Exists() then
					local previous_data = target:GetData()
					if previous_data.LockonMarksAmount then
						previous_data.LockonMarksAmount = previous_data.LockonMarksAmount - 1
					end
				end
				table.remove(TargetHeap, 1)	--删除链表首节点（模拟）
			else
				table.remove(TargetHeap, 1)
			end
		end
		for i, entity in pairs(Isaac.GetRoomEntities()) do
			if entity.Type == EntityType.ENTITY_EFFECT and entity.Variant == modEffectVariant.LOCKON_MARK then
				entity:Remove()
			end
		end
		Magic:BaseSpell_SetAttribute(player, magic_type, "TargetNum", 0)
		local LaserSight = Magic:BaseSpell_GetAttribute(player, magic_type, "LaserSight")
		if LaserSight and LaserSight:Exists() then
			LaserSight:Remove()
			Magic:BaseSpell_ClearAttribute(player, magic_type, "LaserSight")
		end
	end
end
ModRef:AddCallback(tbomCallbacks.TBOMC_SPELL_UPDATE_BASE, Lockon.PostUpdate, MagicType.LOCKON)

function Lockon:PostNewRoom()
	local magic_type = MagicType.LOCKON
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = Game():GetPlayer(p)
		local TargetHeap = Magic:BaseSpell_GetAttribute(player, magic_type, "TargetHeap")
		local TargetNum = (Magic:BaseSpell_GetAttribute(player, magic_type, "TargetNum") or 0)
		for i = 1, TargetNum do
			table.remove(TargetHeap, 1)
		end
		Magic:BaseSpell_SetAttribute(player, magic_type, "TargetNum", 0)
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Lockon.PostNewRoom)

return Lockon