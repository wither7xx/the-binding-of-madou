--感谢 @傷心船Sadship 提供的道具创意
local Main = {}
local WormholeApple = include("scripts/items/collectibles/c003_wormhole_apple/c003_wormhole_apple_api")
local ModRef = tbom

local Common = tbom.Global.Common
local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths
local Translation = tbom.Global.Translation

local Fonts = tbom.Fonts
local tbomCallbacks = tbom.tbomCallbacks
local modCollectibleType = tbom.modCollectibleType

local Magic = tbom.Magic
local MagicFlag = Magic.MagicFlag

local CollectiblePhase = WormholeApple.CollectiblePhase
local QuestionDifficulty = WormholeApple.QuestionDifficulty
local InputCharKey = WormholeApple.InputCharKey
local WormholeAppleTexts = WormholeApple.Texts

function Main:OnUse(collectible_type, rng, player, use_flags, active_slot, custom_var_data)
	local show_anim = true
	local discharge = true
	local phase = WormholeApple:GetPhase(player)
	if phase == CollectiblePhase.PHASE_STANDBY then
		if use_flags & (UseFlag.USE_CARBATTERY | UseFlag.USE_VOID) == 0 then
			WormholeApple:Compose(player, rng)
			--print("test_standby")
			WormholeApple:SetPhase(player, CollectiblePhase.PHASE_WELCOME)
		end
	elseif phase == CollectiblePhase.PHASE_WELCOME then
		show_anim = false
		discharge = false
		--if use_flags & UseFlag.USE_CARBATTERY == 0 then
		--	WormholeApple:SetPhase(player, CollectiblePhase.PHASE_QUIZZING)
		--end
	elseif phase == CollectiblePhase.PHASE_QUIZZING then
		--WormholeApple:SetAdditionalCountdown(player, 180)
		show_anim = false
		discharge = false
	elseif (phase == CollectiblePhase.PHASE_HANDING_IN or phase == CollectiblePhase.PHASE_FORCED_HANDED_IN) and WormholeApple:GetAdditionalCountdown(player) > 0 then
		WormholeApple:SetAdditionalCountdown(player, 0)
		WormholeApple:Award(player)
		WormholeApple:Compose(player)
		WormholeApple:SetCountdown(player, 0)
		WormholeApple:SetPhase(player, CollectiblePhase.PHASE_WELCOME)
	end
	return {ShowAnim = show_anim, Remove = false, Discharge = discharge}
end
ModRef:AddCallback(ModCallbacks.MC_USE_ITEM, Main.OnUse, modCollectibleType.COLLECTIBLE_WORMHOLE_APPLE)

local InputCharFunc = {}
InputCharFunc[InputCharKey.KEY_UNM] = function (player)
	WormholeApple:TextBox_TriggerNegativeNumber(player)
end

InputCharFunc[InputCharKey.KEY_DOT] = function (player)
	WormholeApple:TextBox_TryAddDot(player)
end

InputCharFunc[InputCharKey.KEY_BACKSPACE] = function (player)
	WormholeApple:RemoveRearCharFromTextBox(player)
end

InputCharFunc[InputCharKey.KEY_RETURN] = function (player)
	--local phase = WormholeApple:GetPhase(player)
	--if phase == CollectiblePhase.PHASE_QUIZZING then
		local answer = WormholeApple:GetTextBox(player)
		--if WormholeApple:GetCountdown(player) > 0 then
			WormholeApple:Submit(player, answer, false)
		--end
	--end
end

InputCharFunc[InputCharKey.KEY_CLEAR] = function (player)
	WormholeApple:ResetTextBox(player)
end

