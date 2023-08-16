local WormholeApple_META = {
	__index = {},
}
local WormholeApple = WormholeApple_META.__index
local ModRef = tbom

local Common = tbom.Global.Common
local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths
local Translation = tbom.Global.Translation

local tbomCallbacks = tbom.tbomCallbacks
local modCollectibleType = tbom.modCollectibleType

WormholeApple.CollectiblePhase = {
	PHASE_STANDBY = 0,
	PHASE_WELCOME = 1,
	PHASE_QUIZZING = 2,
	PHASE_HANDING_IN = 3,
	PHASE_FORCED_HANDED_IN = 4,
}
local CollectiblePhase = WormholeApple.CollectiblePhase

WormholeApple.QuestionDifficulty = {
	AMAKUCHI = 1,		--甘口（简单题）
	CHUUKARA = 2,		--中辛（中等题）
	KARAKUCHI = 3,		--辛口（困难题）
}
local QuestionDifficulty = WormholeApple.QuestionDifficulty

WormholeApple.InputCharKey = {
	KEY_1 = 1,
	KEY_2 = 2,
	KEY_3 = 3,
	KEY_4 = 4,
	KEY_5 = 5,
	KEY_6 = 6,
	KEY_7 = 7,
	KEY_8 = 8,
	KEY_9 = 9,
	KEY_0 = 10,
	KEY_UNM = 11,
	KEY_DOT = 12,
	KEY_BACKSPACE = 13,
	KEY_RETURN = 14,
	KEY_CLEAR = 15,
	KEY_NULL = 16,
	NUM_NUMBER_CHAR = 10,
	NUM_INPUT_CHAR_COL = 3,
	NUM_INPUT_CHAR_ROW = 5,
	NUM_INPUT_CHAR = 15,
}
local InputCharKey = WormholeApple.InputCharKey

do
	local path = "scripts/items/collectibles/c003_wormhole_apple/"
	WormholeApple.Texts = setmetatable({}, include(path .. "c003_wormhole_apple_texts"))
	--WormholeApple.Texts = include(path .. "c003_wormhole_apple_texts")
	--WormholeApple.Texts.Questions = {
	--	[QuestionDifficulty.AMAKUCHI] = include(path .. "question_bank/c003_questions_amakuchi"),
	--	[QuestionDifficulty.CHUUKARA] = include(path .. "question_bank/c003_questions_chuukara"),
	--	[QuestionDifficulty.KARAKUCHI] = include(path .. "question_bank/c003_questions_karakuchi"),
	--}
	WormholeApple.Questions = {
		[QuestionDifficulty.AMAKUCHI] = include(path .. "question_bank/c003_questions_amakuchi"),
		[QuestionDifficulty.CHUUKARA] = include(path .. "question_bank/c003_questions_chuukara"),
		[QuestionDifficulty.KARAKUCHI] = include(path .. "question_bank/c003_questions_karakuchi"),
	}
end

local function GetWormholeAppleData(player)
	--print("GetWormholeAppleData(player)")
	--print(tostring(player == nil))
	return Tools:GetPlayerCollectibleData(player, modCollectibleType.COLLECTIBLE_WORMHOLE_APPLE)
end

function WormholeApple:WormholeAppleDataInit(player)
	local data = GetWormholeAppleData(player)
	if data.Phase == nil then
		data.Phase = CollectiblePhase.PHASE_STANDBY		--当前阶段（整数）
	end
	if data.QuestionNum == nil then
		data.QuestionNum = 5							--题目总数（整数）
	end
	if data.Countdown == nil then
		data.Countdown = 0								--计时器（整数）
	end
	if data.AdditionalCountdown == nil then
		data.AdditionalCountdown = 0					--附加计时器（整数），用于附加文字等
	end
	if data.RealScore == nil then
		data.RealScore = 5								--得分（整数），在答错或未作答时扣分
	end
	if data.FormalScore == nil then
		data.FormalScore = 5							--得分（整数），只在答错时扣分
	end
	if data.CurrentQuestionKey == nil then
		data.CurrentQuestionKey = 0						--当前问题键值（整数），用于检索问题列表
	end
	if data.CurrentInputCharKey == nil then
		data.CurrentInputCharKey = InputCharKey.KEY_1	--当前输入键值（整数），用于检索可选字符列表
	end
	if data.GhostPoint == nil then
		data.GhostPoint = 0								--幽灵点数（浮点数），用于抖动字彩蛋
	end
	if data.TextBox == nil then
		data.TextBox = ""								--文本框（字符串）
	end
	if data.QuestionsList == nil then
		data.QuestionsList = {}							--问题列表（散列表数组，对应值为题目难度及序号）
	end
