local Revia = {}
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

function Revia:PostSpellInit(spell_ID, player)
	Magic:Spell_AddAttribute(player, spell_ID, "BarrierNum", 0)
end
ModRef:AddCallback(tbomCallbacks.TBOMC_POST_SPELL_INIT, Revia.PostSpellInit, SpellType.SPELL_REVIA)

function Revia:OnUse(spell_ID, rng, player, use_flag)
	Magic:Spell_SetAttribute(player, spell_ID, "BarrierNum", 0)

	local tmp_effects = player:GetEffects()
	local Diacute_OrbsNum = (Magic:Spell_GetAttribute(player, SpellType.SPELL_DIACUTE, "OrbsNum") or 0)

	if tmp_effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_HOLY_MANTLE) == 0 then
		tmp_effects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE, true, 1 + math.floor(Diacute_OrbsNum / 2))
		Magic:Spell_ModifyAttribute(player, spell_ID, "BarrierNum", 1 + math.floor(Diacute_OrbsNum / 2))
	else
		player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, UseFlag.USE_NOANIM)
		tmp_effects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE, true, math.floor(Diacute_OrbsNum / 2))
		Magic:Spell_ModifyAttribute(player, spell_ID, "BarrierNum", math.floor(Diacute_OrbsNum / 2))
	end
	if Tools:CanAddWisp(player, use_flag) then
		player:AddWisp(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, player.Position)
	end
	return true
end
ModRef:AddCallback(tbomCallbacks.TBOMC_USE_SPELL, Revia.OnUse, SpellType.SPELL_REVIA)

local PrePlayerCollision_DONE = false

function Revia:PostUpdate(spell_ID, player)
	local tmp_effects = player:GetEffects()
	if not PrePlayerCollision_DONE then
		PrePlayerCollision_DONE = true
		local BarrierNum = (Magic:Spell_GetAttribute(player, spell_ID, "BarrierNum") or 0)
		if BarrierNum > tmp_effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_HOLY_MANTLE) then
			for _, entity in pairs(Isaac.GetRoomEntities()) do
				if entity:IsActiveEnemy() and entity:IsVulnerableEnemy() and (not EntityRef(entity).IsFriendly) then
					entity:TakeDamage(30 + 5 * player.Damage, 0, EntityRef(player), 0)
				end
			end
			SFXManager():Play(SoundEffect.SOUND_DIVINE_INTERVENTION)
			Game():ShakeScreen(10)
			Magic:Spell_ModifyAttribute(player, spell_ID, "BarrierNum", -1)
		end
		PrePlayerCollision_DONE = false
	end
end
ModRef:AddCallback(tbomCallbacks.TBOMC_SPELL_UPDATE, Revia.PostUpdate, SpellType.SPELL_REVIA)

function Revia:PostNewRoom()
	local spell_ID = SpellType.SPELL_REVIA
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = Game():GetPlayer(p)
		Magic:Spell_SetAttribute(player, spell_ID, "BarrierNum", 0)
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Revia.PostNewRoom)

return Revia