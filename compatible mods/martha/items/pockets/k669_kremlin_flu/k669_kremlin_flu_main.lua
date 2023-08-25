local CM_KremlinFlu = {}
local ModRef = tbom

local modEntityType = tbom.modEntityType
--local Puyo = tbom.Monsters[modEntityType.ENTITY_PUYO]
local Puyo = include("scripts/monsters/e305_puyo/e305_puyo_api")
local PuyoFlag = Puyo.PuyoFlag

local Flu = Martha.Cards.KremlinFlu

function CM_KremlinFlu:PuyoUpdate(npc)
	if Puyo:IsPuyo(npc) then
		if Puyo:HasFlag(npc, PuyoFlag.FLAG_IMMUNE_TO_ICE) then
			local freezeTime = 90
			local enemyData = Flu:GetTempEntityData(npc, true)
			if enemyData.FreezeTime then
				enemyData.FreezeTime = math.min(freezeTime / 2, enemyData.FreezeTime)
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_NPC_UPDATE, CM_KremlinFlu.PuyoUpdate, modEntityType.ENTITY_PUYO)

return CM_KremlinFlu