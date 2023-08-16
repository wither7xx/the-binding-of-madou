local Translation = {}
local ModRef = tbom

local Common = tbom.Global.Common
local Tools = tbom.Global.Tools

local Fonts = tbom.Fonts
local tbomCallbacks = tbom.tbomCallbacks
local modPlayerType = tbom.modPlayerType
local modCollectibleType = tbom.modCollectibleType
local modTrinketType = tbom.modTrinketType
local modCard = tbom.modCard
local modEffectVariant = tbom.modEffectVariant
local modCostume = tbom.modCostume
local MagicType = tbom.MagicType
local SpellType = tbom.SpellType
local SpellContent = tbom.SpellContent
local Magic = tbom.Magic
local LevelExp = tbom.LevelExp
local AwardFlag = tbom.AwardFlag

local BirthrightName = {
	["zh"] = "长子名分",
	["en"] = "Birthright",
}

local BirthrightDesc = {
	["zh"] = {
		[modPlayerType.PLAYER_ARLENADJA] = "速攻考试",
	},
	["en"] = {
		[modPlayerType.PLAYER_ARLENADJA] = "Flash shoot exam",
	},
}

local CollectibleConfigText = {
	["zh"] = {
		--[modCollectibleType.] = {Name = "", Desc = "",},
		[modCollectibleType.COLLECTIBLE_BLUE_GRIMOIRE] = {Name = "蓝色魔导书", Desc = "开始学习魔法吧！",},
		[modCollectibleType.COLLECTIBLE_PUYO_HAT] = {Name = "噗哟帽", Desc = "噗哟变得友好",},
		[modCollectibleType.COLLECTIBLE_WORMHOLE_APPLE] = {Name = "虫洞苹果", Desc = "化身学霸！",},
		[modCollectibleType.COLLECTIBLE_HEART_SHAPED_COOKIE] = {Name = "心形饼干", Desc = "相亲相爱一家人",},

		[modCollectibleType.COLLECTIBLE_GREEN_GRIMOIRE] = {Name = "绿色魔导书", Desc = "魔法强化！",},
	},
	["en"] = {},
}

local TrinketConfigText = {
	["zh"] = {
		--[modTrinketType.] = {Name = "", Desc = "",},
		[modTrinketType.TRINKET_ANOTHER_CARTRIDE] = {Name = "另一张游戏卡带", Desc = "按E使用外星能力",},
	},
	["en"] = {},
}

local CardConfigText = {
	["zh"] = {
		--[modCard.] = {Name = "", Desc = "",},
	},
	["en"] = {},
}

local function GetPlayerTranslationData(player)
	local data = Tools:GetPlayerData(player)
	data.TranslationData = data.TranslationData or {}
	return data.TranslationData
end

function Translation:FixLanguage(lang)
	local lang_fixed = lang or Options.Language
	if lang_fixed ~= "en" and lang_fixed ~= "zh" then
		lang_fixed = "en"
	end
	return lang_fixed
end

function Translation:GetDefaultCollectibleConfigText(collectible_type, lang)
	local lang_fixed = Translation:FixLanguage(lang)
	if CollectibleConfigText[lang_fixed] and CollectibleConfigText[lang_fixed][collectible_type] then
		return CollectibleConfigText[lang_fixed][collectible_type]
	end
	local item_config_item = Isaac.GetItemConfig():GetCollectible(collectible_type)
	if item_config_item then
		return {Name = item_config_item.Name, Desc = item_config_item.Description,}
	end
	return {Name = "", Desc = "",}
end

function Translation:GetDefaultTrinketConfigText(trinket_type, lang)
	local lang_fixed = Translation:FixLanguage(lang)
	if TrinketConfigText[lang_fixed] and TrinketConfigText[lang_fixed][trinket_type] then
		return TrinketConfigText[lang_fixed][trinket_type]
	end
	local item_config_item = Isaac.GetItemConfig():GetTrinket(trinket_type)
	if item_config_item then
		return {Name = item_config_item.Name, Desc = item_config_item.Description,}
	end
	return {Name = "", Desc = "",}
end

function Translation:GetDefaultCardConfigText(card, lang)
	local lang_fixed = Translation:FixLanguage(lang)
	if CardConfigText[lang_fixed] and CardConfigText[lang_fixed][card] then
		return CardConfigText[lang_fixed][card]
	end
	local item_config_card = Isaac.GetItemConfig():GetCard(card)
	if item_config_card then
		return {Name = item_config_card.Name, Desc = item_config_card.Description,}
	end
	return {Name = "", Desc = "",}
end

function Translation:ShowDefaultCollectibleText(collectible_type)
	local HUD = Game():GetHUD()
	local CollectibleConfigText = Translation:GetDefaultCollectibleConfigText(collectible_type)
	if CollectibleConfigText then
		HUD:ShowItemText(CollectibleConfigText.Name, CollectibleConfigText.Desc)
	end
end

function Translation:ShowDefaultTrinketText(trinket_type)
	local HUD = Game():GetHUD()
	local TrinketConfigText = Translation:GetDefaultTrinketConfigText(trinket_type)
	if TrinketConfigText then
		HUD:ShowItemText(TrinketConfigText.Name, TrinketConfigText.Desc)
	end
end

function Translation:ShowDefaultCardText(card)
	local HUD = Game():GetHUD()
	local CardConfigText = Translation:GetDefaultCardConfigText(card)
	if CardConfigText then
		HUD:ShowItemText(CardConfigText.Name, CardConfigText.Desc)
	end
end

local ItemTranslation_DONE = false

