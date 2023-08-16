local Mana = {}
local ModRef = tbom

local Common = tbom.Global.Common
local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths

local modPickupVariant = tbom.modPickupVariant
local modCollectibleType = tbom.modCollectibleType
local Magic = tbom.Magic

function Mana:Spawn(pickup)	
	local MageNum = 0
	local GrimoireNum = 0
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = Isaac.GetPlayer(p)
		if Magic:IsMageCharacter(player) then
			MageNum = MageNum + 1
		elseif player:HasCollectible(modCollectibleType.COLLECTIBLE_BLUE_GRIMOIRE) then
			GrimoireNum = GrimoireNum + 1
		end
	end
	local room = Game():GetRoom()
	if MageNum + GrimoireNum > 0 and (not room:HasCurseMist()) then
		local chance = 1 / 24 * 100
		if MageNum > 0 then
			chance = 10
		end
		chance = chance + math.max(0, (GrimoireNum - 1)) * 2 + math.max(0, (MageNum - 1)) * 3
		if not (pickup:IsShopItem() 
				or (pickup.Variant == PickupVariant.PICKUP_COIN and pickup.SubType == CoinSubType.COIN_GOLDEN)) then
			if Tools:CanTriggerEvent(pickup, chance) then
				pickup:Morph(EntityType.ENTITY_PICKUP, modPickupVariant.PICKUP_MANA, 0, false, true, true)
				return
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, Mana.Spawn, PickupVariant.PICKUP_HEART)
ModRef:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, Mana.Spawn, PickupVariant.PICKUP_COIN)
ModRef:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, Mana.Spawn, PickupVariant.PICKUP_BOMB)
ModRef:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, Mana.Spawn, PickupVariant.PICKUP_KEY)

function Mana:SpawnBonus(entity)
	local MageNum = 0
	local GrimoireNum = 0
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = Isaac.GetPlayer(p)
		if Magic:IsMageCharacter(player) then
			if Magic:GetMadouRyoku(player) <= Magic:GetMadouJyougen(player) * 0.15 then
				MageNum = MageNum + 1
			end
		elseif player:HasCollectible(modCollectibleType.COLLECTIBLE_BLUE_GRIMOIRE) then
			GrimoireNum = GrimoireNum + 1
		end
	end
	if MageNum + GrimoireNum > 0 and Tools:IsIndividualEnemy(entity) then
		local chance = 5
		chance = chance + math.max(0, (GrimoireNum - 1)) * 2 + math.max(0, (MageNum - 1)) * 5
		if Tools:CanTriggerEvent(entity, chance) then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, modPickupVariant.PICKUP_MANA, 0, entity.Position, Vector(0, 0), entity)
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, Mana.SpawnBonus, nil)

function Mana:OnCollision(pickup, other, collides_other_first)
	if other.Type == EntityType.ENTITY_PLAYER and other.Variant == 0 then
		local player = other:ToPlayer()
		if (not Magic:IsMPFullyCharged(player, true)) 
		and (Magic:IsMageCharacter(player) or player:HasCollectible(modCollectibleType.COLLECTIBLE_BLUE_GRIMOIRE)) then
			if (not pickup.Touched) then
				Tools:PlayUniqueAnimation(pickup, "Collect")
				SFXManager():Play(SoundEffect.SOUND_BEEP)
				pickup:Remove()
				pickup.Touched = true

				player:SetColor(Color(1, 1, 1, 1, 0.5, 0.5, 1), 6, -1, true)
				local Recovery = Magic:GetRecovery(player)
				Magic:ModifyMadouRyoku(player, Recovery, false)
				return true
			else
				return true
			end
		else
			return false
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Mana.OnCollision, modPickupVariant.PICKUP_MANA)

return Mana