local function GetTiggeredKey(player)
	local controller_idx = player.ControllerIndex
	local key = {
		[InputCharKey.KEY_1] = Input.IsButtonTriggered(Keyboard.KEY_1, controller_idx),
		[InputCharKey.KEY_2] = Input.IsButtonTriggered(Keyboard.KEY_2, controller_idx),
		[InputCharKey.KEY_3] = Input.IsButtonTriggered(Keyboard.KEY_3, controller_idx),
		[InputCharKey.KEY_4] = Input.IsButtonTriggered(Keyboard.KEY_4, controller_idx),
		[InputCharKey.KEY_5] = Input.IsButtonTriggered(Keyboard.KEY_5, controller_idx),
		[InputCharKey.KEY_6] = Input.IsButtonTriggered(Keyboard.KEY_6, controller_idx),
		[InputCharKey.KEY_7] = Input.IsButtonTriggered(Keyboard.KEY_7, controller_idx),
		[InputCharKey.KEY_8] = Input.IsButtonTriggered(Keyboard.KEY_8, controller_idx),
		[InputCharKey.KEY_9] = Input.IsButtonTriggered(Keyboard.KEY_9, controller_idx),
		[InputCharKey.KEY_0] = Input.IsButtonTriggered(Keyboard.KEY_0, controller_idx),
		[InputCharKey.KEY_UNM] = Input.IsButtonTriggered(Keyboard.KEY_MINUS, controller_idx),
		[InputCharKey.KEY_DOT] = Input.IsButtonTriggered(Keyboard.KEY_PERIOD, controller_idx),
		[InputCharKey.KEY_BACKSPACE] = Input.IsButtonTriggered(Keyboard.KEY_BACKSPACE, controller_idx),
		[InputCharKey.KEY_RETURN] = Input.IsButtonTriggered(Keyboard.KEY_ENTER, controller_idx),
		[InputCharKey.KEY_CLEAR] = Input.IsButtonTriggered(Keyboard.KEY_EQUAL, controller_idx),
	}
	for i = 1, InputCharKey.NUM_INPUT_CHAR do
		if key[i] then
			return i
		end
	end
	return nil
end

local function TiggerInputCharKey(player, current_input_char_key)
	if InputCharFunc[current_input_char_key] ~= nil then
		InputCharFunc[current_input_char_key](player)
	elseif current_input_char_key > 0 and current_input_char_key <= InputCharKey.NUM_NUMBER_CHAR then
		WormholeApple:AddCharToTextBoxRear(player, current_input_char_key % InputCharKey.NUM_NUMBER_CHAR)
	end
end

function Main:OnUpdate(player)
	WormholeApple:WormholeAppleDataInit(player)

	local phase = WormholeApple:GetPhase(player)
	local offset_key = "WormholeApple"
	if phase == CollectiblePhase.PHASE_WELCOME or phase == CollectiblePhase.PHASE_QUIZZING then
		if WormholeApple:GetRemainingQuestionNum(player) > 0 then
		--	WormholeApple:SetPhase(player, CollectiblePhase.PHASE_HANDING_IN)
		--else
			local controller_idx = player.ControllerIndex
			if WormholeApple:CanAnswerQuestion(player) then
				Magic:AddFlag(player, MagicFlag.FLAG_NUMBER_KEY_DISABLED)
				if Tools:GetUserNum() > 1 then
					Magic:AddSpellIconAreaOffset(player, offset_key, 0, 80)
					Magic:AddSpellTextAreaOffset(player, offset_key, 0, 140)
				end
				if Input.IsActionTriggered(ButtonAction.ACTION_ITEM, controller_idx) then
					local current_input_char_key = WormholeApple:GetCurrentInputCharKey(player)
					TiggerInputCharKey(player, current_input_char_key)
				end
				if controller_idx == 0 and GetTiggeredKey(player) ~= nil then
					local current_input_char_key = GetTiggeredKey(player)
					TiggerInputCharKey(player, current_input_char_key)
				end
				if Input.IsActionTriggered(ButtonAction.ACTION_SHOOTLEFT, controller_idx) then
					WormholeApple:MoveCurrentInputCharKey_Lift(player)
				elseif Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, controller_idx) then
					WormholeApple:MoveCurrentInputCharKey_Right(player)
				end
				if Input.IsActionTriggered(ButtonAction.ACTION_SHOOTUP, controller_idx) then
					WormholeApple:MoveCurrentInputCharKey_Up(player)
				elseif Input.IsActionTriggered(ButtonAction.ACTION_SHOOTDOWN, controller_idx) then
					WormholeApple:MoveCurrentInputCharKey_Down(player)
				end
			--else
				--Magic:ClearFlag(player, MagicFlag.FLAG_NUMBER_KEY_DISABLED)
			end
		end
	else
		--Magic:ClearFlag(player, MagicFlag.FLAG_NUMBER_KEY_DISABLED)
		if Tools:GetUserNum() > 1 then
			Magic:RemoveSpellIconAreaOffset(player, offset_key)
			Magic:RemoveSpellTextAreaOffset(player, offset_key)
		end
		if phase == CollectiblePhase.PHASE_HANDING_IN or phase == CollectiblePhase.PHASE_FORCED_HANDED_IN then
			if WormholeApple:GetAdditionalCountdown(player) == 0 and WormholeApple:CanAnswerQuestion(player, true) then
				WormholeApple:Award(player)
				WormholeApple:Compose(player)
				WormholeApple:SetCountdown(player, 0)
				WormholeApple:SetPhase(player, CollectiblePhase.PHASE_STANDBY)
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Main.OnUpdate, 0)