function Translation:CheckQueuedItem()
	local flag = false
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = Isaac.GetPlayer(p)
		local data = GetPlayerTranslationData(player)
		if not (player:IsItemQueueEmpty() and data.QueuedCard == nil) then	
			flag = true
			break
		end
	end
	if not flag then
		ItemTranslation_DONE = false
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_UPDATE, Translation.CheckQueuedItem)

function Translation:PreAddItem_RunCallback(player)
	local lang_fixed = Translation:FixLanguage(Options.Language)
	local data = GetPlayerTranslationData(player)
	local HUD = Game():GetHUD()
	if not player:IsItemQueueEmpty() then
		local item_config_item = player.QueuedItem.Item
		if item_config_item then
			local item_ID = item_config_item.ID
			if item_config_item:IsCollectible() then
				if not ItemTranslation_DONE then
					local collectible_type = item_ID
					if collectible_type == CollectibleType.COLLECTIBLE_BIRTHRIGHT then
						local player_type = player:GetPlayerType()
						if BirthrightName[lang_fixed] and BirthrightDesc[lang_fixed] and BirthrightDesc[lang_fixed][player_type] then
							HUD:ShowItemText(BirthrightName[lang_fixed], BirthrightDesc[lang_fixed][player_type])
						end
					end
					if CollectibleConfigText[lang_fixed] and CollectibleConfigText[lang_fixed][collectible_type] then
						HUD:ShowItemText(CollectibleConfigText[lang_fixed][collectible_type].Name, CollectibleConfigText[lang_fixed][collectible_type].Desc)
					end
					Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_PRE_ADD_COLLECTIBLE, collectible_type, collectible_type, player:GetCollectibleRNG(collectible_type), player)
					ItemTranslation_DONE = true
				end
			elseif item_config_item:IsTrinket() then
				if not ItemTranslation_DONE then
					local trinket_type = item_ID
					if TrinketConfigText[lang_fixed][trinket_type] ~= nil then
						HUD:ShowItemText(TrinketConfigText[lang_fixed][trinket_type].Name, TrinketConfigText[lang_fixed][trinket_type].Desc)
					end
					Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_PRE_ADD_TRINKET, trinket_type, trinket_type, player:GetTrinketRNG(trinket_type), player)
					ItemTranslation_DONE = true
				end
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Translation.PreAddItem_RunCallback)

function Translation:PrePickupCollision(pickup, other, collides_other_first)
	local player = other:ToPlayer()
	if player and pickup.Variant == PickupVariant.PICKUP_TAROTCARD then
		local data = GetPlayerTranslationData(player)
		if player:IsItemQueueEmpty() then
			data.QueuedCard = pickup
		end
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, Translation.PrePickupCollision)

function Translation:PreAddCard_RunCallback(player)
	local lang_fixed = Translation:FixLanguage(Options.Language)
	local data = GetPlayerTranslationData(player)
	local HUD = Game():GetHUD()
	if data.QueuedCard then
		if (not data.QueuedCard:Exists()) or data.QueuedCard:IsDead() then
			local card = data.QueuedCard.SubType
			for slot_ID = 0, 3 do
				local current_card = player:GetCard(slot_ID)
				if current_card == card then
					if not ItemTranslation_DONE then
						if CardConfigText[lang_fixed][card] ~= nil then
							HUD:ShowItemText(CardConfigText[lang_fixed][card].Name, CardConfigText[lang_fixed][card].Desc)
						end
						Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_PRE_ADD_CARD, card, card, player)
						ItemTranslation_DONE = true
						--return
					end
				end
			end
		end
		data.QueuedCard = nil
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Translation.PreAddCard_RunCallback)

function Translation:RenderFloatingText(text, pos, kcolor, dir, timeout, lang)
	local text_table = {}
	if text == nil then
		text_table = {"",}
	elseif type(text) == "number" or type(text) == "string" then
		text_table = {tostring(text),}
	elseif type(text) == "table" then
		text_table = text
	end
	kcolor = kcolor or KColor(1, 1, 1, 1)
	dir = dir or Vector(0, -1.5)
	timeout = timeout or 45
	timeout = math.max(1, timeout)
	lang = Translation:FixLanguage(lang)
	local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, modEffectVariant.BLANK_ANIM, 0, pos, dir, nil):ToEffect()
	effect.LifeSpan = timeout
	effect.Timeout = timeout
	
	local data = Tools:GetEffectData(effect)
	data.FloatingTextData = data.FloatingTextData or {}
	data.FloatingTextData.Text = text_table
	data.FloatingTextData.Language = lang
	data.FloatingTextData.KColor = kcolor
end

function Translation:FloatingText_OnRender(effect, offset)
	local data = Tools:GetEffectData(effect)
	if data.FloatingTextData and effect.Timeout >= 0 then
		local font = Fonts[Translation:FixLanguage(data.FloatingTextData.Language)] or Fonts["en"]
		local text_table = data.FloatingTextData.Text or {}
		local pos = Isaac.WorldToScreen(effect.Position)
		local kcolor = data.FloatingTextData.KColor
		local init_alpha = kcolor.Alpha
		if effect.Timeout < effect.LifeSpan * 0.5 then
			kcolor.Alpha = init_alpha * (effect.Timeout / (effect.LifeSpan * 0.5))
		end
		for i = 1, #text_table do
			font:DrawStringUTF8(text_table[i], pos.X - 128, pos.Y - 45 - #text_table * 15 + i * 15, kcolor, 256, true)
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, Translation.FloatingText_OnRender, modEffectVariant.BLANK_ANIM)

return Translation