end

function WormholeApple:GetPhase(player)
	local data = GetWormholeAppleData(player)
	return data.Phase or CollectiblePhase.PHASE_STANDBY
end

function WormholeApple:SetPhase(player, value)
	local data = GetWormholeAppleData(player)
	data.Phase = value
end

function WormholeApple:GetQuestionNum(player)
	local data = GetWormholeAppleData(player)
	return data.QuestionNum or 5
end

function WormholeApple:SetQuestionNum(player, value)
	local data = GetWormholeAppleData(player)
	data.QuestionNum = math.max(0, value)
end

function WormholeApple:GetCountdown(player)
	local data = GetWormholeAppleData(player)
	return data.Countdown or 0
end

function WormholeApple:SetCountdown(player, value)
	local data = GetWormholeAppleData(player)
	data.Countdown = math.max(0, value)
end

function WormholeApple:SetCountdownByDifficulty(player, difficulty)
	local second = 60
	local CD_list = {
		[QuestionDifficulty.AMAKUCHI] = 30 * second,
		[QuestionDifficulty.CHUUKARA] = 60 * second,
		[QuestionDifficulty.KARAKUCHI] = 120 * second,
	}
	WormholeApple:SetCountdown(player, CD_list[difficulty])
end

function WormholeApple:ModifyCountdown(player, amount)
	local data = GetWormholeAppleData(player)
	if data.Countdown then
		data.Countdown = math.max(0, data.Countdown + amount)
	end
end

function WormholeApple:GetAdditionalCountdown(player)
	local data = GetWormholeAppleData(player)
	return data.AdditionalCountdown or 0
end

function WormholeApple:SetAdditionalCountdown(player, value)
	local data = GetWormholeAppleData(player)
	data.AdditionalCountdown = math.max(0, value)
end

function WormholeApple:ModifyAdditionalCountdown(player, amount)
	local data = GetWormholeAppleData(player)
	if data.Countdown then
		data.AdditionalCountdown = math.max(0, data.AdditionalCountdown + amount)
	end
end

function WormholeApple:GetRealScore(player)
	local data = GetWormholeAppleData(player)
	return data.RealScore or 0
end

function WormholeApple:SetRealScore(player, value)
	local data = GetWormholeAppleData(player)
	data.RealScore = math.max(0, value)
end

function WormholeApple:ResetRealScore(player)
	local data = GetWormholeAppleData(player)
	data.RealScore = data.QuestionNum
end

function WormholeApple:ModifyRealScore(player, amount)
	local data = GetWormholeAppleData(player)
	if data.RealScore then
		data.RealScore = math.max(0, data.RealScore + amount)
	end
end

function WormholeApple:GetFormalScore(player)
	local data = GetWormholeAppleData(player)
	return data.FormalScore or 0
end

function WormholeApple:SetFormalScore(player, value)
	local data = GetWormholeAppleData(player)
	data.FormalScore = math.max(0, value)
end

function WormholeApple:ResetFormalScore(player)
	local data = GetWormholeAppleData(player)
	data.FormalScore = data.QuestionNum
end

function WormholeApple:ModifyFormalScore(player, amount)
	local data = GetWormholeAppleData(player)
	if data.FormalScore then
		data.FormalScore = math.max(0, data.FormalScore + amount)
	end
end

function WormholeApple:GetCurrentQuestionKey(player)
	local data = GetWormholeAppleData(player)
	return data.CurrentQuestionKey or 0
end

function WormholeApple:SetCurrentQuestionKey(player, value)
	local data = GetWormholeAppleData(player)
	data.CurrentQuestionKey = math.max(0, math.min(value, data.QuestionNum))
