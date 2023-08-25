local PuyoHat = {}
local ModRef = tbom

local Common = tbom.Global.Common
local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths
local Translation = tbom.Global.Translation

local tbomCallbacks = tbom.tbomCallbacks
local modCollectibleType = tbom.modCollectibleType
local modEntityType = tbom.modEntityType
local modPickupVariant = tbom.modPickupVariant

local Puyo = include("scripts/monsters/e305_puyo/e305_puyo_api")
local Gel = include("scripts/items/pick ups/pick2401_gel/pick2401_gel_api")

local PuyoFlag = Puyo.PuyoFlag

local function HasPuyoHatPlayer()
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = Isaac.GetPlayer(p)
		if player:HasCollectible(modCollectibleType.COLLECTIBLE_PUYO_HAT, true) then
			return true
		end
	end
	return false
end

function PuyoHat:PostUpdate()
	if HasPuyoHatPlayer() then
		Puyo:AddPuyoChanceCache("PuyoHat", 15)
	else
		Puyo:ClearPuyoChanceCache("PuyoHat")
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_UPDATE, PuyoHat.PostUpdate)

function PuyoHat:PostPlayerUpdate(player)
	if player:HasCollectible(modCollectibleType.COLLECTIBLE_PUYO_HAT, true) then
		Gel:AddGelStatsMultiCache(player, "PuyoHat", 5)
	else
		Gel:ClearGelStatsMultiCache(player, "PuyoHat")
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PuyoHat.PostPlayerUpdate, 0)

function PuyoHat:PostNPCUpdate(npc)
	if Puyo:IsPuyo(npc) and HasPuyoHatPlayer() then
		Puyo:AddFlag(npc, PuyoFlag.FLAG_DO_NOT_SHOOT)
	end
end
ModRef:AddCallback(ModCallbacks.MC_NPC_UPDATE, PuyoHat.PostNPCUpdate, modEntityType.ENTITY_PUYO)

function PuyoHat:OnTakeDamage(took_dmg, dmg_amount, dmg_flags, dmg_source, dmg_cd_frames)
	local player = took_dmg:ToPlayer()
	if player and player:HasCollectible(modCollectibleType.COLLECTIBLE_PUYO_HAT) then
		if Puyo:IsPuyo(dmg_source.Entity) then
			return false
		end
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, PuyoHat.OnTakeDamage, EntityType.ENTITY_PLAYER)

return PuyoHat