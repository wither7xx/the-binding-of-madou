local AnotherCartride_META = {
	__index = setmetatable({}, include("scripts/items/trinkets/t001_another_cartride/t001_another_cartride_constants")),
}
local AnotherCartride = AnotherCartride_META.__index
local ModRef = tbom

local Common = tbom.Global.Common
local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths
local Translation = tbom.Global.Translation

local tbomCallbacks = tbom.tbomCallbacks
local modTrinketType = tbom.modTrinketType
local modEffectVariant = tbom.modEffectVariant
local modSoundEffect = tbom.modSoundEffect

local TrinketPhase = AnotherCartride.TrinketPhase
local CheckpointType = AnotherCartride.CheckpointType

local function GetAnotherCartrideData(player)
	return Tools:GetPlayerTrinketData(player, modTrinketType.TRINKET_ANOTHER_CARTRIDE)
end

local function GetAnotherCartrideGlobalData()
	return Tools:Global_GetTrinketData(modTrinketType.TRINKET_ANOTHER_CARTRIDE)
end

function AnotherCartride:AnotherCartrideDataInit(player)
	local data = GetAnotherCartrideData(player)
	if data.Phase == nil then
		data.Phase = TrinketPhase.PHASE_STANDBY
	end
	if data.Timeout == nil then
		data.Timeout = 0
	end
	if data.StartingAnimFinished == nil then
		data.StartingAnimFinished = false
	end
	if data.CurrentCheckpoint == nil then
		data.CurrentCheckpoint = false
	end
	if data.Bubbles == nil then
		data.Bubbles = Sprite()
		data.Bubbles:Load("gfx/tbom/et_bubbles.anm2")
	end
end

function AnotherCartride:AnotherCartrideGlobalDataInit()
	local data = GetAnotherCartrideGlobalData()
	if data.CheckpointRoomIdx == nil then
		data.CheckpointRoomIdx = -1
	end
	if data.ShouldUpdateCheckpointPos == nil then
		data.ShouldUpdateCheckpointPos = true
	end
end

function AnotherCartride:GetPhase(player)
	local data = GetAnotherCartrideData(player)
	return data.Phase or TrinketPhase.PHASE_STANDBY
end

function AnotherCartride:SetPhase(player, value)
	local data = GetAnotherCartrideData(player)
	data.Phase = math.max(TrinketPhase.PHASE_STANDBY, value)
end

function AnotherCartride:GetTimeout(player)
	local data = GetAnotherCartrideData(player)
	return data.Timeout or 0
end

function AnotherCartride:SetTimeout(player, value)
	local data = GetAnotherCartrideData(player)
	data.Timeout = math.max(0, value)
end

function AnotherCartride:ModifyTimeout(player, amount)
	local data = GetAnotherCartrideData(player)
	if data.Timeout then
		data.Timeout = math.max(0, data.Timeout + amount) 
	end
end

function AnotherCartride:IsStartingAnimFinished(player)
	local data = GetAnotherCartrideData(player)
	return data.StartingAnimFinished or false
end

function AnotherCartride:SetIfStartingAnimFinished(player, value)
	local data = GetAnotherCartrideData(player)
	data.StartingAnimFinished = value
end

function AnotherCartride:GetCurrentCheckpoint(player)
	local data = GetAnotherCartrideData(player)
	return data.CurrentCheckpoint or CheckpointType.CHECKPOINT_NOT_FOUND
end

function AnotherCartride:SetCurrentCheckpoint(player, value)
	local data = GetAnotherCartrideData(player)
	data.CurrentCheckpoint = math.max(CheckpointType.CHECKPOINT_NOT_FOUND, value)
end

function AnotherCartride:GetBubbles(player)
	local data = GetAnotherCartrideData(player)
	return data.Bubbles
end

function AnotherCartride:ResetBubbles(player)
	local data = GetAnotherCartrideData(player)
	if data.Bubbles then
		data.Bubbles:Play("Appear")
		data.Bubbles:SetFrame(0)
	end
end

function AnotherCartride:GetSpaceship(player)
	local data = GetAnotherCartrideData(player)
	return data.Spaceship
end

function AnotherCartride:SetSpaceship(player, entity)
	local data = GetAnotherCartrideData(player)
	data.Spaceship = entity
end

function AnotherCartride:GetCheckpointRoomIdx()
	local data = GetAnotherCartrideGlobalData()
	return data.CheckpointRoomIdx
end

function AnotherCartride:SetCheckpointRoomIdx(value)
	local data = GetAnotherCartrideGlobalData()
	data.CheckpointRoomIdx = value
end

function AnotherCartride:ShouldUpdateCheckpointPos()
	local data = GetAnotherCartrideGlobalData()
	return data.ShouldUpdateCheckpointPos
end