local function GetGhostItemNum(player)
	local sum = 0
	local ghost_collectible_list = {
		CollectibleType.COLLECTIBLE_OUIJA_BOARD,
		CollectibleType.COLLECTIBLE_SPIRIT_OF_THE_NIGHT,
		CollectibleType.COLLECTIBLE_GHOST_BABY,
		CollectibleType.COLLECTIBLE_LIL_HAUNT,
		CollectibleType.COLLECTIBLE_GHOST_PEPPER,
		CollectibleType.COLLECTIBLE_LOST_SOUL,
		CollectibleType.COLLECTIBLE_PURGATORY,
		CollectibleType.COLLECTIBLE_SPIRIT_SHACKLES,
		CollectibleType.COLLECTIBLE_ASTRAL_PROJECTION,
		CollectibleType.COLLECTIBLE_HUNGRY_SOUL,
		CollectibleType.COLLECTIBLE_GHOST_BOMBS,
	}
	local ghost_trinket_list = {
		TrinketType.TRINKET_SOUL,
		TrinketType.TRINKET_FOUND_SOUL,
	}
	for _, collectible_type in ipairs(ghost_collectible_list) do
		if player:HasCollectible(collectible_type) then
			sum = sum + 1
		end
	end
	for _, trinket_type in ipairs(ghost_trinket_list) do
		if player:HasTrinket(trinket_type) then
			sum = sum + 1
		end
	end
	return sum
end

function Main:UpdateGhostPoint(player)
	local base_point = 0
	local player_type = player:GetPlayerType()
	local ghost_character_list = {
		PlayerType.PLAYER_THELOST,
		PlayerType.PLAYER_THESOUL,
		PlayerType.PLAYER_THELOST_B,
		PlayerType.PLAYER_JACOB2_B,
		PlayerType.PLAYER_THESOUL_B,
	}
	if Common:IsInTable(player_type, ghost_character_list) then
		base_point = base_point + 3
	end
	base_point = base_point + GetGhostItemNum(player)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_VADE_RETRO) then
		base_point = base_point - 3
	end
	local nearest_ghost_dis = WormholeApple:GetNearestGhostDistance(player)
	base_point = base_point + (math.max(0, 300 - nearest_ghost_dis) / 60)
	WormholeApple:SetGhostPoint(player, base_point)
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Main.UpdateGhostPoint, 0)

local SymbolSprite = {
	["root"] = Sprite(),
	["integ"] = Sprite(),
	["part"] = Sprite(),
	["inf"] = Sprite(),
}
--{root} {root_end}  //根号
--{integ} {integ_end}//积分符号
--{part} {part_end} //偏微分符号
--{inf} {inf_end}  //无穷
SymbolSprite["root"]:Load("gfx/tbom/texts/mathematical_symbol.anm2")
SymbolSprite["root"]:Play("Radical")
SymbolSprite["integ"]:Load("gfx/tbom/texts/mathematical_symbol.anm2")
SymbolSprite["integ"]:Play("Integral")
SymbolSprite["part"]:Load("gfx/tbom/texts/mathematical_symbol.anm2")
SymbolSprite["part"]:Play("Partial")
SymbolSprite["inf"]:Load("gfx/tbom/texts/mathematical_symbol.anm2")
SymbolSprite["inf"]:Play("Infinite")

