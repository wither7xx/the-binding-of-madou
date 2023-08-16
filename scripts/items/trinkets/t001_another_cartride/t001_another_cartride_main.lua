local AnotherCartride = setmetatable({}, include("scripts/items/trinkets/t001_another_cartride/t001_another_cartride_core"))
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

function AnotherCartride:PostPlayerUpdate(player)
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
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, AnotherCartride.PostPlayerUpdate, 0)

function AnotherCartride:PostPlayerRender(player, offset)	--��Ҫ��player:Render()������������ݹ飡
	local phase = AnotherCartride:GetPhase(player)
	local timeout = AnotherCartride:GetTimeout(player)
	local current_checkpoint = AnotherCartride:GetCurrentCheckpoint(player)
	local game = Game()
	if game:GetRoom():GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT then
		if current_checkpoint == CheckpointType.CHECKPOINT_SPACESHIP and phase ~= TrinketPhase.PHASE_ON_SPACESHIP then
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
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, AnotherCartride.PostPlayerRender, 0)

function AnotherCartride:PostEntityRemove(entity)
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
		local has_cartride_player = false
		local NumPlayers = Game():GetNumPlayers()
		for p = 0, NumPlayers - 1 do
			local player = Game():GetPlayer(p)
			if player:HasTrinket(modTrinketType.TRINKET_ANOTHER_CARTRIDE) then
				has_cartride_player = true
				break
			end
		end
		if has_cartride_player then
			for p = 0, NumPlayers - 1 do
				local player = Game():GetPlayer(p)
				if player.ControlsEnabled then
					player.ControlsEnabled = false
				end
				AnotherCartride:SetTimeout(player, 300)
				Tools:Immunity_AddImmuneEffect(player, 150)
				AnotherCartride:TryAddNewSpaceship(player)
				AnotherCartride:SetPhase(player, TrinketPhase.PHASE_ON_SPACESHIP)
			end
			SFXManager():Play(modSoundEffect.SOUND_ET_SPACESHIP)
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, AnotherCartride.PostEntityRemove, EntityType.ENTITY_BOMB)

return AnotherCartride