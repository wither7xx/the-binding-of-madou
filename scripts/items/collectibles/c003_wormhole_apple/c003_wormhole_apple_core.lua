local WormholeApple_META = {
	__index = setmetatable({}, include("scripts/items/collectibles/c003_wormhole_apple/c003_wormhole_apple_constants")),
}
local WormholeApple = WormholeApple_META.__index
local ModRef = tbom

local Common = tbom.Global.Common
local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths
local Translation = tbom.Global.Translation

local tbomCallbacks = tbom.tbomCallbacks
local modCollectibleType = tbom.modCollectibleType

local CollectiblePhase = WormholeApple.CollectiblePhase
local QuestionDifficulty = WormholeApple.QuestionDifficulty
local InputCharKey = WormholeApple.InputCharKey

local function GetWormholeAppleData(player)
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
	return (player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == modCollectibleType.COLLECTIBLE_WORMHOLE_APPLE 
			or ignore_item) 
		and (not player:IsCoopGhost()) 
		and (not player:HasCurseMistEffect())
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

function WormholeApple:GetAwardingRecipesList(player, rng, quality)
	local list = {}
	local basic_recipes = {
		{Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_FULL,},
		{Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_HALF,},
		{Variant = PickupVariant.PICKUP_COIN, SubType = CoinSubType.COIN_PENNY,},
		------
		{Variant = PickupVariant.PICKUP_KEY, SubType = KeySubType.KEY_NORMAL,},
		{Variant = PickupVariant.PICKUP_BOMB, SubType = BombSubType.BOMB_NORMAL,},
		{Variant = PickupVariant.PICKUP_LIL_BATTERY, SubType = BatterySubType.BATTERY_MICRO,},
	}
	local q1_recipes = {
		{Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_ROTTEN,},
		{Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_RANDOM,},
		{Variant = PickupVariant.PICKUP_PILL, SubType = Maths:RandomInt(PillColor.NUM_STANDARD_PILLS, rng, false, false),},
	}
	local q2_recipes = {
		{Variant = PickupVariant.PICKUP_COIN, SubType = CoinSubType.COIN_NICKEL,},
		{Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_SOUL,},
		{Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_HALF_SOUL,},
		{Variant = PickupVariant.PICKUP_LIL_BATTERY, SubType = BatterySubType.BATTERY_NORMAL,},
	}
	local q3_recipes = {
		{Variant = PickupVariant.PICKUP_COIN, SubType = CoinSubType.COIN_DIME,},
		{Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_GOLDEN,},
		{Variant = PickupVariant.PICKUP_KEY, SubType = KeySubType.KEY_CHARGED,},
	}
	local q4_recipes = {
		{Variant = PickupVariant.PICKUP_COIN, SubType = CoinSubType.COIN_LUCKYPENNY,},
		{Variant = PickupVariant.PICKUP_COIN, SubType = CoinSubType.COIN_GOLDEN,},
		{Variant = PickupVariant.PICKUP_KEY, SubType = KeySubType.KEY_GOLDEN,},
		{Variant = PickupVariant.PICKUP_BOMB, SubType = BombSubType.BOMB_GOLDEN,},
		{Variant = PickupVariant.PICKUP_BOMB, SubType = BombSubType.BOMB_GIGA,},
		{Variant = PickupVariant.PICKUP_PILL, SubType = PillColor.PILL_GOLD,},
		{Variant = PickupVariant.PICKUP_LIL_BATTERY, SubType = BatterySubType.BATTERY_MEGA,},
		{Variant = PickupVariant.PICKUP_LIL_BATTERY, SubType = BatterySubType.BATTERY_GOLDEN,},
	}
	local special_recipes = {
		{Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_ETERNAL,},
		{Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_BLACK,},
		{Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_BONE,},
	}
	if quality == 0 then
		local q0_recipes = {
			{Variant = PickupVariant.PICKUP_POOP, SubType = PoopPickupSubType.POOP_SMALL,},
			{Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_ROTTEN,},
		}
		for i = 1, 5 do
			local rand = Maths:RandomInt(3, rng, false, true)
			if i <= 4 then
				table.insert(list, basic_recipes[rand])
			else
				local rand_q0 = Maths:RandomInt(3, rng, false, true)
				if rand_q0 <= 2 then
					table.insert(list, q0_recipes[rand_q0])
				else
					table.insert(list, basic_recipes[rand])
				end
			end
		end
	elseif quality == 1 then
		for i = 1, 8 do
			local rand = Maths:RandomInt(#basic_recipes, rng, false, true)
			if i <= 7 then
				table.insert(list, basic_recipes[rand])
			else
				local rand_q1 = Maths:RandomInt(3, rng, false, true)
				if rand_q1 == 1 then
					table.insert(list, q1_recipes[Maths:RandomInt(#q1_recipes, rng, false, true)])
				elseif rand_q1 == 2 then
					table.insert(list, special_recipes[Maths:RandomInt(#special_recipes, rng, false, true)])
				else
					table.insert(list, basic_recipes[rand])
				end
			end
		end
	elseif quality == 2 then
		for i = 1, 8 do
			local rand = Maths:RandomInt(#basic_recipes, rng, false, true)
			if i <= 5 then
				table.insert(list, basic_recipes[rand])
			elseif i <= 7 then
				if i == 7 and Maths:RandomInt(1, rng, true, false) == 0 then
					table.insert(list, special_recipes[Maths:RandomInt(#special_recipes, rng, false, true)])
				else
					table.insert(list, q2_recipes[Maths:RandomInt(#q2_recipes, rng, false, true)])
				end
			else
				if Maths:RandomInt(1, rng, true, false) == 0 then
					table.insert(list, q1_recipes[Maths:RandomInt(#q1_recipes, rng, false, true)])
				else
					table.insert(list, basic_recipes[rand])
				end
			end
		end
	elseif quality == 3 then
		for i = 1, 8 do
			local rand = Maths:RandomInt(#basic_recipes, rng, false, true)
			if i <= 3 then
				table.insert(list, basic_recipes[rand])
			elseif i <= 7 then
				if i == 7 and Maths:RandomInt(1, rng, true, false) == 0 then
					table.insert(list, special_recipes[Maths:RandomInt(#special_recipes, rng, false, true)])
				else
					table.insert(list, q3_recipes[Maths:RandomInt(#q3_recipes, rng, false, true)])
				end
			else
				local rand_q1 = Maths:RandomInt(3, rng, false, true)
				if rand_q1 == 1 then
					table.insert(list, q1_recipes[Maths:RandomInt(#q1_recipes, rng, false, true)])
				elseif rand_q1 == 2 then
					table.insert(list, {Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_SOUL,})
				else
					table.insert(list, basic_recipes[rand])
				end
			end
		end
	else
		for i = 1, 8 do
			local rand_q4 = Maths:RandomInt(#q4_recipes, rng, false, true)
			if i <= 5 then
				table.insert(list, q4_recipes[rand_q4])
			elseif i == 6 then
				table.insert(list, basic_recipes[Maths:RandomInt(#basic_recipes, rng, false, true)])
			elseif i == 7 then
				if Maths:RandomInt(1, rng, true, false) == 0 then
					table.insert(list, special_recipes[Maths:RandomInt(#special_recipes, rng, false, true)])
				else
					table.insert(list, q3_recipes[Maths:RandomInt(#q3_recipes, rng, false, true)])
				end
			else
				local rand_q1 = Maths:RandomInt(3, rng, false, true)
				if rand_q1 == 1 then
					table.insert(list, q1_recipes[Maths:RandomInt(#q1_recipes, rng, false, true)])
				elseif rand_q1 == 2 then
					table.insert(list, {Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_SOUL,})
				else
					table.insert(list, basic_recipes[Maths:RandomInt(#basic_recipes, rng, false, true)])
				end
			end
		end
	end
	return list
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
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.MOM_FOOT_STOMP, 0, player.Position, Vector(0, 0), nil)
			else
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_SUPERTROLL, player.Position, Vector(0, 0), nil)
			end
		else
			player:UseActiveItem(CollectibleType.COLLECTIBLE_POOP)
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
		local collectible_type
		if player_type == PlayerType.PLAYER_CAIN_B then
			local awarding_recipes_list = WormholeApple:GetAwardingRecipesList(player, rng, quality)
			for _, recipe in ipairs(awarding_recipes_list) do
				Isaac.Spawn(EntityType.ENTITY_PICKUP, recipe.Variant, recipe.SubType, player.Position, RandomVector() * 5, nil)
			end
		else
			collectible_type = Tools:RandomCollectible_ByQuality(player, quality, rng, true)
		end
		local bonus_rand = Maths:RandomInt(10, rng, true, false)
		if bonus_rand == 0 then
			if real_score == 1 then
				if collectible_type and (not player:HasCollectible(CollectibleType.COLLECTIBLE_CONSOLATION_PRIZE, true)) then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_CONSOLATION_PRIZE, Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil)
				end
			elseif real_score == 5 then
				if not player:HasTrinket(TrinketType.TRINKET_PERFECTION, true) then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_PERFECTION, player.Position, RandomVector() * 5, nil)
				end
			end
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
			player:AddWisp(CollectibleType.COLLECTIBLE_UNDEFINED, player.Position)
		end
	end
end
--[[
WormholeApple.CharacterThatCannotPickItems = {}

function WormholeApple:IsCharacterThatCannotPickItems(player_type)
	return Common:IsInTable(player_type, self.CharacterThatCannotPickItems)
end

function WormholeApple:AddCharacterThatCannotPickItems(player_type)
	if not WormholeApple:IsCharacterThatCannotPickItems(player_type) then
		table.insert(self.CharacterThatCannotPickItems, player_type)
	end
end
]]
return WormholeApple_META