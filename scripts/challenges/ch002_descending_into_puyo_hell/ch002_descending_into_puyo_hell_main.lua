local PuyoHell = {}
local ModRef = tbom

local Common = tbom.Global.Common
local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths
local Translation = tbom.Global.Translation

local Fonts = tbom.Fonts
local modPlayerType = tbom.modPlayerType
local tbomCallbacks = tbom.tbomCallbacks
local modCollectibleType = tbom.modCollectibleType
local modEntityType = tbom.modEntityType
local modChallenge = tbom.modChallenge

local Puyo = include("scripts/monsters/e305_puyo/e305_puyo_api")
local PuyoFlag = Puyo.PuyoFlag

function PuyoHell:PostPlayerInit(player)
	if player and player.Variant == 0 then
		if Isaac.GetChallenge() == modChallenge.CHALLENGE_DESCENDING_INTO_PUYO_HELL then
			if player:GetPlayerType() ~= modPlayerType.PLAYER_ARLENADJA then
				Isaac.ExecuteCommand("restart " .. modPlayerType.PLAYER_ARLENADJA)
			end
			player:ChangePlayerType(modPlayerType.PLAYER_ARLENADJA)
		end
	end
end
tbom:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_INIT, CallbackPriority.EARLY, PuyoHell.PostPlayerInit)

function PuyoHell:NPCUpdate(npc)
	if Isaac.GetChallenge() == modChallenge.CHALLENGE_DESCENDING_INTO_PUYO_HELL then
		if Puyo:IsPuyo(npc) then
			local game = Game()
			local level = game:GetLevel()
			local stage = level:GetStage()
			local difficulty = game.Difficulty
			--if npc.FrameCount == 1 then
			Puyo:AddFlag(npc, PuyoFlag.FLAG_DO_NOT_USE_NORMAL_SKILL)
			--end
			if npc.InitSeed % 8 == 0 then
				stage = stage + 1
			end
			if math.floor(npc.InitSeed / 10) % 4 == 0 then
				difficulty = Difficulty.DIFFICULTY_HARD
			end
			local skill_type = Puyo:GetSkillTypeByStage(stage, difficulty)
			Puyo:SetSkillType(npc, skill_type)
			--print(skill_type, Puyo:GetSkillType(npc))
		end
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_NPC_UPDATE, CallbackPriority.LATE, PuyoHell.NPCUpdate, modEntityType.ENTITY_PUYO)

function PuyoHell:PostNewRoom()
	local game = Game()
	local room = game:GetRoom()
	local level = game:GetLevel()
	if Isaac.GetChallenge() == modChallenge.CHALLENGE_DESCENDING_INTO_PUYO_HELL then
		if Puyo:CanSpawnPuyo(room, level) then
			local room_desc = level:GetCurrentRoomDesc()
			seed = room_desc.SpawnSeed
			Puyo:SpawnRandomPuyo(room, level, math.floor(seed / 10000), 2)
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PuyoHell.PostNewRoom)

function PuyoHell:Reset(is_continued)
	if not is_continued then
		if Isaac.GetChallenge() == modChallenge.CHALLENGE_DESCENDING_INTO_PUYO_HELL then
			local player = Isaac.GetPlayer(0)
			local pool = Game():GetItemPool()
			player:AddCollectible(CollectibleType.COLLECTIBLE_PLUTO)
			player:AddCollectible(CollectibleType.COLLECTIBLE_FRIEND_BALL)
			pool:RemoveCollectible(modCollectibleType.COLLECTIBLE_PUYO_HAT)
			Puyo:AddPuyoChanceCache("PuyoHell", 32)
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, PuyoHell.Reset)

return PuyoHell