local TextModifier = {}
TextModifier["num"] = function (text_data)
	text_data.UsedFont = Fonts["number"]
end

TextModifier["cjk"] = function (text_data)
	text_data.UsedFont = Fonts["zh"]
end

TextModifier["up"] = function (text_data)
	text_data.SelfPosOffset.Y = text_data.SelfPosOffset.Y - 4
end

TextModifier["down"] = function (text_data)
	text_data.SelfPosOffset.Y = text_data.SelfPosOffset.Y + 4
end

TextModifier["sps"] = function (text_data)
	text_data.Scale.X = text_data.Scale.X * 0.8
	text_data.Scale.Y = text_data.Scale.Y * 0.8
	text_data.SelfPosOffset.Y = text_data.SelfPosOffset.Y - 3
end

TextModifier["sbs"] = function (text_data)
	text_data.Scale.X = text_data.Scale.X * 0.8
	text_data.Scale.Y = text_data.Scale.Y * 0.8
	text_data.SelfPosOffset.Y = text_data.SelfPosOffset.Y + 5
end

TextModifier["leftdown"] = function (text_data)
	text_data.SelfPosOffset.X = text_data.SelfPosOffset.X - 5
	text_data.SelfPosOffset.Y = text_data.SelfPosOffset.Y + 5
end

TextModifier["lightblue"] = function (text_data)
	text_data.UsedKColor.Red = 0.5
	text_data.UsedKColor.Green = 0.5
end

TextModifier["grey"] = function (text_data)
	text_data.UsedKColor.Red = 0.5
	text_data.UsedKColor.Green = 0.5
	text_data.UsedKColor.Blue = 0.5
end

local function HasMark(list, mark, idx)
	if list[mark] then
		for _, range in ipairs(list[mark]) do
			if idx >= range.X and idx <= range.Y then
				return true
			end
		end
	end
	return false
end

local RenderFlash = 0

