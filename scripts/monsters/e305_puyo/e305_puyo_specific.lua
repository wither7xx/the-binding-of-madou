local PuyoSpecific = {}

local Common = tbom.Global.Common
local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths
local Translation = tbom.Global.Translation

local Puyo = include("scripts/monsters/e305_puyo/e305_puyo_core").__index
local PuyoVariant = tbom.PuyoVariant
local PuyoFlag = Puyo.PuyoFlag

PuyoSpecific[PuyoVariant.PUYO_PURPLE] = function (npc)
	if npc.FrameCount == 1 then
		Puyo:AddFlag(npc, PuyoFlag.FLAG_IMMUNE_TO_ICE)
	end
end

PuyoSpecific[PuyoVariant.PUYO_RED] = function (npc)
	if npc.FrameCount == 1 then
		Puyo:AddFlag(npc, PuyoFlag.FLAG_CAN_STACK)
	end
end

PuyoSpecific[PuyoVariant.PUYO_BLUE] = function (npc)
	if npc.FrameCount == 1 then
		Puyo:AddFlag(npc, PuyoFlag.FLAG_IMMUNE_TO_ICE)
		Puyo:AddFlag(npc, PuyoFlag.FLAG_CAN_STACK)
	end
	local amplitude = 3.6		--Õñ·ù
	local angular_freq = 26 * 0.004 * (2 * math.pi)	--½ÇÆµÂÊ
	local offset_Y = amplitude * math.cos(math.deg(angular_freq * npc.FrameCount))
	npc.SpriteOffset = Vector(0, offset_Y)
	npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
end

return PuyoSpecific