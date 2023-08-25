local Main = {}
local CM_AnotherCartride = include("compatible mods/martha/items/trinkets/tbom/t001_another_cartride/t001_another_cartride_core").__index

local modTrinketType = tbom.modTrinketType
local AnotherCartride = include("scripts/items/trinkets/t001_another_cartride/t001_another_cartride_api")
local ModRef = tbom

local modEffectVariant = tbom.modEffectVariant

local MarthaPlayerType = tbom.CM_MarthaPlayerType

local Hope = Martha.Collectibles.Hope
local Martha_Character = Martha.Players.Martha

function Main:Martha_PostPlayerUpdate(player)
	CM_AnotherCartride:AnotherCartrideDataInit(player)
	if player:GetPlayerType() == MarthaPlayerType.PLAYER_MARTHA and Martha_Character:IsMarthaValid(player) then
		CM_AnotherCartride:SetIfUsingMarthaData(player, true)
		local cost = Martha:GetMarthaBlastHopeCost(player)
		local cooldowned = CM_AnotherCartride:GetBlastCooldown(player) <= 0
		if player:HasCollectible(CollectibleType.COLLECTIBLE_FAST_BOMBS) then
			cooldowned = true
		end
		if cooldowned and Input.IsActionTriggered(ButtonAction.ACTION_BOMB, player.ControllerIndex) then
			local canBlast = false
			if CM_AnotherCartride:GetHope(player) >= cost or player:HasCollectible(CollectibleType.COLLECTIBLE_BLOOD_BOMBS) then
				canBlast = true
			end
			if canBlast then
				local radius = 100
				local checkpoint_triggered = false
				for _, checkpoint in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, modEffectVariant.ET_CHECKPOINT)) do
					if player.Position:Distance(checkpoint.Position) <= radius then
						checkpoint_triggered = true
						break
					end
				end
				if checkpoint_triggered then
					AnotherCartride:TryTriggerEffect()
				end
			end
		end
		CM_AnotherCartride:SetIfUsingMarthaData(player, false)
		CM_AnotherCartride:TryUpdateMarthaData(player)
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Main.Martha_PostPlayerUpdate, 0)

return Main