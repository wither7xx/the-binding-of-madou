local Questions = {}
local ModRef = tbom

local Common = tbom.Global.Common
local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths
local Translation = tbom.Global.Translation

local EquivalentInfinitesimalList = {}
EquivalentInfinitesimalList[1] = function (var)
	local data = {
		Text = "sin " .. var,
		Coef_num = 1,		--系数分子
		Coef_den = 1,		--系数分母
		Freq = 1,			--次数
		IsMonomial = true,	--是否为单项式
	}
	return data 
end

EquivalentInfinitesimalList[2] = function (var)
	local data = {
		Text = "tan " .. var,
		Coef_num = 1,
		Coef_den = 1,
		Freq = 1,
		IsMonomial = true,
	}
	return data 
end

EquivalentInfinitesimalList[3] = function (var)
	local data = {
		Text = "arcsin " .. var,
		Coef_num = 1,
		Coef_den = 1,
		Freq = 1,
		IsMonomial = true,
	}
	return data 
end

EquivalentInfinitesimalList[4] = function (var)
	local data = {
		Text = "arctan " .. var,
		Coef_num = 1,
		Coef_den = 1,
		Freq = 1,
		IsMonomial = true,
	}
	return data 
end

EquivalentInfinitesimalList[5] = function (var)
	local data = {
		Text = "e{sps}" .. var .. "{sps_end} - 1",
		Coef_num = 1,
		Coef_den = 1,
		Freq = 1,
	}
	return data 
end

EquivalentInfinitesimalList[6] = function (var, _, _, arg3)
	local data = {
		Text = Maths:Fix_Round(arg3) .. "{sps}" .. var .. "{sps_end} - 1",
		Coef_num = Maths:Fix_Round(math.log(arg3), 2),
		Coef_den = 1,
		Freq = 1,
	}
	return data 
end

EquivalentInfinitesimalList[7] = function (var)
	local data = {
		Text = "ln(1 + " .. var .. ")",
		Coef_num = 1,
		Coef_den = 1,
		Freq = 1,
		IsMonomial = true,
	}
	return data 
end

EquivalentInfinitesimalList[8] = function (var, _, _, arg3)		--变量名（字符串），略，略，大于1的正整数
	local arg3_text = "log{sbs}" .. Maths:Fix_Round(arg3) .. "{sbs_end}"
	if arg3 == 10 then
		arg3_text = "lg"
	end
	local data = {
		Text = arg3_text .. "(1 + " .. var .. ")",
		Coef_num = 1,
		Coef_den = Maths:Fix_Round(math.log(arg3), 2),
		Freq = 1,
		IsMonomial = true,
	}
	return data 
end

EquivalentInfinitesimalList[9] = function (var, arg1, arg2)		--变量名（字符串），正整数，任意非零整数
	local arg1_text = Maths:Fix_Round(arg1)
	if arg1 == 1 then
		arg1_text = ""
	end
	local arg2_text = tostring(Maths:Fix_Round(math.abs(arg2)))
	if math.abs(arg2) == 1 then
		arg2_text = ""
	end
	if arg2 > 0 then
		arg2_text = "+ " .. arg2_text
	else
		arg2_text = "- " .. arg2_text
	end
	local data = {
		Text = "(1 " .. arg2_text .. var .. "){sps}" .. arg1_text .. "{sps_end} - 1",
		Coef_num = arg1 * arg2,
		Coef_den = 1,
		Freq = 1,
	}
	return data 
end

EquivalentInfinitesimalList[10] = function (var, _, arg2, arg3)
	local arg3_text = Maths:Fix_Round(arg3)
	if arg3 == 2 then
		arg3_text = ""
	end
	local arg2_text = tostring(Maths:Fix_Round(math.abs(arg2)))
	if math.abs(arg2) == 1 then
		arg2_text = ""
	end
	if arg2 > 0 then
		arg2_text = "+ " .. arg2_text
	else
		arg2_text = "- " .. arg2_text
	end
	local data = {
		Text = "{sps}" .. arg3_text .. "{sps_end}{root} {root_end}  (1 " .. arg2_text .. var .. ") - 1",
		Coef_num = arg2,
		Coef_den = arg3,
		Freq = 1,
		IsMonomial = true,
	}
	return data 
end

EquivalentInfinitesimalList[11] = function (var)
	local data = {
		Text = "ln(" .. var .. " + {root} {root_end}  (1 + " .. var .. "{sps}2{sps_end}))",
		Coef_num = 1,
		Coef_den = 1,
		Freq = 1,
		IsMonomial = true,
	}
	return data 
