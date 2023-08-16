local Special = {}
local ModRef = tbom

local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths

local tbomCallbacks = tbom.tbomCallbacks
local MagicType = tbom.MagicType
local Magic = tbom.Magic

function Special:OnUse(spell_ID, rng, player, use_flags)	--特殊法术不对魔导力进行统一操作
	if Magic:IsSpellRecharged(player, spell_ID, true) then
		Magic:IncreaseDefaultSpellCD(player, spell_ID)
	end
end
ModRef:AddCallback(tbomCallbacks.TBOMC_USE_SPELL_BASE, Special.OnUse, MagicType.SPECIAL)

function Special:PostUpdate(spell_ID, player)
	Magic:ModifySpellCD(player, spell_ID, -2)
end
ModRef:AddCallback(tbomCallbacks.TBOMC_SPELL_UPDATE_BASE, Special.PostUpdate, MagicType.SPECIAL)

return Special