local Defensive = {}
local ModRef = tbom

local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths

local tbomCallbacks = tbom.tbomCallbacks
local MagicType = tbom.MagicType
local Magic = tbom.Magic

function Defensive:OnUse(spell_ID, rng, player, use_flags)
	Magic:CostDefaultMadouRyoku(player, spell_ID, false)
	Magic:IncreaseDefaultSpellCD(player, spell_ID)
end
ModRef:AddCallback(tbomCallbacks.TBOMC_USE_SPELL_BASE, Defensive.OnUse, MagicType.DEFENSIVE)

function Defensive:PostUpdate(spell_ID, player)
	Magic:ModifySpellCD(player, spell_ID, -2)
end
ModRef:AddCallback(tbomCallbacks.TBOMC_SPELL_UPDATE_BASE, Defensive.PostUpdate, MagicType.DEFENSIVE)

return Defensive