function AnotherCartride:SetIfShouldUpdateCheckpointPos(value)
	local data = GetAnotherCartrideGlobalData()
	data.ShouldUpdateCheckpointPos = value
end

function AnotherCartride:GetCheckpointPos()
	local data = GetAnotherCartrideGlobalData()
	return data.CheckpointPos
end

function AnotherCartride:SetCheckpointPos(pos)
	local data = GetAnotherCartrideGlobalData()
	data.CheckpointPos = pos
end

function AnotherCartride:TryAddNewCheckpointRoomIdx()
	--local room_idx = AnotherCartride:GetCheckpointRoomIdx()
	--if room_idx == nil then
		local room_type_list = {
			RoomType.ROOM_DEFAULT,
		}
		local room_shape_list = {
			RoomShape.ROOMSHAPE_1x1,
		}
		local new_value = Tools:RandomRoomIdx(true, room_type_list, room_shape_list)
		AnotherCartride:SetCheckpointRoomIdx(new_value)
	--end
end

function AnotherCartride:TryAddNewCheckpoint(room)
	local pos = AnotherCartride:GetCheckpointPos()
	if pos == nil or AnotherCartride:ShouldUpdateCheckpointPos() then
		local margin = 80
		local new_pos = room:GetRandomPosition(margin)
		AnotherCartride:SetCheckpointPos(new_pos)
		pos = new_pos
		AnotherCartride:SetIfShouldUpdateCheckpointPos(false)
	end
	Isaac.Spawn(EntityType.ENTITY_EFFECT, modEffectVariant.ET_CHECKPOINT, 0, pos, Vector(0, 0), nil)
	--if room:IsFirstVisit() then		--²âÊÔ×¨ÓÃ
	--	Isaac.Spawn(tbom.modEntityType.ENTITY_PUYO, tbom.PuyoVariant.PUYO_PURPLE, 0, pos, Vector(0, 0), nil)
	--end
end

function AnotherCartride:TryAddNewSpaceship(player)
	local spaceship = AnotherCartride:GetSpaceship(player)
	local timeout = AnotherCartride:GetTimeout(player)
	if (not (spaceship and spaceship:Exists())) and timeout > 0 then
		local new_spaceship = Isaac.Spawn(EntityType.ENTITY_EFFECT, modEffectVariant.ET_SPACESHIP, 0, player.Position, Vector(0, 0), nil):ToEffect()
		new_spaceship.Parent = player
		new_spaceship:FollowParent(new_spaceship.Parent)
		if timeout >= 150 then
			new_spaceship.SpriteOffset = Vector(0, -(timeout - 150))
		else
			new_spaceship.SpriteOffset = Vector(0, -(300 - timeout * 2))
		end
		AnotherCartride:SetSpaceship(player, new_spaceship)
	end
end

function AnotherCartride:IsInCheckpointRoom()
	local game = Game()
	local level = game:GetLevel()
	local stage = level:GetStage()
	local room_idx = AnotherCartride:GetCheckpointRoomIdx()
	local current_room_desc = level:GetCurrentRoomDesc()
	local stage_blacklist = {
		LevelStage.STAGE4_3,
		LevelStage.STAGE8,
	}
	return room_idx 
		and room_idx >= 0 
		and room_idx == current_room_desc.SafeGridIndex 
		and Tools:GetDimByRoomDesc(current_room_desc) == 0
		and (not Common:IsInTable(stage, stage_blacklist))
end

function AnotherCartride:IsInCheckpoint(player)
	local max_radius = 30
	for _, checkpoint in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, modEffectVariant.ET_CHECKPOINT)) do
		if player.Position:Distance(checkpoint.Position) <= max_radius then
			return true
		end
	end
	return false
end

function AnotherCartride:HasAnotherCartridePlayer()
	local game = Game()
	local NumPlayers = game:GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = game:GetPlayer(p)
		if player:HasTrinket(modTrinketType.TRINKET_ANOTHER_CARTRIDE) then
			return true
		end
	end
	return false
end

function AnotherCartride:TryTriggerEffect()
	local game = Game()
	if AnotherCartride:HasAnotherCartridePlayer() then
		local NumPlayers = game:GetNumPlayers()
		for p = 0, NumPlayers - 1 do
			local player = game:GetPlayer(p)
			if player.ControlsEnabled then
				player.ControlsEnabled = false
			end
			AnotherCartride:SetTimeout(player, 300)
			Tools:Immunity_AddImmuneEffect(player, 150)
			AnotherCartride:TryAddNewSpaceship(player)
			AnotherCartride:SetPhase(player, TrinketPhase.PHASE_ON_SPACESHIP)
		end
		SFXManager():Play(modSoundEffect.SOUND_ET_SPACESHIP)
		--game:GetSeeds():ForgetStageSeed(game:GetLevel():GetStage())
		AnotherCartride:SetIfShouldUpdateCheckpointPos(true)
	end
end

return AnotherCartride_META