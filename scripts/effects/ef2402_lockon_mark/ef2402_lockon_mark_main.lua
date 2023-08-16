local LockonMark = {}
local ModRef = tbom

local modEffectVariant = tbom.modEffectVariant

function LockonMark:PostInit(effect)
	effect.DepthOffset = 999999
end
ModRef:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, LockonMark.PostInit, modEffectVariant.LOCKON_MARK)

function LockonMark:Remove(isContinued)
	if not isContinued then
		for i, entity in pairs(Isaac.GetRoomEntities()) do
			if entity.Type == EntityType.ENTITY_EFFECT and entity.Variant == modEffectVariant.LOCKON_MARK then
				entity:Remove()
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, LockonMark.Remove)

return LockonMark