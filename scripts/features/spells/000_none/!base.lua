local BaseNone = {}
local ModRef = tbom

local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths

local tbomCallbacks = tbom.tbomCallbacks
local MagicType = tbom.MagicType
local Magic = tbom.Magic

function BaseNone:OnUse(spell_ID, rng, player, use_flags)
	Magic:CostDefaultMadouRyoku(player, spell_ID, false)
end
ModRef:AddCallback(tbomCallbacks.TBOMC_USE_SPELL_BASE, BaseNone.OnUse, MagicType.NONE)

return BaseNone