end

function WormholeApple:ResetCurrentQuestionKey(player)
	local data = GetWormholeAppleData(player)
	data.CurrentQuestionKey = 0
end

function WormholeApple:ModifyCurrentQuestionKey(player, amount)
	local data = GetWormholeAppleData(player)
	if data.CurrentQuestionKey then
		--data.CurrentQuestionKey = math.max(0, math.min(data.CurrentQuestionKey + amount, data.QuestionNum))
		data.CurrentQuestionKey = math.max(1, data.CurrentQuestionKey + amount)
	end
end

function WormholeApple:GetRemainingQuestionNum(player)
	local data = GetWormholeAppleData(player)
	if data.QuestionNum and data.CurrentQuestionKey then
		return math.min(data.QuestionNum, data.QuestionNum - data.CurrentQuestionKey + 1)
	end
	return 0
end

function WormholeApple:GetCurrentInputCharKey(player)
	local data = GetWormholeAppleData(player)
	return data.CurrentInputCharKey or InputCharKey.KEY_NULL
end

function WormholeApple:SetCurrentInputCharKey(player, value)
	local data = GetWormholeAppleData(player)
	data.CurrentInputCharKey = math.max(InputCharKey.KEY_1, math.min(value, InputCharKey.NUM_INPUT_CHAR))
end

function WormholeApple:ResetCurrentInputCharKey(player)
	local data = GetWormholeAppleData(player)
	data.CurrentInputCharKey = InputCharKey.KEY_NULL
end

function WormholeApple:MoveCurrentInputCharKey_Down(player)
	local data = GetWormholeAppleData(player)
	if data.CurrentInputCharKey then
		if data.CurrentInputCharKey == InputCharKey.KEY_NULL then
			data.CurrentInputCharKey = InputCharKey.KEY_1
		else
			--data.CurrentInputCharKey = math.max(InputCharKey.KEY_1, math.min(data.CurrentQuestionKey + amount, data.QuestionNum))
			local result = data.CurrentInputCharKey + InputCharKey.NUM_INPUT_CHAR_COL
			while result > InputCharKey.NUM_INPUT_CHAR do
				result = result - InputCharKey.NUM_INPUT_CHAR
			end
			data.CurrentInputCharKey = result
		end
	end
end

function WormholeApple:MoveCurrentInputCharKey_Up(player)
	local data = GetWormholeAppleData(player)
	if data.CurrentInputCharKey then
		if data.CurrentInputCharKey == InputCharKey.KEY_NULL then
			data.CurrentInputCharKey = InputCharKey.KEY_1
		else
			local result = data.CurrentInputCharKey - InputCharKey.NUM_INPUT_CHAR_COL
			while result <= 0 do
				result = result + InputCharKey.NUM_INPUT_CHAR
			end
			data.CurrentInputCharKey = result
		end
	end
end

function WormholeApple:MoveCurrentInputCharKey_Right(player)
	local data = GetWormholeAppleData(player)
	if data.CurrentInputCharKey then
		if data.CurrentInputCharKey == InputCharKey.KEY_NULL then
			data.CurrentInputCharKey = InputCharKey.KEY_1
		else
			local result = math.floor((data.CurrentInputCharKey - 1) / InputCharKey.NUM_INPUT_CHAR_COL) * InputCharKey.NUM_INPUT_CHAR_COL + (data.CurrentInputCharKey % InputCharKey.NUM_INPUT_CHAR_COL) + 1
			data.CurrentInputCharKey = result
		end
	end
end

function WormholeApple:MoveCurrentInputCharKey_Lift(player)
	local data = GetWormholeAppleData(player)
	if data.CurrentInputCharKey then
		if data.CurrentInputCharKey == InputCharKey.KEY_NULL then
			data.CurrentInputCharKey = InputCharKey.KEY_1
		else
			local result = (data.CurrentInputCharKey % InputCharKey.NUM_INPUT_CHAR_COL) - 1
			while result <= 0 do
				result = result + InputCharKey.NUM_INPUT_CHAR_COL
			end
			data.CurrentInputCharKey = result + math.floor((data.CurrentInputCharKey - 1) / InputCharKey.NUM_INPUT_CHAR_COL) * InputCharKey.NUM_INPUT_CHAR_COL
		end
	end
