local Main = {}
local AnotherCartride = include("scripts/items/trinkets/t001_another_cartride/t001_another_cartride_api")
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

function Main:PostPlayerUpdate(player)
	AnotherCartride:AnotherCartrideDataInit(player)

	local phase = AnotherCartride:GetPhase(player)
	local timeout = AnotherCartride:GetTimeout(player)
	local current_checkpoint = AnotherCartride:GetCurrentCheckpoint(player)
	if player:HasTrinket(modTrinketType.TRINKET_ANOTHER_CARTRIDE) and phase ~= TrinketPhase.PHASE_ON_SPACESHIP then
		if AnotherCartride:IsInCheckpoint(player) then
			if current_checkpoint ~= CheckpointType.CHECKPOINT_SPACESHIP then
				AnotherCartride:SetCurrentCheckpoint(player, CheckpointType.CHECKPOINT_SPACESHIP)
			else
				local bubbles = AnotherCartride:GetBubbles(player)
				if bubbles then
					bubbles:Update()
				end
			end
		else
			AnotherCartride:SetIfStartingAnimFinished(player, false)
			if current_checkpoint == CheckpointType.CHECKPOINT_SPACESHIP then
				AnotherCartride:SetCurrentCheckpoint(player, CheckpointType.CHECKPOINT_NOT_FOUND)
			end
		end
	else
		if phase ~= TrinketPhase.PHASE_ON_SPACESHIP then
			AnotherCartride:SetPhase(player, TrinketPhase.PHASE_STANDBY)
		end
	end
	if phase == TrinketPhase.PHASE_ON_SPACESHIP then
		if timeout > 0 and timeout < 150 then
			AnotherCartride:TryAddNewSpaceship(player)
		elseif timeout == 0 then
			player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, UseFlag.USE_NOANIM)
			player.ControlsEnabled = true
			AnotherCartride:SetPhase(player, TrinketPhase.PHASE_STANDBY)
		end
	end
	AnotherCartride:ModifyTimeout(player, -1)
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Main.PostPlayerUpdate, 0)

function Main:PostPlayerRender(player, offset)	--不要将player:Render()放在这里，会死递归！
	local phase = AnotherCartride:GetPhase(player)
	local timeout = AnotherCartride:GetTimeout(player)
	local current_checkpoint = AnotherCartride:GetCurrentCheckpoint(player)
	local game = Game()
	local room = game:GetRoom()
	if room:IsClear() and room:GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT then
		if player:HasTrinket(modTrinketType.TRINKET_ANOTHER_CARTRIDE) and current_checkpoint == CheckpointType.CHECKPOINT_SPACESHIP and phase ~= TrinketPhase.PHASE_ON_SPACESHIP then
			local bubbles = AnotherCartride:GetBubbles(player)
			if bubbles then
				if AnotherCartride:IsStartingAnimFinished(player) then
					bubbles:Play("CheckPoint")
				else
					bubbles:Play("Appear")
					if bubbles:IsFinished("Appear") then
						AnotherCartride:SetIfStartingAnimFinished(player, true)
					end
				end
				local pos = Tools:GetEntityRenderScreenPos(player, true) + Vector(0, -35)
				bubbles:Render(pos)
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, Main.PostPlayerRender, 0)

function Main:PostEntityRemove(entity)
	local bomb = entity:ToBomb()
	local base_radius = 80
	local radius = base_radius * bomb.RadiusMultiplier
	local checkpoint_triggered = false
	for _, checkpoint in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, modEffectVariant.ET_CHECKPOINT)) do
		if bomb.Position:Distance(checkpoint.Position) <= radius then
			checkpoint_triggered = true
			break
		end
	end
	if checkpoint_triggered then
		AnotherCartride:TryTriggerEffect()
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, Main.PostEntityRemove, EntityType.ENTITY_BOMB)

function Main:PostNewRoom()
	if AnotherCartride:HasAnotherCartridePlayer() then
		AnotherCartride:TryAddNewCheckpointRoomIdx()
		if AnotherCartride:IsInCheckpointRoom() then
			local room = Game():GetRoom()
			AnotherCartride:TryAddNewCheckpoint(room)
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Main.PostNewRoom)

return AnotherCartride