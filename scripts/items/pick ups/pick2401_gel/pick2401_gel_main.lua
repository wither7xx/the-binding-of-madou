local Main = {}
local Gel = include("scripts/items/pick ups/pick2401_gel/pick2401_gel_api")
local ModRef = tbom

local Common = tbom.Global.Common
local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths
local Translation = tbom.Global.Translation

local modPickupVariant = tbom.modPickupVariant
local modSoundEffect = tbom.modSoundEffect
local GelSubType = tbom.GelSubType
local tbomCallbacks = tbom.tbomCallbacks

local GelNumIndexList = Gel.GelNumIndexList
local GelCacheFlagList = Gel.GelCacheFlagList

function Main:PostPlayerUpdate(player)
	Gel:PlayerDataInit(player)
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Main.PostPlayerUpdate, 0)

function Main:PrePickupCollision(pickup, other, collides_other_first)
	if other.Type == 1 and other.Variant == 0 then
		local player = other:ToPlayer()
		if not pickup.Touched then
			local gel_subtype = pickup.SubType
			Gel:ModifyGelNum(player, gel_subtype, 1)
			local caflag = GelCacheFlagList[gel_subtype]
			--print(caflag)
			if caflag then
				player:AddCacheFlags(caflag)
				player:EvaluateItems()
			end
			SFXManager():Play(Gel:GetGelSFX())
			Tools:PlayUniqueAnimation(pickup, "Collect")
			pickup:Remove()
			pickup.Touched = true
			return true
		else
			return true
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Main.PrePickupCollision, modPickupVariant.PICKUP_GEL)

function Main:OnTakeDamage(took_dmg, dmg_amount, dmg_flags, dmg_source, dmg_cd_frames)
	local player = took_dmg:ToPlayer()
	if player and (not Tools:IsSelfDamage(dmg_flags)) then
		if Gel:GetGelNum(player, GelSubType.GEL_GREEN) > 0 then
			Gel:ModifyGelNum(player, GelSubType.GEL_GREEN, -1)
			local difficulty = Game().Difficulty
			if difficulty == Difficulty.DIFFICULTY_NORMAL or difficulty == Difficulty.DIFFICULTY_GREED then
				SFXManager():Play(modSoundEffect.SOUND_GREEN_GEL_HIT)
			end
		else
			for gel_subtype, caflag in pairs(GelCacheFlagList) do
				Gel:ModifyGelNum(player, gel_subtype, -1)
				player:AddCacheFlags(caflag)
				player:EvaluateItems()
			end
		end
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, Main.OnTakeDamage, EntityType.ENTITY_PLAYER)

function Main:EvaluateCache(player, caflag)
	local gel_stats_multi = Gel:GetGelStatsMulti(player)
	--local gel_stats_multi = 1
	--if player:HasCollectible(tbom.modCollectibleType.COLLECTIBLE_PUYO_HAT, true) then
	--	gel_stats_multi = 5
	--end
	--print(gel_stats_multi)
	if caflag == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage + 0.1 * Gel:GetGelNum(player, GelSubType.GEL_RED) * gel_stats_multi
		--print("NoMulti: "..(0.1 * Gel:GetGelNum(player, GelSubType.GEL_RED)))
		--print("Multi: "..(0.1 * Gel:GetGelNum(player, GelSubType.GEL_RED) * gel_stats_multi))
		--print("Collected")
	end
	if caflag == CacheFlag.CACHE_FIREDELAY then
		player.MaxFireDelay = (30 / (30 / (player.MaxFireDelay + 1) + 0.05 * Gel:GetGelNum(player, GelSubType.GEL_BLUE) * gel_stats_multi) - 1)
	end
	if caflag == CacheFlag.CACHE_RANGE then
		player.TearRange = player.TearRange + 10 * Gel:GetGelNum(player, GelSubType.GEL_YELLOW) * gel_stats_multi
	end
	if caflag == CacheFlag.CACHE_SPEED then
		player.MoveSpeed = player.MoveSpeed + 0.02 * Gel:GetGelNum(player, GelSubType.GEL_YELLOW) * gel_stats_multi
	end
	if caflag == CacheFlag.CACHE_LUCK then
		player.Luck = player.Luck + 0.1 * Gel:GetGelNum(player, GelSubType.GEL_PURPLE) * gel_stats_multi
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, Main.EvaluateCache)
--[[
function Main:OnRender(player, offset)
	--µ÷ÊÔ×¨ÓÃ
	local font = tbom.Fonts[Options.Language] or tbom.Fonts["en"]
	local texts = {
		[1] = "Stage: ".. tostring(Game():GetLevel():GetStage()),
		[2] = "Puyo Combo: " .. tostring(Tools:GameData_GetAttribute("PuyoComboInCurrentRoom"))
	}
	local pos = Tools:GetEntityRenderScreenPos(player)
	for i = 1, #texts do
		font:DrawStringUTF8(texts[i], pos.X - 200, pos.Y - 5 * #texts + i * 15, KColor(1, 1, 1, 0.8), 400, true)
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, Main.OnRender)
]]
return Gel