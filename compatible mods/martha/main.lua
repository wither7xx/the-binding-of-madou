local CM_Martha = {}

tbom.CM_MarthaCard = {
	CARD_KREMLINFLU = Martha.Cards.KremlinFlu.ID
}

tbom.CM_MarthaPlayerType = {
	PLAYER_MARTHA = Martha.Players.Martha.ID,
	PLAYER_MARTHA_B = Martha.Players.MarthaB.ID,
}

tbom.CM_MarthaCollectibleType = {
	COLLECTIBLE_DEGENERACY = Martha.Collectibles.Degeneracy.ID,
}

local root_path = "compatible mods/martha/"

local modTrinketType = tbom.modTrinketType
CM_Martha.tbomTrinkets = {
	[modTrinketType.TRINKET_ANOTHER_CARTRIDE] = include(root_path .. "items/trinkets/tbom/t001_another_cartride/t001_another_cartride_main"),
}

local MarthaCard = tbom.CM_MarthaCard
CM_Martha.Cards = {
	[MarthaCard.CARD_KREMLINFLU] = include(root_path .. "items/pockets/k669_kremlin_flu/k669_kremlin_flu_main"),
}

local MarthaCollectibleType = tbom.CM_MarthaCollectibleType
CM_Martha.Collectibles = {
	[MarthaCollectibleType.COLLECTIBLE_DEGENERACY] = include(root_path .. "items/collectibles/c016_degeneracy/c016_degeneracy_main"),
}

local MarthaPlayerType = tbom.CM_MarthaPlayerType
CM_Martha.Characters = {
	[MarthaPlayerType.PLAYER_MARTHA] = include(root_path .. "characters/p001_martha/p001_martha_main"),
}

return CM_Martha