end

function WormholeApple:GetQuestionsList(player)
	local data = GetWormholeAppleData(player)
	return data.QuestionsList or {}
end

function WormholeApple:TryAddQuestion(player, difficulty, question_ID)
	local data = GetWormholeAppleData(player)
	if data.QuestionsList and data.QuestionNum and #(data.QuestionsList) < data.QuestionNum then
		table.insert(data.QuestionsList, {Difficulty = difficulty, QuestionID = question_ID})
	end
end

function WormholeApple:ClearQuestionList(player)
	local data = GetWormholeAppleData(player)
	data.QuestionsList = {}
end

function WormholeApple:GetGhostPoint(player)
	local data = GetWormholeAppleData(player)
	return data.GhostPoint or 0
end

function WormholeApple:SetGhostPoint(player, value)
	local data = GetWormholeAppleData(player)
	data.GhostPoint = math.max(0, value)
end

function WormholeApple:ModifyGhostPoint(player, amount)
	local data = GetWormholeAppleData(player)
	if data.GhostPoint then
		data.GhostPoint = math.max(0, data.GhostPoint + amount)
	end
end

function WormholeApple:GetNearestGhostDistance(player)
	local dis0 = 999999
	--local entities = Isaac.GetRoomEntities()
	for _, entity in pairs(Isaac.GetRoomEntities()) do
		if entity and entity:Exists() and player.Position:Distance(entity.Position) < dis0 and Tools:IsGhostEnemy(entity) then
			dis0 = player.Position:Distance(entity.Position)
		end
	end
	return dis0
end

function WormholeApple:GetTextBox(player)
	local data = GetWormholeAppleData(player)
	return data.TextBox or ""
end

function WormholeApple:ResetTextBox(player)
	local data = GetWormholeAppleData(player)
	data.TextBox = ""
end

function WormholeApple:AddCharToTextBoxHead(player, chr)
	local data = GetWormholeAppleData(player)
	if data.TextBox and string.len(data.TextBox) < 32 then
		data.TextBox = chr .. data.TextBox
	end
end

function WormholeApple:AddCharToTextBoxRear(player, chr)
	local data = GetWormholeAppleData(player)
	if data.TextBox and string.len(data.TextBox) < 32 then
		data.TextBox = data.TextBox .. chr
	end
end

function WormholeApple:RemoveHeadCharFromTextBox(player)
	local data = GetWormholeAppleData(player)
	if data.TextBox then
		data.TextBox = string.sub(data.TextBox, 2)
	end
end

function WormholeApple:RemoveRearCharFromTextBox(player)
	local data = GetWormholeAppleData(player)
	if data.TextBox then
		data.TextBox = string.sub(data.TextBox, 1, -2)
	end
end

function WormholeApple:TextBox_TriggerNegativeNumber(player)
	local head = string.sub(WormholeApple:GetTextBox(player), 1, 1)
	if head == "-" then
		WormholeApple:RemoveHeadCharFromTextBox(player)
	else
		WormholeApple:AddCharToTextBoxHead(player, "-")
	end
end

function WormholeApple:TextBox_TryAddDot(player)
	local text_box = WormholeApple:GetTextBox(player)
	if string.find(text_box, "%.") == nil then
		WormholeApple:AddCharToTextBoxRear(player, ".")
	end
end

function WormholeApple:GetCurrentDifficulty(player)
	local data = GetWormholeAppleData(player)
	if data.QuestionsList and data.CurrentQuestionKey and data.QuestionsList[data.CurrentQuestionKey] then
		return data.QuestionsList[data.CurrentQuestionKey].Difficulty
	end
	return nil
end

function WormholeApple:GetCurrentQuestionID(player)
	local data = GetWormholeAppleData(player)
	if data.QuestionsList and data.CurrentQuestionKey and data.QuestionsList[data.CurrentQuestionKey] then
		return data.QuestionsList[data.CurrentQuestionKey].QuestionID
	end
	return nil
