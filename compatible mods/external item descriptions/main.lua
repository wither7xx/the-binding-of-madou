local CM_EID = {}
local ModRef = tbom

local Tools = tbom.Global.Tools
local modCollectibleType = tbom.modCollectibleType
local modPlayerType = tbom.modPlayerType

local CharacterIcon = Sprite()
CharacterIcon:Load("gfx/compatible mods/eid/character icon.anm2", true)

EID:addIcon("Player"..modPlayerType.PLAYER_ARLENADJA, "Arle Nadja", 0, 12, 12, -1, 1, CharacterIcon)

local desc_root = "compatible mods/external item descriptions/descriptions/rep/"
CM_EID.Descriptions = {
	["zh_cn"] = include(desc_root .. "zh_cn"),
	["en_us"] = include(desc_root .. "en_us"),
}

do
	local Descriptions = CM_EID.Descriptions
	for lang, desc in pairs(Descriptions) do
		local OrigDescList = EID.descriptions[lang]
		if OrigDescList then
			if desc.Collectibles then
				for id, collectible in pairs(desc.Collectibles) do
					EID:addCollectible(id, collectible.Description, collectible.Name, lang)
					if collectible.bookOfVirtuesWisps and OrigDescList.bookOfVirtuesWisps then
						OrigDescList.bookOfVirtuesWisps[id] = collectible.bookOfVirtuesWisps
					end
					if collectible.bookOfBelialBuffs and OrigDescList.bookOfBelialBuffs then
						OrigDescList.bookOfBelialBuffs[id] = collectible.bookOfBelialBuffs
					end
				end
			end
			if desc.Trinkets then
				for id, trinket in pairs(desc.Trinkets) do
					EID:addTrinket(id, trinket.Description, trinket.Name, lang)
				end
			end
			if desc.Birthrights then
				for id, birthright in pairs(desc.Birthrights) do
					EID:addBirthright(id, birthright.Description, birthright.PlayerName, lang)
				end
			end
		end
	end
end

function CM_EID:OnRender(_)
	if EID.GameRenderCount % 30 ~= 0 then
		return
	end
	local NumPlayers = Game():GetNumPlayers()
	local MPIconExists = false
	local EsauMPIconExists = false
	for p = 0, NumPlayers - 1 do
		local player = Game():GetPlayer(p)
		local UserIdx = Tools:GetUserIdx(player)
		local player_type = player:GetPlayerType()
		if UserIdx == 0 and player:HasCollectible(modCollectibleType.COLLECTIBLE_BLUE_GRIMOIRE) then
			MPIconExists = true
			if player_type == PlayerType.PLAYER_ESAU then
				EsauMPIconExists = true
			end
		end
	end
	if MPIconExists then
		EID:addTextPosModifier("MPIcon", Vector(0,18))
		if EsauMPIconExists then
			EID:addTextPosModifier("Esau MPIcon", Vector(0,12))
		else
			EID:removeTextPosModifier("Esau MPIcon")
		end
	else
		EID:removeTextPosModifier("MPIcon")
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_RENDER, CM_EID.OnRender)

return CM_EID