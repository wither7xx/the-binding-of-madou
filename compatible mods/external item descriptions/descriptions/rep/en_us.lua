local CM_Desc_Texts_en_us = {}

local modCollectibleType = tbom.modCollectibleType
local modTrinketType = tbom.modTrinketType
local modPlayerType = tbom.modPlayerType

local lang = "en_us"

CM_Desc_Texts_en_us.Collectibles = {
	--[[
	[modCollectibleType.] = {
		Name = "",
		Description = "",
	},
	]]
	[modCollectibleType.COLLECTIBLE_BLUE_GRIMOIRE] = {
		Name = "Blue Grimoire",
		Description = "While held: Hearts, Coins, bombs and keys have a chance to be replaced into mana pickups.#On use, consumes 5 mp and grants a random spell effect.#{{Player"..modPlayerType.PLAYER_ARLENADJA.."}}Arle can held 8 different spells.",
		bookOfVirtuesWisps = "Fire: Fires explosive tears; Ice: Fires slow tears; Thunder: Fires laser tears#{{Player"..modPlayerType.PLAYER_ARLENADJA.."}}Only valid for：Healing: 20% chance for enemy to drop heart on kill; Diacute: Adds a grey normal wisp; Bayoen: 7.5% chance for Mark tears; Revia: Immune to projectiles.",
		bookOfBelialBuffs = "x130% magic damage.",
	},
	[modCollectibleType.COLLECTIBLE_PUYO_HAT] = {
		Name = "Puyo Hat",
		Description = "Puyos will no longer fire projectiles. Touching puyos will no longer hurt the player. #+15% chance to spawn puyo.",
	},
	[modCollectibleType.COLLECTIBLE_WORMHOLE_APPLE] = {
		Name = "Wormhole Apple",
		Description = "On use, the player will participate in a time-limited quiz. Upon completing all the questions, a reward will be granted. #The quality of the reward gets higher the more questions the player answers correctly within the specified time. ",
	},
	[modCollectibleType.COLLECTIBLE_HEART_SHAPED_COOKIE] = {
		Name = "Heart Shaped Cookie",
		Description = "Touching enemies will no longer hurt the player. #As Tainted Magdalene, the player has a 50% chance to trigger this effect.#!!! Does not work on Dark Esau.",
	},
	[modCollectibleType.COLLECTIBLE_GREEN_GRIMOIRE] = {
		Name = "Green Grimoire",
		Description = "{{Player"..modPlayerType.PLAYER_ARLENADJA.."}}Unlocks Jugem, the forbidden spell of Arle.",
	},
}

CM_Desc_Texts_en_us.Trinkets = {
	[modTrinketType.TRINKET_ANOTHER_CARTRIDE] = {
		Name = "Another Cartride",
		Description = "TBA",
	},
}

CM_Desc_Texts_en_us.Birthrights = {
	[modPlayerType.PLAYER_ARLENADJA] = {
		Description = "Increases the amount of exp points by up to 300% if enemies are quickly killed when entering a new room.",
		PlayerName = "Arle Nadja",
	},
}

return CM_Desc_Texts_en_us
