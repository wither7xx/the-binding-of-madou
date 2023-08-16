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

function ArleNadja:PostPlayerInit(player)
	if player:GetPlayerType() == modPlayerType.PLAYER_ARLENADJA then
		local game = Game()
		if not (game:GetRoom():GetFrameCount() < 0 and game:GetFrameCount() > 0) then
			player:SetPocketActiveItem(modCollectibleType.COLLECTIBLE_BLUE_GRIMOIRE, ActiveSlot.SLOT_POCKET, false)
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, ArleNadja.PostPlayerInit, 0)

function ArleNadja:CheckPlayerData(player)		--//���޸ģ�С�����ô����
	if player:GetPlayerType() == modPlayerType.PLAYER_ARLENADJA then
		local starting_sprite_path = "gfx/characters/001_arle_nadja.anm2"
		Tools:TrySetStartingCostume(player, modCostume.ARLE_HAIR, starting_sprite_path)

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
ModRef:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CallbackPriority.EARLY, ArleNadja.CheckPlayerData, 0)	--����һ��ʱ�佻������

function ArleNadja:EvaluateCache(player, caflag)
	if player:GetPlayerType() == modPlayerType.PLAYER_ARLENADJA then
		--��ʼ����
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

function ArleNadja:LevelExpDataUpdate(player)
	local room = Game():GetRoom()
	if player:GetPlayerType() == modPlayerType.PLAYER_ARLENADJA then
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
			local FlashShootMulti = math.floor(math.max(100, 400 - room:GetFrameCount()) / 100) - 1
			LevelExp:ExpMulti_SetAttribute(player, "FlashShoot", FlashShootMulti)
		else
			LevelExp:ExpMulti_ClearAttribute(player, "FlashShoot")
		end
		--�Զ���ȡ��������
		local award_flag = AwardFlag.AWARD_STATS_INCREASE | AwardFlag.AWARD_HP_UP | AwardFlag.AWARD_MP_UP | AwardFlag.AWARD_UPGRADE_SPELL
		LevelExp:TryLevelUp(player, award_flag)
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, ArleNadja.LevelExpDataUpdate)

function ArleNadja:PreGetUpgradeAward(player, award_flag)	--��ֻ����ĳ���ر������������ཱ���ֱ��趨һ��Ĭ��ֵ����ֻ����ÿ��if�����һ��else���ɣ����ͱ��ʱֻ����һ����ǣ���֤�ص�����ÿ������ʱֻ���ṩһ�����⽱��������ΪĬ�Ͻ���
	if player:GetPlayerType() == modPlayerType.PLAYER_ARLENADJA then
		if award_flag == AwardFlag.AWARD_STATS_INCREASE then
			local bits = Maths:RandomInt(4, nil, true, true)
			if bits == 2 then		--�涨:����ʱ���ı䵯��
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

return ArleNadja