--感谢 @桃雨飞 提供的角色过场立绘与操作说明贴图
local ArleNadja = {}
local ModRef = tbom

local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths

local tbomCallbacks = tbom.tbomCallbacks
local modCollectibleType = tbom.modCollectibleType
local modPlayerType = tbom.modPlayerType
local modCostume = tbom.modCostume
local MagicType = tbom.MagicType
local SpellType = tbom.SpellType
local SpellContent = tbom.SpellContent
local Magic = tbom.Magic
local LevelExp = tbom.LevelExp
local CriticalChance = tbom.CriticalChance
local AwardFlag = tbom.AwardFlag

local Puyo = include("scripts/monsters/e305_puyo/e305_puyo_api")

local UnlockableSpellList = {
	["2"] = SpellType.SPELL_HEALING,
	["3"] = SpellType.SPELL_DIACUTE,
	["5"] = SpellType.SPELL_THUNDER,
	["7"] = SpellType.SPELL_FIRE,
	["9"] = SpellType.SPELL_ICE_STORM,
	["11"] = SpellType.SPELL_THUNDER,
	["13"] = SpellType.SPELL_DIACUTE,
	["14"] = SpellType.SPELL_BAYOEN,
	["16"] = SpellType.SPELL_FIRE,
	["18"] = SpellType.SPELL_ICE_STORM,
	["20"] = SpellType.SPELL_REVIA,
	["22"] = SpellType.SPELL_THUNDER,
	["24"] = SpellType.SPELL_DIACUTE,
	["26"] = SpellType.SPELL_FIRE,
	["28"] = SpellType.SPELL_ICE_STORM,
	["30"] = SpellType.SPELL_THUNDER,
}

local function HasArleNadja()
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = Isaac.GetPlayer(p)
		if player:GetPlayerType() == modPlayerType.PLAYER_ARLENADJA then
			return true
		end
	end
	return false
end

local function CheckGrimoire(player)
	if player:GetPlayerType() == modPlayerType.PLAYER_ARLENADJA 
	and player:GetActiveItem(ActiveSlot.SLOT_POCKET) ~= modCollectibleType.COLLECTIBLE_BLUE_GRIMOIRE then
		player:SetPocketActiveItem(modCollectibleType.COLLECTIBLE_BLUE_GRIMOIRE, ActiveSlot.SLOT_POCKET, false)
	end
end

function ArleNadja:PostPlayerInit(player)
	if player:GetPlayerType() == modPlayerType.PLAYER_ARLENADJA then
		local game = Game()
		if game:GetFrameCount() <= 0 or game:GetRoom():GetFrameCount() > 0 then
			player:SetPocketActiveItem(modCollectibleType.COLLECTIBLE_BLUE_GRIMOIRE, ActiveSlot.SLOT_POCKET, true)
			game:GetItemPool():RemoveCollectible(modCollectibleType.COLLECTIBLE_BLUE_GRIMOIRE)
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, ArleNadja.PostPlayerInit, 0)

function ArleNadja:PostPlayerUpdate(player)
	if player:GetPlayerType() == modPlayerType.PLAYER_ARLENADJA then
		local starting_sprite_path = "gfx/characters/001_arle_nadja.anm2"
		Tools:TrySetStartingCostume(player, modCostume.ARLE_HAIR, starting_sprite_path)

		--if player:GetActiveItem(ActiveSlot.SLOT_POCKET) ~= modCollectibleType.COLLECTIBLE_BLUE_GRIMOIRE then
		--	player:SetPocketActiveItem(modCollectibleType.COLLECTIBLE_BLUE_GRIMOIRE, ActiveSlot.SLOT_POCKET, false)
		--end

		Magic:TrySetMageCharacter(player, true)
		Magic:PlayerDataInit(player, 20, 20, 20)
		Magic:TryAddSpell(player, SpellType.SPELL_FIRE, 1, true)
		Magic:TryAddSpell(player, SpellType.SPELL_ICE_STORM, 1, true)
		Magic:TryAddSpell(player, SpellType.SPELL_THUNDER, 0, true)
		Magic:TryAddSpell(player, SpellType.SPELL_HEALING, 0, true)
		Magic:TryAddSpell(player, SpellType.SPELL_DIACUTE, 0, true)
		Magic:TryAddSpell(player, SpellType.SPELL_BAYOEN, 0, true)
		Magic:TryAddSpell(player, SpellType.SPELL_REVIA, 0, true)
		Magic:TryAddSpell(player, SpellType.SPELL_JUGEM, 0, true)

		LevelExp:TrySetRPGCharacter(player, true)
		LevelExp:PlayerDataInit(player, 0, 0)
		LevelExp:TrySetUnlockableSpellList(player, UnlockableSpellList)

		CriticalChance:TrySetCritCharacter(player, true)
		CriticalChance:PlayerDataInit(player, 4)

		Tools:PlayerData_SetAttribute(player, "ArleNadja_PlayerDataInited", true)
	else
		if Tools:PlayerData_GetAttribute(player, "ArleNadja_PlayerDataInited") == true then
			Magic:SetMageCharacter(player, false)
			LevelExp:SetRPGCharacter(player, false)
			CriticalChance:SetCritCharacter(player, false)
			player:TryRemoveNullCostume(modCostume.ARLE_HAIR)
		end
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CallbackPriority.EARLY, ArleNadja.PostPlayerUpdate, 0)	--留出一定时间交给读档