local function VerbatimRender(player, texts, pos)
	local lang = Translation:FixLanguage(Options.Language)
	local font = Fonts[lang]
	local font_num = Fonts["number"]
	for i = 1, #texts do
		local text = texts[i]
		local text_ini = 1
		local PrefixList = {}		--前缀列表（字符串数组），影响整行字
		local MarkList = {}			--标记列表，标示所含有的标记及其范围（散列表，键为标记名称，对应值为矢量数组（标示范围）），影响单字
		local TextDataList = {}
		--统计前缀
		local prefix_idx = 1
		while prefix_idx <= string.len(text) do
			local chr = string.sub(text, prefix_idx, prefix_idx)
			if chr ~= "<" then
				break
			end
			local prefix_ini = string.find(text, "<", prefix_idx)
			local prefix_fin = string.find(text, ">", prefix_idx)
			local colon_pos = string.find(text, ":", prefix_idx)
			if prefix_ini and prefix_fin then
				local prefix = string.sub(text, prefix_ini + 1, prefix_fin - 1)
				local param
				if colon_pos and colon_pos > prefix_ini and colon_pos < prefix_fin then
					param = string.sub(text, colon_pos + 1, prefix_fin - 1)
					prefix = string.sub(text, prefix_ini + 1, colon_pos - 1)
				end
				local value = true
				if param then
					value = param
				end
				PrefixList[prefix] = value
				prefix_idx = prefix_fin
				text_ini = prefix_fin + 1
			else
				break
			end
			prefix_idx = prefix_idx + 1
		end
		--统计所含标记及其范围
		local text_sub = string.sub(text, text_ini)
		local length = Common:UTF8_strlen(text_sub)
		local real_text = ""
		local real_idx = 1
		local idx = 1
		while idx <= length do
			local chr = Common:UTF8_sub(text_sub, idx, idx)
			local escape_chr = Common:UTF8_sub(text_sub, idx, idx + 1)
			local mark_fin = Common:UTF8_simplyfind(text_sub, "}", idx)
			local _, prev_mark_fin = Common:UTF8_simplyfind(text_sub, "_end}", idx)
			if chr == "{" and mark_fin and escape_chr ~= "{{" then		--规定：标记一律表示为"{mark}xxx{mark_end}"；若向右匹配失败则认为范围向右延伸至字符串末尾，若向左匹配失败则跳过；"{{"为转义字符，表示大括号"{"
				if mark_fin ~= prev_mark_fin then
					local new_mark = Common:UTF8_sub(text_sub, idx + 1, mark_fin - 1)
					local new_mark_fin_str = "{" .. new_mark .. "_end}"
					local mark_ini2, mark_fin2 = Common:UTF8_simplyfind(text_sub, new_mark_fin_str, idx)
					local range = Vector(real_idx, real_idx - 1)
					if mark_ini2 and mark_fin2 then
						local range_idx = mark_fin + 1
						while Common:UTF8_simplyfind(text_sub, new_mark_fin_str, range_idx) do
							if Common:UTF8_sub(text_sub, range_idx, range_idx) == "{" and Common:UTF8_sub(text_sub, range_idx, range_idx + 1) ~= "{{" then
								local range_mark_fin = Common:UTF8_simplyfind(text_sub, "}", range_idx)
								local _, range_mark_fin2 = Common:UTF8_simplyfind(text_sub, new_mark_fin_str, range_idx - 1)
								if range_mark_fin then
									if range_mark_fin == range_mark_fin2 then
										break
									else
										range_idx = range_mark_fin
									end
								else
									range.Y = range.Y + 1
								end
							else
								range.Y = range.Y + 1
							end
							range_idx = range_idx + 1
						end
					else
						range.Y = length
					end
					MarkList[new_mark] = MarkList[new_mark] or {}
					table.insert(MarkList[new_mark], range)
					idx = mark_fin
				else
					idx = prev_mark_fin
				end
			else
				if escape_chr == "{{" then
					real_text = real_text .. "{"
					idx = idx + 1
				else
					real_text = real_text .. chr
				end
				local new_data = {
					UsedFont = font,
					Scale = Vector(1, 1),
					GlobalPosOffset = Vector(0, 0),
					SelfPosOffset = Vector(0, 0),
					UsedKColor = KColor(1, 1, 1, 0.8),
				}
				table.insert(TextDataList, new_data)
				real_idx = real_idx + 1
			end
			idx = idx + 1
		end
		local real_text_width = 0
		local real_length = Common:UTF8_strlen(real_text)
		for j = 1, real_length do
			local chr = Common:UTF8_sub(real_text, j, j)
			local text_data = TextDataList[j]
			for mark, _ in pairs(MarkList) do
				if HasMark(MarkList, mark, j) and TextModifier[mark] ~= nil then
					TextModifier[mark](text_data)
				end
			end
			text_data.GlobalPosOffset.X = real_text_width
			real_text_width = real_text_width + text_data.UsedFont:GetStringWidthUTF8(chr)
		end

		local base_offset_X = pos.X - 8 * 9.75
		local base_offset_Y = pos.Y - 60 - 15 * #texts + i * 15
		if PrefixList["center"] then
			local param_offset = tonumber(PrefixList["center"]) or 0
			base_offset_X = pos.X - (real_text_width / 2) + param_offset
		end
		if PrefixList["down"] then
			local param_offset = tonumber(PrefixList["down"]) or i
			base_offset_Y = pos.Y + param_offset * 15
		end
		if PrefixList["right"] then
			local param_offset = tonumber(PrefixList["right"]) or 0
			base_offset_X = pos.X + 30 + param_offset
			base_offset_Y = pos.Y - 50 + i * 15
		end

		for j = 1, real_length do
			local chr = Common:UTF8_sub(real_text, j, j)
			local text_data = TextDataList[j]
			local used_font = text_data.UsedFont
			local text_pos = text_data.GlobalPosOffset + text_data.SelfPosOffset
			local shake_offset = Vector(0, 0)
			local ghost_point = WormholeApple:GetGhostPoint(player)
			--print(ghost_point)
			--local shake_offset = RandomVector() * (WormholeApple:GetGhostPoint(player) / 0.5) 
			if ghost_point > 0 and (not Game():IsPaused()) then
				shake_offset = RandomVector() * (math.min(ghost_point, 13) / 13)
			end
			local used_kcolor = text_data.UsedKColor
			if PrefixList["flash"] == "red" then
				local render_flash_value = 1 - math.abs(math.sin(RenderFlash * (math.pi / 60)))
				used_kcolor.Green = render_flash_value
				used_kcolor.Blue = render_flash_value
			elseif PrefixList["flash"] == "green" then
				local render_flash_value = 1 - math.abs(math.sin(RenderFlash * (math.pi / 60)))
				used_kcolor.Red = render_flash_value
				used_kcolor.Blue = render_flash_value
			end
			local vec = Vector(base_offset_X + text_pos.X + shake_offset.X, base_offset_Y + text_pos.Y + shake_offset.Y)
			used_font:DrawStringScaledUTF8(chr, vec.X, vec.Y, text_data.Scale.X, text_data.Scale.Y, used_kcolor, 0, false)

			for mark, sprite in pairs(SymbolSprite) do
				if HasMark(MarkList, mark, j) then
					sprite.Color = Color(used_kcolor.Red, used_kcolor.Green, used_kcolor.Blue, used_kcolor.Alpha)
					sprite.Scale = text_data.Scale
					sprite:Render(Vector(vec.X - used_font:GetStringWidthUTF8(" "), vec.Y + 1.2))
				end
			end
			--[[
			if HasMark(MarkList, "root", j) then
				--{root} {root_end}  //
				SymbolSprite["root"].Color = Color(used_kcolor.Red, used_kcolor.Green, used_kcolor.Blue, used_kcolor.Alpha)
				SymbolSprite["root"].Scale = text_data.Scale
				SymbolSprite["root"]:Render(Vector(vec.X - used_font:GetStringWidthUTF8(" "), vec.Y + 1.2))
			end
			if HasMark(MarkList, "integ", j) then
				--{integ} {integ_end}//
				SymbolSprite["integ"].Color = Color(used_kcolor.Red, used_kcolor.Green, used_kcolor.Blue, used_kcolor.Alpha)
				SymbolSprite["integ"].Scale = text_data.Scale
				SymbolSprite["integ"]:Render(Vector(vec.X - used_font:GetStringWidthUTF8(" "), vec.Y + 1.2))
			end
			if HasMark(MarkList, "part", j) then
				--{part} {part_end} //
				SymbolSprite["part"].Color = Color(used_kcolor.Red, used_kcolor.Green, used_kcolor.Blue, used_kcolor.Alpha)
				SymbolSprite["part"].Scale = text_data.Scale
				SymbolSprite["part"]:Render(Vector(vec.X - used_font:GetStringWidthUTF8(" "), vec.Y + 1.2))
			end
			if HasMark(MarkList, "inf", j) then
				--{inf} {inf_end}  //
				SymbolSprite["inf"].Color = Color(used_kcolor.Red, used_kcolor.Green, used_kcolor.Blue, used_kcolor.Alpha)
				SymbolSprite["inf"].Scale = text_data.Scale
				SymbolSprite["inf"]:Render(Vector(vec.X - used_font:GetStringWidthUTF8(" "), vec.Y + 1.2))
			end
			]]
			--char_offset_X = char_offset_X + text_data.UsedFont:GetStringWidthUTF8(chr)
		end
	end
