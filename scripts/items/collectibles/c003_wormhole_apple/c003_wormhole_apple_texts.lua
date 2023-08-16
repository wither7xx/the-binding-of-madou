local Texts_META = {
	__index = {},
}
local Texts = Texts_META.__index

Texts.Welcome = {
	["zh"] = {
		"<center>各位考生你们好，欢迎参加普通高等学校招生全地下室统一考试",
		"<center>预祝你取得优异成绩",
		"<center>请在规定时间内回答以下问题，并在指定位置输入答案",
		--"<center>（仅支持输入数字、符号和小数点）",
		--"<center>（按下回车键即可提交答案，按下[掉落键]即可删去字符）",
		"<center>{lightblue}[射击键]{lightblue_end} - 选择字符  {lightblue}[使用键]{lightblue_end} - 输入选择的字符",
		"<center>{num}{grey}×{grey_end}{num_end} - 删除字符  {num}{grey}→{grey_end}{num_end} - 提交  {num}{grey}C{grey_end}{num_end} - 清空",
		"<center>（亦可使用键盘直接输入数字、符号等）{sps_end}",
		"<center>==提交任意字符即可开始答题==",
	},
	["en"] = {
		"<center>BASEMENT SCHOLASTIC APTITUDE TEST",
		"<center>MATHEMATICS",
		"<center>Please answer the following questions within",
		"<center>the designated time and input your responses.",
		"<center>{lightblue}[SHOOT]{lightblue_end} - Select Number  {lightblue}[ITEM]{lightblue_end} - Input Selected Number",
		"<center>{num}{grey}×{grey_end}{num_end} - Delete Number  {num}{grey}→{grey_end}{num_end} - Submit  {num}{grey}C{grey_end}{num_end} - Clear",
		"<center>{sps}(You can also input numbers directly using the keyboard.){sps_end}",
		"<center>PLEASE SUBMIT ANY TEXT TO START ANSWERING.",
	},
}

--[[
Texts.Error = {
	["zh"] = {
		"<down><flash:red>请先完成本次答题再进行新一轮答题！",
	},
	["en"] = {

	},
}
]]

Texts.HandingIn = {
	["zh"] = {
		"<center><flash:green>交卷成功，请领取奖励！",
	},
	["en"] = {

	},
}

Texts.ForcedHandedIn = {
	["zh"] = {
		"<center><flash:red>检测到中途退出考试，已自动交卷！",
	},
	["en"] = {

	},
}

Texts.Remain = {
	["zh"] = function (remaining_question_num, countdown)
		local texts = {
			"<right>剩余题目： {num}" .. remaining_question_num .. "{num_end}",
			"<right>剩余时间： {num}" .. countdown .. "{num_end}秒",
		}
		if countdown > 0 and countdown <= 10 then
			texts[2] = "<flash:red>" .. texts[2]
		end
		return texts
	end,
	["en"] = function (remaining_question_num, countdown)
		local texts = {
			"<right>Remain: {num}" .. remaining_question_num .. "{num_end}",
			"<right>Time: {num}" .. countdown .. "{num_end}s",
		}
		if countdown > 0 and countdown <= 10 then
			texts[2] = "<flash:red>" .. texts[2]
		end
		return texts
	end,
}

Texts.Answer = {
	["zh"] = function (text)
		local texts = {
			"<right>输入答案： {num}" .. text .. "_{num_end}",
		}
		return texts
	end,
	["en"] = function (text)
		local texts = {
			"<right>Ans.: {num}" .. text .. "_{num_end}",
		}
		return texts
	end,
}

return Texts_META