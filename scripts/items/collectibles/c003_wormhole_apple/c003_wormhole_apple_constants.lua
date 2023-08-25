local WormholeApple_META = {
	__index = {},
}
local WormholeApple = WormholeApple_META.__index

WormholeApple.CollectiblePhase = {
	PHASE_STANDBY = 0,
	PHASE_WELCOME = 1,
	PHASE_QUIZZING = 2,
	PHASE_HANDING_IN = 3,
	PHASE_FORCED_HANDED_IN = 4,
}

WormholeApple.QuestionDifficulty = {
	AMAKUCHI = 1,		--甘口（简单题）
	CHUUKARA = 2,		--中辛（中等题）
	KARAKUCHI = 3,		--辛口（困难题）
}

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

do
	local QuestionDifficulty = WormholeApple.QuestionDifficulty
	local path = "scripts/items/collectibles/c003_wormhole_apple/"
	WormholeApple.Texts = include(path .. "c003_wormhole_apple_texts")
	WormholeApple.Questions = {
		[QuestionDifficulty.AMAKUCHI] = include(path .. "question_bank/c003_questions_amakuchi"),
		[QuestionDifficulty.CHUUKARA] = include(path .. "question_bank/c003_questions_chuukara"),
		[QuestionDifficulty.KARAKUCHI] = include(path .. "question_bank/c003_questions_karakuchi"),
	}
end

return WormholeApple_META