end

local function RenderInputChar(key, pos)
	local used_font = Fonts["number"]
	local input_char_list = {
		[InputCharKey.KEY_1] = "1",
		[InputCharKey.KEY_2] = "2",
		[InputCharKey.KEY_3] = "3",
		[InputCharKey.KEY_4] = "4",
		[InputCharKey.KEY_5] = "5",
		[InputCharKey.KEY_6] = "6",
		[InputCharKey.KEY_7] = "7",
		[InputCharKey.KEY_8] = "8",
		[InputCharKey.KEY_9] = "9",
		[InputCharKey.KEY_UNM] = "-",
		[InputCharKey.KEY_0] = "0",
		[InputCharKey.KEY_DOT] = ".",
		[InputCharKey.KEY_BACKSPACE] = "×",
		[InputCharKey.KEY_RETURN] = "→",
		[InputCharKey.KEY_CLEAR] = "C",
	}
	for r = 1, InputCharKey.NUM_INPUT_CHAR_ROW do
		for c = 1, InputCharKey.NUM_INPUT_CHAR_COL do
			local used_char_key = (r - 1) * InputCharKey.NUM_INPUT_CHAR_COL + c
			local used_kcolor = KColor(1, 1, 1, 0.8)
			if key == used_char_key then
				used_kcolor.Red = 0
				used_kcolor.Blue = 0
			end
			local base_offset_X = pos.X - 37 - 10 * InputCharKey.NUM_INPUT_CHAR_COL + c * 10
			local base_offset_Y = pos.Y - 45 + (r - 1) * 10
			used_font:DrawStringScaledUTF8(input_char_list[used_char_key], base_offset_X, base_offset_Y, 1, 1, used_kcolor, 0, false)
		end
	end
