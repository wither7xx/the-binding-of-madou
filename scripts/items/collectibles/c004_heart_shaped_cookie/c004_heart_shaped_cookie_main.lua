local Main = {}
local HeartShapedCookie = include("scripts/items/collectibles/c004_heart_shaped_cookie/c004_heart_shaped_cookie_api")
local ModRef = tbom

local Common = tbom.Global.Common
local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths
local Translation = tbom.Global.Translation

local tbomCallbacks = tbom.tbomCallbacks
local modCollectibleType = tbom.modCollectibleType

HeartShapedCookie:AddSelfHurtingCharacter(PlayerType.PLAYER_MAGDALENE_B, 50)

function Main:OnTakeDamage(took_dmg, dmg_amount, dmg_flags, dmg_source, dmg_cd_frames)
	local player = took_dmg:ToPlayer()
	if player and player:HasCollectible(modCollectibleType.COLLECTIBLE_HEART_SHAPED_COOKIE) then
		local source_entity = dmg_source.Entity
		if dmg_flags & (DamageFlag.DAMAGE_FIRE | DamageFlag.DAMAGE_LASER) == 0 and source_entity and source_entity:IsEnemy() then
			if source_entity.Type ~= EntityType.ENTITY_DARK_ESAU then
				local player_type = player:GetPlayerType()
				local chance = Maths:RandomInt(100, nil, false, true)
				if chance > HeartShapedCookie:GetHurtChance(player_type) then
					Tools:Immunity_AddImmuneEffect(player, 6, false)
					return false
				end
			end
		end
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, Main.OnTakeDamage, EntityType.ENTITY_PLAYER)

function Main:PreAddCollectible(collectible_type, rng, player)
	local lang = Translation:FixLanguage()
	local HeartShapedCookieName = Translation:GetDefaultCollectibleConfigText(collectible_type).Name
	local HeartShapedCookieDesc = {}
	HeartShapedCookieDesc[PlayerType.PLAYER_MAGDALENE_B] = {
		["zh"] = "温柔相拥",
		["en"] = "Soft & cuddly",
	}
	HeartShapedCookieDesc[PlayerType.PLAYER_JACOB_B] = {
		["zh"] = "你的爱还不够真诚...",
		["en"] = "Your love is not sincere enough...",
	}
	HeartShapedCookieDesc[PlayerType.PLAYER_JACOB2_B] = HeartShapedCookieDesc[PlayerType.PLAYER_JACOB_B]
	local player_type = player:GetPlayerType()
	if HeartShapedCookieDesc[player_type] ~= nil then
		local HUD = Game():GetHUD()
		HUD:ShowItemText(HeartShapedCookieName, HeartShapedCookieDesc[player_type][lang] or HeartShapedCookieDesc[player_type]["en"])
	end
end
ModRef:AddCallback(tbomCallbacks.TBOMC_PRE_ADD_COLLECTIBLE, Main.PreAddCollectible, modCollectibleType.COLLECTIBLE_HEART_SHAPED_COOKIE)

return Main