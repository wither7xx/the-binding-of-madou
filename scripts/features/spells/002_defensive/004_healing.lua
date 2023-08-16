local Healing = {}
local ModRef = tbom

local Maths = tbom.Global.Maths
local Tools = tbom.Global.Tools

local tbomCallbacks = tbom.tbomCallbacks
local modCollectibleType = tbom.modCollectibleType
local MagicType = tbom.MagicType
local SpellType = tbom.SpellType
local SpellContent = tbom.SpellContent
local Magic = tbom.Magic
local modSoundEffect = tbom.modSoundEffect

function Healing:OnUse(spell_ID, rng, player, use_flag)
	local SFX = SFXManager()
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player_p = Isaac.GetPlayer(p)
		if Tools:IsSameEntity(player, player_p) then
			if player_p:GetHearts() < player_p:GetEffectiveMaxHearts() then
				player_p:AddHearts(2)
			else
				player_p:AddSoulHearts(1)
			end
		else
			player_p:AddHearts(2)
		end
	end
	SFX:Play(SoundEffect.SOUND_VAMP_GULP)

	local Diacute_OrbsNum = (Magic:Spell_GetAttribute(player, SpellType.SPELL_DIACUTE, "OrbsNum") or 0)
	Magic:ModifySpellCD(player, spell_ID, -(Diacute_OrbsNum * 5 * 60))

	if Tools:CanAddWisp(player, use_flag) then
		player:AddWisp(CollectibleType.COLLECTIBLE_YUM_HEART, player.Position)
	end
	return true
end
ModRef:AddCallback(tbomCallbacks.TBOMC_USE_SPELL, Healing.OnUse, SpellType.SPELL_HEALING)

return Healing