end

function Main:RenderText()
	local game = Game()
	if Tools:CanShowHUD() then
		local NumPlayers = game:GetNumPlayers()
		for p = 0, NumPlayers - 1 do
			local player = game:GetPlayer(p)
			local lang = Translation:FixLanguage(Options.Language)
			local wormhole_apple_text = WormholeApple.Texts
			local phase = WormholeApple:GetPhase(player)
			local pos = Tools:GetEntityRenderScreenPos(player)
			local additional_CD = WormholeApple:GetAdditionalCountdown(player)
			if (WormholeApple:CanAnswerQuestion(player) or phase == CollectiblePhase.PHASE_HANDING_IN or phase == CollectiblePhase.PHASE_FORCED_HANDED_IN) 
			and Game():GetRoom():GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT then
				local texts = {}
				local additional_texts = {}
				local remaining_question_num = WormholeApple:GetRemainingQuestionNum(player)
				local countdown = math.ceil(WormholeApple:GetCountdown(player) / 60)
				local remain_texts = wormhole_apple_text.Remain[lang](remaining_question_num, countdown)
				local answer_text = wormhole_apple_text.Answer[lang](WormholeApple:GetTextBox(player))
				if phase == CollectiblePhase.PHASE_WELCOME then
					texts = wormhole_apple_text.Welcome[lang]
					additional_texts = Common:ConcatArrays(answer_text, remain_texts)
					RenderInputChar(WormholeApple:GetCurrentInputCharKey(player), pos)
				elseif phase == CollectiblePhase.PHASE_QUIZZING then
					local question = WormholeApple:GetCurrentQuestion(player)
					if question and question.Texts then
						texts = question:Texts(player, lang)
					end
					additional_texts = Common:ConcatArrays(answer_text, remain_texts)
					--if WormholeApple:GetAdditionalCountdown(player) > 0 then
					--	local error_texts = wormhole_apple_text.Error[lang]
					--	VerbatimRender(player, error_texts, pos)
					--end
					RenderInputChar(WormholeApple:GetCurrentInputCharKey(player), pos)
				elseif phase == CollectiblePhase.PHASE_HANDING_IN and additional_CD > 0 then
					texts = wormhole_apple_text.HandingIn[lang]
				elseif phase == CollectiblePhase.PHASE_FORCED_HANDED_IN and additional_CD > 0 then
					texts = wormhole_apple_text.ForcedHandedIn[lang]
				end
				VerbatimRender(player, texts, pos)
				--local texts_pos_offset = Vector(0, 0)
				--if Tools:GetUserNum() > 1 then
				--	texts_pos_offset = Vector(30, -45)
				--else
				--	for i, str in ipairs(additional_texts) do
				--		str = "<center>" .. str
				--	end
				--end
				--local texts_pos_offset = Vector(30, -45)
				VerbatimRender(player, additional_texts, pos)
			end
		end
	end