end
local Freq1EINum = 11

EquivalentInfinitesimalList[12] = function (var)
	local data = {
		Text = "1 - cos " .. var,
		Coef_num = 1,
		Coef_den = 2,
		Freq = 2,
	}
	return data 
end

EquivalentInfinitesimalList[13] = function (var)
	local data = {
		Text = "x - ln(1 + " .. var .. ")",
		Coef_num = 1,
		Coef_den = 2,
		Freq = 2,
	}
	return data 
end

EquivalentInfinitesimalList[14] = function (var)
	local data = {
		Text = "tan " .. var .. " - " .. var,
		Coef_num = 1,
		Coef_den = 3,
		Freq = 3,
	}
	return data 
end

EquivalentInfinitesimalList[15] = function (var)
	local data = {
		Text = "arcsin " .. var .. " - " .. var,
		Coef_num = 1,
		Coef_den = 6,
		Freq = 3,
	}
	return data 
end

EquivalentInfinitesimalList[16] = function (var)
	local data = {
		Text = var .. " - sin " .. var,
		Coef_num = 1,
		Coef_den = 6,
		Freq = 3,
	}
	return data 
end

EquivalentInfinitesimalList[17] = function (var)
	local data = {
		Text = var .. " - arctan " .. var,
		Coef_num = 1,
		Coef_den = 3,
		Freq = 3,
	}
	return data 
end

EquivalentInfinitesimalList[18] = function (var)
	local data = {
		Text = "tan " .. var .. " - sin " .. var,
		Coef_num = 1,
		Coef_den = 2,
		Freq = 3,
	}
	return data 
end