end

function WormholeApple:GetNextDifficulty(player)
	local data = GetWormholeAppleData(player)
	if data.QuestionsList and data.CurrentQuestionKey and data.QuestionsList[data.CurrentQuestionKey + 1] then
		return data.QuestionsList[data.CurrentQuestionKey + 1].Difficulty
	end
	return nil
end

function WormholeApple:GetNextQuestionID(player)
	local data = GetWormholeAppleData(player)
	if data.QuestionsList and data.CurrentQuestionKey and data.QuestionsList[data.CurrentQuestionKey + 1] then
		return data.QuestionsList[data.CurrentQuestionKey + 1].QuestionID
	end
	return nil
end

function WormholeApple:GetQuestion(player, difficulty, question_ID)
	if difficulty and question_ID and WormholeApple.Questions[difficulty] then
		return WormholeApple.Questions[difficulty][question_ID]
	end
	return nil
end

function WormholeApple:GetCurrentQuestion(player)
	local difficulty = WormholeApple:GetCurrentDifficulty(player)
	local question_ID = WormholeApple:GetCurrentQuestionID(player)
	--print("new question:"..difficulty..","..question_ID)
	return WormholeApple:GetQuestion(player, difficulty, question_ID)
end

function WormholeApple:HasQuestion(player, difficulty, question_ID)
	local question_list = WormholeApple:GetQuestionsList(player)
	for _, question in ipairs(question_list) do
		if question.Difficulty == difficulty and question.QuestionID == question_ID then
			return true
		end
	end
	return false
end

function WormholeApple:CanAnswerQuestion(player, ignore_item)
	return (player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == modCollectibleType.COLLECTIBLE_WORMHOLE_APPLE or ignore_item) and (not player:IsCoopGhost()) and (not player:HasCurseMistEffect())
end

