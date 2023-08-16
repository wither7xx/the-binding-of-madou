local GreenGrimoire = {}
local ModRef = tbom

local Common = tbom.Global.Common
local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths
local Translation = tbom.Global.Translation

local tbomCallbacks = tbom.tbomCallbacks
local modCollectibleType = tbom.modCollectibleType
local modPlayerType = tbom.modPlayerType
local MagicType = tbom.MagicType
local SpellType = tbom.SpellType
local SpellContent = tbom.SpellContent
local Magic = tbom.Magic

function GreenGrimoire:PostPlayerUpdate(player)
	if player:HasCollectible(modCollectibleType.COLLECTIBLE_GREEN_GRIMOIRE) then
		local player_type = player:GetPlayerType()
		local HUD = Game():GetHUD()
		local lang_fixed = Translation:FixLanguage(Options.Language)
		local text_name = {["en"] = "Magic power up! ", ["zh"] = "魔法强化",}
		if player_type == modPlayerType.PLAYER_ARLENADJA then
			local spell_ID = SpellType.SPELL_JUGEM
			if not Magic:IsSpellUnlocked(player, spell_ID) then
				HUD:ShowItemText(text_name[lang_fixed], Magic:GetUpgradeText(player, spell_ID, lang_fixed))
				Magic:UpgradeSpell(player, spell_ID)
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, GreenGrimoire.PostPlayerUpdate)

function GreenGrimoire:PostNPCDeath(npc)
	local PlayerModifier = 0
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = Game():GetPlayer(p)
		if Magic:IsMageCharacter(player) and (not player:HasCollectible(modCollectibleType.COLLECTIBLE_GREEN_GRIMOIRE)) then
			PlayerModifier = PlayerModifier + 1
		end
	end
	if PlayerModifier > 0 then
		local game = Game()
		local stage = game:GetLevel():GetAbsoluteStage()
		if stage > LevelStage.STAGE3_1 then
			local HardModeModifier = 0
			if game.Difficulty == Difficulty.DIFFICULTY_HARD or game.Difficulty == Difficulty.DIFFICULTY_GREEDIER then
				HardModeModifier = 20
			end
			local chance = Maths:Fix_Round(1 / (200 - HardModeModifier - ((PlayerModifier - 1) * 25)), 2)
			if (not npc:IsBoss()) and Tools:CanTriggerEvent(npc, chance) then
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, modCollectibleType.COLLECTIBLE_GREEN_GRIMOIRE, npc.Position, Vector(0, 0), nil)
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, GreenGrimoire.PostNPCDeath, nil)

--function GreenGrimoire:PreAddCollectible(collectible_type, rng, player)
--	Translation:ShowDefaultCollectibleText(collectible_type)
--end
--ModRef:AddCallback(tbomCallbacks.TBOMC_PRE_ADD_COLLECTIBLE, GreenGrimoire.PreAddCollectible, modCollectibleType.COLLECTIBLE_GREEN_GRIMOIRE)

return GreenGrimoire