function ArleNadja:PostUpdate()
	Tools:TryCheckEsauJrData(CheckGrimoire)
	if HasArleNadja() then
		Puyo:AddPuyoChanceCache("ArleNadja", 10)
	else
		Puyo:ClearPuyoChanceCache("ArleNadja")
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_POST_UPDATE, 10, ArleNadja.PostUpdate)

function ArleNadja:EvaluateCache(player, caflag)
	if player:GetPlayerType() == modPlayerType.PLAYER_ARLENADJA then
		--初始属性
		if caflag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage - 0.5
		end
		if caflag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = (30 / (30 / (player.MaxFireDelay + 1) - 0.2) - 1)
		end
		if caflag == CacheFlag.CACHE_RANGE then
			player.TearRange = player.TearRange - 40
		end
		if caflag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed - 0.1
		end
		for i, level_exp_flag in pairs(LevelExp:GetStatsCacheFlags(player)) do
			if level_exp_flag == CacheFlag.CACHE_DAMAGE and caflag == CacheFlag.CACHE_DAMAGE then
				player.Damage = player.Damage + 0.2
			end
			if level_exp_flag == CacheFlag.CACHE_FIREDELAY and caflag == CacheFlag.CACHE_FIREDELAY then
				player.MaxFireDelay = (30 / (30 / (player.MaxFireDelay + 1) + 0.1) - 1)
			end
			if level_exp_flag == CacheFlag.CACHE_RANGE and caflag == CacheFlag.CACHE_RANGE then
				player.TearRange = player.TearRange + 20
			end
			if level_exp_flag == CacheFlag.CACHE_SPEED and caflag == CacheFlag.CACHE_SPEED then
				player.MoveSpeed = player.MoveSpeed + 0.05
			end
			if level_exp_flag == CacheFlag.CACHE_LUCK and caflag == CacheFlag.CACHE_LUCK then
				player.Luck = player.Luck + 0.2
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ArleNadja.EvaluateCache)

local function GetCurrentRoomFrameCount()
	local game = Game()
	local room = game:GetRoom()
	if not game:IsGreedMode() then
		return room:GetFrameCount()
	else
		local greed_wave_frame_count = Tools:GameData_GetAttribute("ArleNadja_GreedWaveFrameCount") or 0
		return room:GetFrameCount() - greed_wave_frame_count
	end
end

function ArleNadja:PostNewGreedModeWave(current_wave)
	local game = Game()
	if game:IsGreedMode() then
		local room = game:GetRoom()
		Tools:GameData_SetAttribute("ArleNadja_GreedWaveFrameCount", room:GetFrameCount())
	end
end
ModRef:AddCallback(tbomCallbacks.TBOMC_POST_NEW_GREED_MODE_WAVE, ArleNadja.PostNewGreedModeWave)

function ArleNadja:LevelExpDataUpdate(player)
	
	if player:GetPlayerType() == modPlayerType.PLAYER_ARLENADJA then
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
			local FlashShootMulti = math.floor(math.max(100, 400 - GetCurrentRoomFrameCount()) / 100) - 1
			LevelExp:ExpMulti_SetAttribute(player, "FlashShoot", FlashShootMulti)
		else
			LevelExp:ExpMulti_ClearAttribute(player, "FlashShoot")
		end
		--自动获取升级奖励
		local award_flag = AwardFlag.AWARD_STATS_INCREASE | AwardFlag.AWARD_HP_UP | AwardFlag.AWARD_MP_UP | AwardFlag.AWARD_UPGRADE_SPELL
		LevelExp:TryLevelUp(player, award_flag)
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, ArleNadja.LevelExpDataUpdate)

function ArleNadja:PreGetUpgradeAward(player, award_flag)	--若只想获得某种特别奖励，而将其余奖励分别设定一个默认值，则只需在每个if后面加一个else即可；发送标记时只发送一个标记，保证回调函数每次运行时只会提供一个特殊奖励、其余为默认奖励
	if player:GetPlayerType() == modPlayerType.PLAYER_ARLENADJA then
		if award_flag == AwardFlag.AWARD_STATS_INCREASE then
			local bits = Maths:RandomInt(4, nil, true, true)
			if bits == 2 then		--规定:升级时不改变弹速
				bits = 10
			end
			LevelExp:AddStatsCacheFlags(player, (1 << bits))
		end
		if award_flag == AwardFlag.AWARD_HP_UP then
			player:AddHearts(24)
		end
		if award_flag == AwardFlag.AWARD_MP_UP then
			if not Magic:IsMPFullyCharged(player, true) then
				player:SetColor(Color(1, 1, 1, 1, 0.5, 0.5, 1), 3, -1, true)
				SFXManager():Play(SoundEffect.SOUND_BEEP)
			end
			local BonusMPCap = 5
			if LevelExp:GetRealReberu(player) <= 5 then
				BonusMPCap = 10
			end
			Magic:ModifyMadouJyougen(player, BonusMPCap)
			Magic:FullMadouRyoku(player)
		end
		if award_flag == AwardFlag.AWARD_UPGRADE_SPELL then
			LevelExp:TryUpgradeUnlockableSpell(player)
		end
	end
end
ModRef:AddCallback(tbomCallbacks.TBOMC_PRE_GET_UPGRADE_AWARD, ArleNadja.PreGetUpgradeAward)

function ArleNadja:PostNewRoom()
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = Isaac.GetPlayer(p)
		CheckGrimoire(player)
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, ArleNadja.PostNewRoom)

function ArleNadja:PostNewLevel()
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = Isaac.GetPlayer(p)
		CheckGrimoire(player)
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, ArleNadja.PostNewLevel)

return ArleNadja