function WormholeApple:Compose(player, rng)
	rng = rng or player:GetCollectibleRNG(modCollectibleType.COLLECTIBLE_WORMHOLE_APPLE)
	WormholeApple:ClearQuestionList(player)
	WormholeApple:ResetCurrentQuestionKey(player)
	WormholeApple:ResetCurrentInputCharKey(player)
	WormholeApple:ResetRealScore(player)
	WormholeApple:ResetFormalScore(player)
	local question_num = WormholeApple:GetQuestionNum(player)
	local difficulty_list = {
		[1] = {QuestionDifficulty.AMAKUCHI, QuestionDifficulty.AMAKUCHI, QuestionDifficulty.CHUUKARA, QuestionDifficulty.KARAKUCHI, QuestionDifficulty.KARAKUCHI},
		[2] = {QuestionDifficulty.AMAKUCHI, QuestionDifficulty.CHUUKARA, QuestionDifficulty.CHUUKARA, QuestionDifficulty.KARAKUCHI, QuestionDifficulty.KARAKUCHI},
		[3] = {QuestionDifficulty.AMAKUCHI, QuestionDifficulty.CHUUKARA, QuestionDifficulty.KARAKUCHI, QuestionDifficulty.KARAKUCHI, QuestionDifficulty.KARAKUCHI},
		--{QuestionDifficulty.AMAKUCHI, QuestionDifficulty.KARAKUCHI, QuestionDifficulty.KARAKUCHI, QuestionDifficulty.KARAKUCHI, QuestionDifficulty.KARAKUCHI}
	}
	local used_difficulty_list = difficulty_list[Maths:RandomInt(#difficulty_list, rng, false, true)]
	for idx, difficulty in ipairs(used_difficulty_list) do
		if WormholeApple.Questions[difficulty] then
			local question_bank = WormholeApple.Questions[difficulty]
			local weight_list = {}
			for i, question in ipairs(question_bank) do
				table.insert(weight_list, question.Weight)
			end
			local question_ID = Maths:RandomInt(#question_bank, rng, false, true)
			--local question_ID = Maths:RandomInt_Weighted(weight_list, rng)
			while WormholeApple:HasQuestion(player, difficulty, question_ID) do
				question_ID = (question_ID % #question_bank) + 1
			end
			question_bank[question_ID]:Update(player, rng)
			WormholeApple:TryAddQuestion(player, difficulty, question_ID)
			--print(difficulty,question_ID)
		end
	end
end

function WormholeApple:Submit(player, answer, is_timeout)
	--print("test1")
	local phase = WormholeApple:GetPhase(player)
	if phase == CollectiblePhase.PHASE_WELCOME then
		WormholeApple:ResetTextBox(player)
		local next_difficulty = WormholeApple:GetNextDifficulty(player)
		WormholeApple:SetCountdownByDifficulty(player, next_difficulty)
		WormholeApple:ModifyCurrentQuestionKey(player, 1)
		WormholeApple:SetPhase(player, CollectiblePhase.PHASE_QUIZZING)
		--print("SetPhase(player, CollectiblePhase.PHASE_QUIZZING)")
	elseif phase == CollectiblePhase.PHASE_QUIZZING then
		local final_answer = tonumber(answer)
		local is_right_answer = false
		local current_question = WormholeApple:GetCurrentQuestion(player)
		if current_question then
			local right_answer = current_question:Answer(player)
			--print(final_answer, right_answer)
			if final_answer and final_answer == right_answer then
				is_right_answer = true
			end
		end
		if not is_right_answer then
			if not is_timeout then
				WormholeApple:ModifyFormalScore(player, -1)
			end
			WormholeApple:ModifyRealScore(player, -1)
		end
		WormholeApple:ResetTextBox(player)
		local next_difficulty = WormholeApple:GetNextDifficulty(player)
		--local difficulty = WormholeApple:GetCurrentDifficulty(player)
		if next_difficulty then
			WormholeApple:SetCountdownByDifficulty(player, next_difficulty)
		else
			WormholeApple:SetCountdown(player, 0)
			WormholeApple:SetAdditionalCountdown(player, 180)
		end
		--print("Key:"..WormholeApple:GetCurrentQuestionKey(player))
		--print("modified")
		WormholeApple:ModifyCurrentQuestionKey(player, 1)
		--print("Key:"..WormholeApple:GetCurrentQuestionKey(player))
		--print("answer is "..tostring(is_right_answer))
	end
end

function WormholeApple:Award(player, rng)
	rng = rng or player:GetCollectibleRNG(modCollectibleType.COLLECTIBLE_WORMHOLE_APPLE)
	local real_score = WormholeApple:GetRealScore(player)
	if real_score == 0 then
		local formal_score = WormholeApple:GetFormalScore(player)
		if real_score == formal_score then
			if player:HasCollectible(CollectibleType.COLLECTIBLE_HOST_HAT) 
			or player:HasCollectible(CollectibleType.COLLECTIBLE_PYROMANIAC) 
			or player:HasTrinket(TrinketType.TRINKET_SAFETY_SCISSORS) then
				return Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.MOM_FOOT_STOMP, 0, player.Position, Vector(0, 0), nil)
			else
				return Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_SUPERTROLL, player.Position, Vector(0, 0), nil)
			end
		else
			player:UseActiveItem(CollectibleType.COLLECTIBLE_POOP)
			return nil
		end
	else
		local quality = real_score - 1
		if player:HasCollectible(CollectibleType.COLLECTIBLE_SACRED_ORB) then
			quality = 2 + math.floor(quality / 2)
		elseif player:GetTrinketMultiplier(TrinketType.TRINKET_NO) >= 2 then
			if quality <= 2 then
				quality = quality + 1
			end
		end
		local player_type = player:GetPlayerType()
		local give_item_directly = WormholeApple:IsCharacterThatCannotPickItems(player_type)
		return Tools:RandomCollectible_ByQuality(player, quality, rng, give_item_directly)
	end
end

WormholeApple.CharacterThatCannotPickItems = {}

function WormholeApple:IsCharacterThatCannotPickItems(player_type)
	return Common:IsInTable(player_type, self.CharacterThatCannotPickItems)
end

function WormholeApple:AddCharacterThatCannotPickItems(player_type)
	if not WormholeApple:IsCharacterThatCannotPickItems(player_type) then
		table.insert(self.CharacterThatCannotPickItems, player_type)
	end
end

return WormholeApple_META