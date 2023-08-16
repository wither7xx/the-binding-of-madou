local BlueGrimoire = {}
local ModRef = tbom

local Common = tbom.Global.Common
local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths
local Translation = tbom.Global.Translation

local tbomCallbacks = tbom.tbomCallbacks
local modCollectibleType = tbom.modCollectibleType
local MagicType = tbom.MagicType
local SpellType = tbom.SpellType
local SpellContent = tbom.SpellContent
local Magic = tbom.Magic

function BlueGrimoire:OnUse(collectible_type, rng, player, use_flags, active_slot, custom_var_data)
	local is_succeed = Magic:TryToggleCurrentSpell(player, use_flags, rng)
	if is_succeed == nil then	--若不返回任何值，则默认显示动画
		is_succeed = true
	end
	return {ShowAnim = is_succeed, Remove = false}
end
ModRef:AddCallback(ModCallbacks.MC_USE_ITEM, BlueGrimoire.OnUse, modCollectibleType.COLLECTIBLE_BLUE_GRIMOIRE)

function BlueGrimoire:PostPlayerUpdate(player)
	if player:HasCollectible(modCollectibleType.COLLECTIBLE_BLUE_GRIMOIRE) and Tools:CanShowHUD() then
		Magic:SetDisplayMPIcon(player, true)
	else
		Magic:SetDisplayMPIcon(player, false)
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, BlueGrimoire.PostPlayerUpdate, 0)

function BlueGrimoire:TryDisplayChargeEffect(player)
	if player:HasCollectible(modCollectibleType.COLLECTIBLE_BLUE_GRIMOIRE) and (not Magic:IsMPFullyCharged(player, true)) then
		player:SetColor(Color(1, 1, 1, 1, 0.5, 0.5, 1), 3, -1, true)
		SFXManager():Play(SoundEffect.SOUND_BEEP)
	end
end

function BlueGrimoire:AwardBonusMP(player)
	local BonusMP = 1
	BlueGrimoire:TryDisplayChargeEffect(player)
	Magic:ModifyMadouRyoku(player, BonusMP, false)
end

function BlueGrimoire:TryAwardBonusMP(player)
	if player:HasCollectible(modCollectibleType.COLLECTIBLE_BLUE_GRIMOIRE) then
		if Tools:IsOriginalCharacter(player) or (not Magic:IsMageCharacter(player)) then
			BlueGrimoire:AwardBonusMP(player)
		end
	end
end

function BlueGrimoire:PreSpawnCleanAward(rng, spawn_pos)
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = Game():GetPlayer(p)
		BlueGrimoire:TryAwardBonusMP(player)
	end
end
ModRef:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, BlueGrimoire.PreSpawnCleanAward)

function BlueGrimoire:PostNewGreedModeWave(current_wave)
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = Game():GetPlayer(p)
		BlueGrimoire:TryAwardBonusMP(player)
	end
end
ModRef:AddCallback(tbomCallbacks.TBOMC_POST_NEW_GREED_MODE_WAVE, BlueGrimoire.PostNewGreedModeWave)

local MagicSynergies = {}
local CompatibleCollectiblesList = {
	CollectibleType.COLLECTIBLE_NUMBER_ONE,
	CollectibleType.COLLECTIBLE_BREAKFAST,
	CollectibleType.COLLECTIBLE_BATTERY,
	CollectibleType.COLLECTIBLE_CHOCOLATE_MILK,
	CollectibleType.COLLECTIBLE_CRYSTAL_BALL,
	CollectibleType.COLLECTIBLE_MAGIC_8_BALL,
	CollectibleType.COLLECTIBLE_JESUS_JUICE,
	CollectibleType.COLLECTIBLE_SOY_MILK,
	CollectibleType.COLLECTIBLE_MILK,
	CollectibleType.COLLECTIBLE_ALMOND_MILK,
	CollectibleType.COLLECTIBLE_RED_STEW,
}

