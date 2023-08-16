local MeteorShower = {}
local ModRef = tbom

local Common = tbom.Global.Common
local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths
local Translation = tbom.Global.Translation

local Fonts = tbom.Fonts
local modPlayerType = tbom.modPlayerType
local SpellContent = tbom.SpellContent
local MagicType = tbom.MagicType
local SpellType = tbom.SpellType
local Magic = tbom.Magic
local tbomCallbacks = tbom.tbomCallbacks
local modCollectibleType = tbom.modCollectibleType
local modChallenge = tbom.modChallenge

function MeteorShower:PostPlayerInit(player)
	if player and player.Variant == 0 then
		if Isaac.GetChallenge() == modChallenge.CHALLENGE_METEOR_SHOWER then
			player:ChangePlayerType(modPlayerType.PLAYER_ARLENADJA)
		end
	end
end
tbom:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_INIT, CallbackPriority.EARLY, MeteorShower.PostPlayerInit)

function MeteorShower:CheckPlayerData(player)
	if Isaac.GetChallenge() == modChallenge.CHALLENGE_METEOR_SHOWER then
		if player:GetPlayerType() == modPlayerType.PLAYER_ARLENADJA then
			Magic:ForbidSpell(player, SpellType.SPELL_FIRE)
			Magic:ForbidSpell(player, SpellType.SPELL_ICE_STORM)
			Magic:ForbidSpell(player, SpellType.SPELL_THUNDER)
			Magic:ForbidSpell(player, SpellType.SPELL_HEALING)
			Magic:ForbidSpell(player, SpellType.SPELL_DIACUTE)
			Magic:ForbidSpell(player, SpellType.SPELL_BAYOEN)
			Magic:ForbidSpell(player, SpellType.SPELL_REVIA)
			if not Magic:HasInfiniteMP(player) then
				Magic:EnableInfiniteMP(player)
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, MeteorShower.CheckPlayerData, 0)

function MeteorShower:Reset(is_continued)
	if not is_continued then
		if Isaac.GetChallenge() == modChallenge.CHALLENGE_METEOR_SHOWER then
			local player = Isaac.GetPlayer(0)
			local pool = Game():GetItemPool()
			player:AddCollectible(modCollectibleType.COLLECTIBLE_GREEN_GRIMOIRE)
			pool:RemoveCollectible(CollectibleType.COLLECTIBLE_HOST_HAT)
			pool:RemoveCollectible(CollectibleType.COLLECTIBLE_PYROMANIAC)
			pool:RemoveCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS)
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, MeteorShower.Reset)

return MeteorShower