end
--ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, WormholeApple.RenderText)
ModRef:AddCallback(ModCallbacks.MC_POST_RENDER, Main.RenderText)

--[[
function WormholeApple:Input_PostPlayerUpdate(player)
	--local NumPlayers = Game():GetNumPlayers()
	if Magic:IsMageCharacter(player) then
		local TiggeredKey_Switch = Magic:Input_GetTiggeredKey_Switch(player)
		if TiggeredKey_Switch and (not Magic:HasFlag(player, MagicFlag.FLAG_CANNOT_SWITCH_SPELL)) then
			local try_enable = true
			local try_use = false
			if Magic:GetMagicType(TiggeredKey_Switch) == MagicType.SPECIAL then
				try_use = true
			end
			Magic:TrySwitchCurrentSpellKey(player, TiggeredKey_Switch, try_enable, try_use)
			Magic:SetChangeSpellCountDown(player, 120)
		end

		local TiggeredKey_Move = Magic:Input_GetTiggeredKey_Move(player)
		if TiggeredKey_Move ~= nil and (not Magic:HasFlag(player, MagicFlag.FLAG_NUMBER_KEY_DISABLED)) then
			Magic:TryMoveCurrentSpellKey(player, TiggeredKey_Move)
			Magic:SetChangeSpellCountDown(player, 120)
		end
	end
	if WormholeApple:CanAnswerQuestion(player) then
		local phase = WormholeApple:GetPhase(player)
		if phase == CollectiblePhase.PHASE_QUIZZING then
			
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, WormholeApple.Input_PostPlayerUpdate)
]]

function Main:UpdateOnRenderFrame()
	local game = Game()
	local NumPlayers = game:GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = game:GetPlayer(p)
		WormholeApple:ModifyCountdown(player, -1)
		
		local phase = WormholeApple:GetPhase(player)
		if phase == CollectiblePhase.PHASE_QUIZZING and WormholeApple:GetCountdown(player) == 0 then
			if WormholeApple:GetRemainingQuestionNum(player) > 0 then
				local answer = WormholeApple:GetTextBox(player)
				--print("test0")
				WormholeApple:Submit(player, answer, true)
			else
				if WormholeApple:CanAnswerQuestion(player) then
					WormholeApple:SetPhase(player, CollectiblePhase.PHASE_HANDING_IN)
				else
					WormholeApple:SetPhase(player, CollectiblePhase.PHASE_FORCED_HANDED_IN)
				end
				Magic:ClearFlag(player, MagicFlag.FLAG_NUMBER_KEY_DISABLED)
			end
		end
		if not game:IsPaused() then
			WormholeApple:ModifyAdditionalCountdown(player, -1)
		end
	end
	RenderFlash = (RenderFlash + 1) % 120
end
ModRef:AddCallback(ModCallbacks.MC_POST_RENDER, Main.UpdateOnRenderFrame)

local function TryForciblyHandIn(player)
	local phase = WormholeApple:GetPhase(player)
	if phase == CollectiblePhase.PHASE_QUIZZING then
		local remaining_question_num = WormholeApple:GetRemainingQuestionNum(player)
		WormholeApple:ModifyRealScore(player, -remaining_question_num)
		WormholeApple:SetAdditionalCountdown(player, 300)
		WormholeApple:SetPhase(player, CollectiblePhase.PHASE_FORCED_HANDED_IN)
	end
end

function Main:PostGameStarted(is_continued)
	if is_continued then
		local game = Game()
		local NumPlayers = game:GetNumPlayers()
		for p = 0, NumPlayers - 1 do
			local player = game:GetPlayer(p)
			TryForciblyHandIn(player)
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Main.PostGameStarted)

function Main:PostUpdate()
	Tools:TryCheckEsauJrData(TryForciblyHandIn)
end
ModRef:AddPriorityCallback(ModCallbacks.MC_POST_UPDATE, 10, Main.PostUpdate)

return Main