Questions[1] = {
	argc = 8,
	argv = {
		["Default"] = {1, 1, 2, 1, 2, 3, 1, 1},		--正整数，任意非零整数，大于1的正整数，选用的等价无穷小序号（内层分母，分子，外层分母），极限值（任意正整数），可用对数值序号（1至3的正整数）
	},
	Weight = 2,
	Build = function (self, rng)
		local argc = self.argc
		local argv = {}
		local EI_IDList = {}
		for i = 1, 3 do
			local is_new = true
			local range = (#EquivalentInfinitesimalList)
			if i <= 2 then
				range = Freq1EINum
			end
			local rand = Maths:RandomInt(range, rng, false, true)
			if Common:IsInTable(rand, EI_IDList) then
				is_new = false
			else
				table.insert(EI_IDList, rand)
			end
			if not is_new then
				while Common:IsInTable(rand, EI_IDList) do
					rand = (rand % range) + 1
				end
				table.insert(EI_IDList, rand)
			end
		end
		for i = 1, 3 do
			if i <= 2 then
				argv[i] = Maths:RandomInt(4, rng, false, true)
				if i == 2 then
					argv[i] = argv[i] * Maths:RandomSign(rng, false)
				end
			elseif i == 3 then
				argv[i] = Maths:RandomInt_Inclined(3, rng)
			end
		end
		for idx, EI_ID in pairs(EI_IDList) do
			argv[idx + 3] = EI_ID
		end
		argv[7] = Maths:RandomInt_Inclined(4, rng)
		argv[8] = Maths:RandomInt(3, rng, false, true)
		if argv[3] == 2 then
			argv[8] = 1
		end
		return argv
	end,
	Update = function (self, player, rng)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.Build(self, rng)
	end,
	GetEIData = function (self, player)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or self.Build(self)
		local argv = self.argv[player_index]
		local var_list = {"x", "g(x)", "x"}
		local EI_data = {}
		local EI_text = {}
		for i = 1, 3 do
			local EI = EquivalentInfinitesimalList[argv[3 + i]]
			if EI and EI(var_list[i], argv[1], argv[2], argv[3]) then
				local data = EI(var_list[i], argv[1], argv[2], argv[3])
				EI_data[i] = data
				EI_text[i] = data.Text
				if i == 1 and (not data.IsMonomial) then
					EI_text[i] = "(" .. data.Text .. ")"
				end
			else
				EI_data[i] = {
					Text = "x",
					Coef_num = 1,
					Coef_den = 1,
					Freq = 1,
				}
				EI_text[i] = "x"
			end
		end
		return EI_data, EI_text
	end,
	GetFinalCoef = function (self, player)
		local EI_data = self.GetEIData(self, player)
		local final_coef_num = 1
		local final_coef_den = 1
		for i = 1, 3 do
			local data = EI_data[i]
			if i <= 2 then
				final_coef_num = final_coef_num * data.Coef_num
				final_coef_den = final_coef_den * data.Coef_den
			else
				final_coef_num = final_coef_num * data.Coef_den
				final_coef_den = final_coef_den * data.Coef_num
			end
		end
		return final_coef_num, final_coef_den
	end,
	Texts = function (self, player, lang)
		local lang_fixed = Translation:FixLanguage(lang)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or self.Build(self)
		local argv = self.argv[player_index]
		local EI_data, EI_text = self.GetEIData(self, player)
		local final_freq_den = EI_data[3].Freq + 1
		local ln_text = ""
		for i = 1, 3 do
			local value = 1
			if argv[8] then
				value = argv[3] + i - argv[8]
			end
			if value >= 2 then
				ln_text = ln_text .. "ln" .. Maths:Fix_Round(value) .. " = " .. (Maths:Fix_Round(math.log(value), 2)) .. ", "
			end
		end
		local texts = {
			["zh"] = {
				"记{num}g(x) = ƒ(x)/" .. EI_text[1] .. "{num_end}，若：",
				"<center:8>{num}{down}" .. EI_text[2] .. "{down_end}{num_end}",
				"<center>{num}lim{sbs}x→0{sbs_end}———————————— = " .. Maths:Fix_Round(argv[7]) .. "{num_end}，",
				"<center:8>{num}{up}" .. EI_text[3] .. "{up_end}{num_end}",
				"则{num}lim{sbs}x→0{sbs_end}(ƒ(x)/x{sps}" .. final_freq_den .. "{sps_end}) = ?{num_end}",
				"<center>（取{num}" .. ln_text .. "{num_end}结果保留两位小数）",
			},
			["en"] = {
				"Consider {num}g(x) = ƒ(x)/" .. EI_text[1] .. "{num_end}. If",
				"<center:8>{num}{down}" .. EI_text[2] .. "{down_end}{num_end}",
				"<center>{num}lim{sbs}x→0{sbs_end}———————————— = " .. Maths:Fix_Round(argv[7]) .. "{num_end}, ",
				"<center:8>{num}{up}" .. EI_text[3] .. "{up_end}{num_end}",
				"find {num}lim{sbs}x→0{sbs_end}(ƒ(x)/x{sps}" .. final_freq_den .. "{sps_end}){num_end}.",
				"<center>(Please use {num}" .. ln_text .. "{num_end}",
				"<center>and round the result to two decimal places.)",
			},
		}	
		return texts[lang_fixed] or texts["en"]
	end,
	Answer = function (self, player)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or self.Build(self)
		local argv = self.argv[player_index]
		local final_coef_num, final_coef_den = self.GetFinalCoef(self, player)
		local result = argv[7] * final_coef_den / final_coef_num
		return Maths:Fix_Round(result, 2)
	end,
	Reset = function (self)
		for key, value in pairs(self.argv) do
			if key ~= "Default" then
				self.argv[key] = nil
			end
		end
	end,
}

Questions[2] = {
	argc = 9,
	argv = {
		["Default"] = {0, 0, 0, 0, 0, 0, 0, 0, 0},
	},
	Weight = 2,
	Build = function (self, rng)
		local argc = self.argc
		local argv = {}
		for i = 1, argc do
			argv[i] = Maths:RandomSign(rng, false) * Maths:RandomInt(9, rng, true, true)
		end
		return argv
	end,
	Update = function (self, player, rng)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.Build(self, rng)
	end,
	Texts = function (self, player, lang)
		local lang_fixed = Translation:FixLanguage(lang)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or self.Build(self)
		local argc = self.argc
		local argv = self.argv[player_index]
		local arg_text = {}
		for i = 1, argc do
			arg_text[i] = " " .. tostring(argv[i]) .. " "
			if argv[i] >= 0 then
				arg_text[i] = " " .. arg_text[i]
			end
		end
		local texts = {
			["zh"] = {
				"<center:22>{num}" .. arg_text[1] .. arg_text[2] .. arg_text[3] .. "{num_end}",
				"<center>设方阵{num}A = " .. arg_text[4] .. arg_text[5] .. arg_text[6] .. "{num_end}，",
				"<center:22>{num}" .. arg_text[7] .. arg_text[8] .. arg_text[9] .. "{num_end}",
				"<center>求{num}|A| = ?{num_end}",
			},
			["en"] = {
				"<center:58>{num}" .. arg_text[1] .. arg_text[2] .. arg_text[3] .. "{num_end}",
				"<center>Consider the matrix {num}A = " .. arg_text[4] .. arg_text[5] .. arg_text[6] .. "{num_end}, ",
				"<center:58>{num}" .. arg_text[7] .. arg_text[8] .. arg_text[9] .. "{num_end}",
				"<center>What is the value of {num}|A| ?{num_end}",
			},
		}	
		return texts[lang_fixed] or texts["en"]
	end,
	Answer = function (self, player)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or self.Build(self)
		local argv = self.argv[player_index]
		local matrix = {[1] = {}, [2] = {}, [3] = {}, }
		local idx = 1
		for i = 1, 3 do
			for j = 1, 3 do
				matrix[i][j] = argv[idx]
				idx = idx + 1
			end
		end
		return Maths:Determinant_3x3(matrix)
	end,
	Reset = function (self)
		for key, value in pairs(self.argv) do
			if key ~= "Default" then
				self.argv[key] = nil
			end
		end
	end,
}

Questions[3] = {
	argc = 10,
	argv = {
		["Default"] = {0, 1, 1, 0, 0, 0, 0, 0, 0, 0},	--积分下限，积分上限，变量系数，变量常数项，函数值，函数值，导数值，导数值，导数值，导数值
	},
	Weight = 1,
	Build = function (self, rng)
		local argc = self.argc
		local argv = {}
		argv[1] = Maths:RandomSign(rng, true) * Maths:RandomInt(31, rng, true, false)
		local arg2_sign = Maths:RandomSign(rng, true)
		if argv[1] < 0 then
			if arg2_sign >= 0 then
				argv[2] = arg2_sign * Maths:RandomInt(32, rng, true, false)
			else
				argv[2] = arg2_sign * Maths:RandomInt(argv[1], rng, true, false)
			end
		else
			argv[2] = Maths:RandomInt_Ranged(argv[1], 32, rng, false, false)
		end
		argv[3] = Maths:Fix_Round(Maths:RandomInt_Inclined(3, rng))
		argv[4] = Maths:RandomSign(rng, true) * Maths:RandomInt(31, rng, true, false)
		for i = 5, argc do
			local float_sign = Maths:RandomInt(1, rng, true, true)
			argv[i] = Maths:RandomSign(rng, false) * (Maths:RandomInt(31, rng, true, false) + Maths:Fix_Round(float_sign * Maths:RandomFloat(rng), 2))
			if float_sign == 0 then
				argv[i] = Maths:Fix_Round(argv[i])
			end
		end
		return argv
	end,
	Update = function (self, player, rng)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.Build(self, rng)
	end,
	Texts = function (self, player, lang)
		local lang_fixed = Translation:FixLanguage(lang)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or self.Build(self)
		local argc = self.argc
		local argv = self.argv[player_index]
		local arg4_text = ""
		if argv[4] > 0 then
			arg4_text = " + " .. arg4_text .. argv[4]
		elseif argv[4] < 0 then
			arg4_text = " - " .. arg4_text .. math.abs(argv[4])
		end
		local func_text = {
			[1] = "ƒ(" .. argv[3] * argv[1] .. ") = " .. argv[5] .. ", ",
			[2] = "ƒ(" .. argv[3] * argv[2] .. ") = " .. argv[6] .. ", ",
			[3] = "ƒ`(" .. argv[3] * argv[1] .. ") = " .. argv[7] .. ", ",
			[4] = "ƒ`(" .. argv[3] * argv[2] .. ") = " .. argv[8] .. ", ",
			[5] = "ƒ`(" .. argv[3] * argv[1] + argv[4] .. ") = " .. argv[9] .. ", ",
			[6] = "ƒ`(" .. argv[3] * argv[2] + argv[4] .. ") = " .. argv[10] .. ", ",
		}
		local func_text_cconcated = {
			[1] = func_text[1] .. func_text[2],
			[2] = func_text[4],
		}
		if argv[4] == 0 then
			func_text_cconcated[2] = func_text[3] .. func_text_cconcated[2]
		else
			func_text_cconcated[1] = func_text_cconcated[1] .. func_text[3]
			func_text_cconcated[2] = func_text_cconcated[2] .. func_text[5] .. func_text[6]
		end
		local texts = {
			["zh"] = {
				"<center>已知 {num}" .. func_text_cconcated[1] .. "{num_end}",
				"<center>{num}" .. func_text_cconcated[2] .. "{num_end}",
				"<center>则 {num}{integ} {integ_end}{sbs}" .. argv[1] .. "{sbs_end}{sps}" .. argv[2] .. "{sps_end}xƒ``(" .. argv[3] .. "x" .. arg4_text .. ")dx = ?{num_end}",
				"<center>（结果保留两位小数）",
			},
			["en"] = {
				"<center>Consider {num}" .. func_text[1] .. func_text[2] .. func_text[3] .. "{num_end}",
				"<center>{num}" .. func_text[4] .. func_text[5] .. func_text[6] .. "{num_end}",
				"<center>Find {num}{integ} {integ_end}{sbs}" .. argv[1] .. "{sbs_end}{sps}" .. argv[2] .. "{sps_end}xƒ{sps}``{sps_end}(" .. argv[3] .. "x" .. arg4_text .. ")dx .{num_end}",
				"<center>(Round the result to two decimal places.)",
			},
		}	
		return texts[lang_fixed] or texts["en"]
	end,
	Answer = function (self, player)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or self.Build(self)
		local argv = self.argv[player_index]
		local result = (argv[2] * argv[10] - argv[1] * argv[9] - ((argv[6] - argv[5]) / argv[3])) / argv[3]
		return Maths:Fix_Round(result, 2)
	end,
	Reset = function (self)
		for key, value in pairs(self.argv) do
			if key ~= "Default" then
				self.argv[key] = nil
			end
		end
	end,
}

Questions[4] = {
	argc = 1,
	argv = {
		["Default"] = {2},
	},
	Weight = 1,
	Build = function (self, rng)
		local argc = self.argc
		local argv = {}
		for i = 1, argc do
			argv[i] = Maths:Fix_Round(Maths:RandomInt_Inclined(3, rng))
		end
		return argv
	end,
	Update = function (self, player, rng)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.Build(self, rng)
	end,
	Texts = function (self, player, lang)
		local lang_fixed = Translation:FixLanguage(lang)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or self.Build(self)
		local argv = self.argv[player_index]
		local texts = {
			["zh"] = {
				"求： {num}{integ} {integ_end}{sbs}0{sbs_end}{sps}1{sps_end}(dx / {root} {root_end}  (1 - x{sps}1/" .. argv[1] .. "{sps_end})) = ?{num_end}",
				"<center>（取 {cjk}π{cjk_end}{num} = 3.14, {num_end}{root} {root_end}  {cjk}π{cjk_end}{num} = 1.77, {num_end}结果保留两位小数）",
			},
			["en"] = {
				"<center>Find {num}{integ} {integ_end}{sbs}0{sbs_end}{sps}1{sps_end}(dx / {root} {root_end}  (1 - x{sps}1/" .. argv[1] .. "{sps_end})){num_end}.",
				"<center>(Please use {cjk}π{cjk_end}{num} = 3.14, {num_end}{root} {root_end}  {cjk}π{cjk_end}{num} = 1.77, {num_end}",
				"<center>and round the result to two decimal places.)"
			},
		}	
		return texts[lang_fixed] or texts["en"]
	end,
	Answer = function (self, player)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or self.Build(self)
		local argv = self.argv[player_index]
		local result = argv[1] * Maths:Beta(argv[1], 0, false, true, 2)
		return Maths:Fix_Round(result, 2)
	end,
	Reset = function (self)
		for key, value in pairs(self.argv) do
			if key ~= "Default" then
				self.argv[key] = nil
			end
		end
	end,
}

Questions[5] = {
	argc = 2,
	argv = {
		["Default"] = {2, 1},		--大圆半径（小圆直径）（大于1的正整数），积分变量（半径）指数（正整数）
	},
	Weight = 1,
	Build = function (self, rng)
		local argc = self.argc
		local argv = {}
		argv[1] = Maths:Fix_Round(Maths:RandomInt_Inclined(2, rng))
		argv[2] = Maths:RandomInt(4, rng, false, false)
		return argv
	end,
	Update = function (self, player, rng)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.Build(self, rng)
	end,
	Texts = function (self, player, lang)
		local lang_fixed = Translation:FixLanguage(lang)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or self.Build(self)
		local argv = self.argv[player_index]
		local arg2_text = ""
		if argv[2] > 1 then
			arg2_text = "{sps}" .. arg2_text .. argv[2] .. "{sps_end}"
		end
		local texts = {
			["zh"] = {
				"<center>设平面区域 {num}D = {{(x, y) | 0 <= x <= " .. argv[1] .. ", {root} {root_end}  (" .. argv[1] .. "x - x{sps}2{sps_end}) <= y <= {root} {root_end}  (" .. Maths:Fix_Round(argv[1] ^ 2) .. " - x{sps}2{sps_end})},",
				"<center>求： {num}{integ}  {integ_end}{sbs}D{sbs_end}(x{sps}2{sps_end} + y{sps}2{sps_end})" .. arg2_text .. "d{num_end}{cjk}σ{cjk_end}{num} = ?{num_end}",
				"<center>（取 {cjk}π{cjk_end}{num} = 3.14, {num_end}结果保留两位小数）",
			},
			["en"] = {
				"<center>Consider the following plane region:",
				"<center>{num}D = {{(x, y) | 0 <= x <= " .. argv[1] .. ", {root} {root_end}  (" .. argv[1] .. "x - x{sps}2{sps_end}) <= y <= {root} {root_end}  (" .. Maths:Fix_Round(argv[1] ^ 2) .. " - x{sps}2{sps_end})}",
				"<center>Find {num}{integ}  {integ_end}{sbs}D{sbs_end}(x{sps}2{sps_end} + y{sps}2{sps_end})" .. arg2_text .. "d{num_end}{cjk}σ{cjk_end} .",
				"<center>(Please use {cjk}π{cjk_end}{num} = 3.14, {num_end}{num_end}",
				"<center>and round the result to two decimal places.)"
			},
		}	
		return texts[lang_fixed] or texts["en"]
	end,
	Answer = function (self, player)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or self.Build(self)
		local argv = self.argv[player_index]
		local radius_freq = 2 * argv[2] + 2		-- |J| = r，指数加1；转换为原函数时指数再加1
		local pi = 3.14
		local result = ((argv[1] ^ radius_freq) * (0.5 * pi - Maths:Wallis(radius_freq, 2)) / radius_freq)
		return Maths:Fix_Round(result, 2)
	end,
	Reset = function (self)
		for key, value in pairs(self.argv) do
			if key ~= "Default" then
				self.argv[key] = nil
			end
		end
	end,
}

Questions[6] = {
	argc = 1,
	argv = {
		["Default"] = {2},
	},
	Weight = 1,
	Build = function (self, rng)
		local argc = self.argc
		local argv = {}
		argv[1] = Maths:Fix_Round(Maths:RandomInt_Inclined(3, rng))
		return argv
	end,
	Update = function (self, player, rng)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.Build(self, rng)
	end,
	Texts = function (self, player, lang)
		local lang_fixed = Translation:FixLanguage(lang)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or self.Build(self)
		local argv = self.argv[player_index]
		local texts = {
			["zh"] = {
				"<center:27>{num}    1-x   x    0    0    0  {num_end}",
				"<center:27>{num}   -1   1-x   x    0    0  {num_end}",
				"<center>已知方阵{num} D =     0  -1   1-x   x    0  {num_end}",
				"<center:27>{num}     0    0  -1   1-x   x  {num_end}",
				"<center:27>{num}     0    0    0  -1   1-x {num_end}",
				"<center>其中{num} x = ".. argv[1] .. ", {num_end}则{num} |D| = ?{num_end}",
			},
			["en"] = {
				"<center>Consider the following matrix:",
				"<center:10>{num}    1-x   x    0    0    0  {num_end}",
				"<center:10>{num}   -1   1-x   x    0    0  {num_end}",
				"<center>{num} D =     0  -1   1-x   x    0  {num_end}",
				"<center:10>{num}     0    0  -1   1-x   x  {num_end}",
				"<center:10>{num}     0    0    0  -1   1-x {num_end}",
				"<center>If{num} x = ".. argv[1] .. ", {num_end}what is the value of{num} |D|{num_end} ?",
			},
		}	
		return texts[lang_fixed] or texts["en"]
	end,
	Answer = function (self, player)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or self.Build(self)
		local argv = self.argv[player_index]
		local result = 1
		for i = 1, 5 do
			result = result + ((-1) ^ i) * (argv[1] ^ i)
		end
		return result
	end,
	Reset = function (self)
		for key, value in pairs(self.argv) do
			if key ~= "Default" then
				self.argv[key] = nil
			end
		end
	end,
}


return Questions