MagicSynergies[CollectibleType.COLLECTIBLE_NUMBER_ONE] = function(player, rng)
	Magic:ModifyMadouJyougen(player, 1)
	BlueGrimoire:TryDisplayChargeEffect(player)
	Magic:ModifyMadouRyoku(player, 1)
end

MagicSynergies[CollectibleType.COLLECTIBLE_BREAKFAST] = function(player, rng)
	BlueGrimoire:TryDisplayChargeEffect(player)
	Magic:ModifyMadouRyoku(player, 3)
end

MagicSynergies[CollectibleType.COLLECTIBLE_BATTERY] = function(player, rng)
	if Tools:IsOriginalCharacter(player) or (not Magic:IsMageCharacter(player)) then
		Magic:ModifyMadouJyougen(player, 10)
	end
end

MagicSynergies[CollectibleType.COLLECTIBLE_CHOCOLATE_MILK] = function(player, rng)
	Magic:ModifyMadouJyougen(player, 5)
	BlueGrimoire:TryDisplayChargeEffect(player)
	Magic:FullMadouRyoku(player)
end

MagicSynergies[CollectibleType.COLLECTIBLE_CRYSTAL_BALL] = function(player, rng)
	Magic:ModifyMadouJyougen(player, 20)
	BlueGrimoire:TryDisplayChargeEffect(player)
	Magic:ModifyMadouRyoku(player, 10)
end

MagicSynergies[CollectibleType.COLLECTIBLE_MAGIC_8_BALL] = function(player, rng)
	Magic:ModifyMadouJyougen(player, 15)
	BlueGrimoire:TryDisplayChargeEffect(player)
	Magic:ModifyMadouRyoku(player, 8)
end

MagicSynergies[CollectibleType.COLLECTIBLE_JESUS_JUICE] = function(player, rng)
	Magic:ModifyMadouJyougen(player, 20)
	BlueGrimoire:TryDisplayChargeEffect(player)
	Magic:FullMadouRyoku(player)
end

MagicSynergies[CollectibleType.COLLECTIBLE_SOY_MILK] = function(player, rng)
	Magic:ModifyMadouJyougen(player, 10)
	BlueGrimoire:TryDisplayChargeEffect(player)
	Magic:ModifyMadouRyoku(player, 2)
end

MagicSynergies[CollectibleType.COLLECTIBLE_MILK] = function(player, rng)
	BlueGrimoire:TryDisplayChargeEffect(player)
	Magic:ModifyMadouRyoku(player, 5)
end

MagicSynergies[CollectibleType.COLLECTIBLE_ALMOND_MILK] = function(player, rng)
	Magic:ModifyMadouJyougen(player, 3 * Maths:RandomInt(3, rng, false, true) - 2)	--氢氰酸：HCN
end

MagicSynergies[CollectibleType.COLLECTIBLE_RED_STEW] = function(player, rng)
	Magic:ModifyMadouJyougen(player, 10)
	BlueGrimoire:TryDisplayChargeEffect(player)
	Magic:FullMadouRyoku(player)
end

function BlueGrimoire:PostAddCollectible(collectible_type, rng, player, is_newly_added)
	if is_newly_added and MagicSynergies[collectible_type] ~= nil then
		MagicSynergies[collectible_type](player, rng)
	end
end
for i, collectible_type in ipairs(CompatibleCollectiblesList) do
	ModRef:AddCallback(tbomCallbacks.TBOMC_POST_ADD_COLLECTIBLE, BlueGrimoire.PostAddCollectible, collectible_type)
end

--function BlueGrimoire:PreAddCollectible(collectible_type, rng, player)
--	Translation:ShowDefaultCollectibleText(collectible_type)
--end
--ModRef:AddCallback(tbomCallbacks.TBOMC_PRE_ADD_COLLECTIBLE, BlueGrimoire.PreAddCollectible, modCollectibleType.COLLECTIBLE_BLUE_GRIMOIRE)

return BlueGrimoire