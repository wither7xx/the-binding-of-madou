local Helper = {}
local ModRef = tbom

local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths

local tbomCallbacks = tbom.tbomCallbacks
local MagicType = tbom.MagicType
local Magic = tbom.Magic

function Helper:OnUse(spell_ID, rng, player, use_flags)

end
ModRef:AddCallback(tbomCallbacks.TBOMC_USE_SPELL_BASE, Helper.OnUse, MagicType.HELPER)

function Helper:PostUpdate(spell_ID, player)
	Magic:ModifySpellCD(player, spell_ID, -2)
end
ModRef:AddCallback(tbomCallbacks.TBOMC_SPELL_UPDATE_BASE, Helper.PostUpdate, MagicType.HELPER)

return Helper