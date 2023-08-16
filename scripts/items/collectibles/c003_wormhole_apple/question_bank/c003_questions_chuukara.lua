local Questions = {}

local Common = tbom.Global.Common
local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths
local Translation = tbom.Global.Translation

Questions[1] = {
	argc = 1,
	argv = {
		["Default"] = {1},
	},
	Weight = 1,
	Build = function (self, rng)
		local argc = self.argc
		local argv = {}
		argv[1] = Maths:RandomInt(2, rng, false, true)
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
		local arg_text = {
			[1] = "{num}e {sps}i{num_end} {cjk}π{cjk_end}{sps_end}",
			[2] = "{num}e {sps}i{num_end} {cjk}π{cjk_end}{sps_end} + 1",
		}
		local texts = {
			["zh"] = {
				"若{num}e{num_end}表示自然对数的底数，{num}i{num_end}表示虚数",
				"单位，{cjk}π{cjk_end}表示圆周率，则：",
				"<center>" .. arg_text[argv[1]] .. " = ?",
			},
			["en"] = {
				"If \"e\" represents the base of the",
				"natural logarithm, \"i\" represents",
				"the imaginary unit, and \"{cjk}π{cjk_end}\"",
				"represents the mathematical",
				"constant pi, what is the value of",
				"<center>" .. arg_text[argv[1]] .. " ?",
			},
		}	
		return texts[lang_fixed] or texts["en"]
	end,
	Answer = function (self, player)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or self.Build(self)
		local argv = self.argv[player_index]
		local arg_answer = {
			[1] = -1,
			[2] = 0,
		}
		return arg_answer[argv[1]]
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
	argc = 3,
	argv = {
		["Default"] = {2, 2, 2},			--1式真数，2式幂数，1式真数的倍率（均为大于1的正整数）
	},
	Weight = 2,
	Build = function (self, rng)
		local argc = self.argc
		local argv = {}
		for i = 1, argc do
			argv[i] = Maths:RandomInt_Inclined(2, rng)
			if i == 2 and argv[i] == argv[i - 1] then
				argv[i] = argv[i] + 1
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
		local argv = self.argv[player_index]
		local arg1_text = Maths:Fix_Round(argv[1])
		local base = argv[1] * argv[3]
		if base == 10 then
			arg1_text = "lg" .. arg1_text .. " = a, "
		else
			arg1_text = "log{sbs}" .. Maths:Fix_Round(base) .."{sbs_end}" .. arg1_text .. " = a, "
		end
		local arg2_text = Maths:Fix_Round(base) .. "{sps}b{sps_end} = " .. Maths:Fix_Round(argv[2]) .. ", "
		local find_text = Maths:Fix_Round(argv[1] * argv[2])
		if argv[1] * base == 10 then
			find_text = "lg" .. find_text
		else
			find_text = "log{sbs}" .. Maths:Fix_Round(argv[3] * base) .."{sbs_end}" .. find_text
		end
		local texts = {
			["zh"] = {
				"<center>记{num}" .. arg1_text .. arg2_text .. "{num_end}",
				"<center>今取{num}a = " .. Maths:Fix_Round(math.log(argv[1], base), 2) .. ", b = " .. Maths:Fix_Round(math.log(argv[2], base), 2) .. ", {num_end}",
				"<center>求：{num}" .. find_text .. " = ?{num_end}",
				"<center>（结果保留两位小数）", 
			},
			["en"] = {
				"<center>Consider {num}" .. arg1_text .. arg2_text .. "{num_end}",
				"<center>If using {num}a = " .. Maths:Fix_Round(math.log(argv[1], base), 2) .. ", b = " .. Maths:Fix_Round(math.log(argv[2], base), 2) .. ", {num_end}",
				"<center>what is the value of {num}" .. find_text .. "{num_end} ?",
				"<center>(Round the result to two decimal places.)", 
			},
		}	
		return texts[lang_fixed] or texts["en"]
	end,
	Answer = function (self, player)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or self.Build(self)
		local argv = self.argv[player_index]
		local value_a = Maths:Fix_Round(math.log(argv[1], base), 2)
		local value_b = Maths:Fix_Round(math.log(argv[2], base), 2)
		local result = (value_a + value_b) / (2 - value_a)
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

Questions[3] = {
	argc = 8,
	argv = {
		["Default"] = {2, 2, 2, 2, 1, 1, 1, 1},		--基数，基数，基数，取出物件数目（不小于2，小于物件总数），目标物件序号，目标物件数目（不大于基数，不大于取出物件数目，不小于1），分布类型（1：二项分布；2：超几何分布），题目类型（1：求概率；2：求期望；3：求方差）
	},
	Weight = 3,
	Build = function (self, rng)
		local argc = self.argc
		local argv = {}
		for i = 1, argc do
			if i <= 3 then
				argv[i] = Maths:RandomInt_Ranged(2, 5, rng, true, true)
			elseif i == 4 then		--//
				argv[i] = Maths:RandomInt_Ranged(2, math.max(math.max(argv[1] + argv[2], argv[1] + argv[3]), argv[2] + argv[3]), rng, true, false)
			elseif i == 6 then
				argv[i] = Maths:RandomInt(math.min(argv[4], argv[argv[5]]), rng, false, true)
			elseif i == 7 then
				argv[i] = Maths:RandomInt(2, rng, false, true)
			else
				argv[i] = Maths:RandomInt(3, rng, false, true)
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
		local argv = self.argv[player_index]
		local type_text = {
			["zh"] = {
				[1] = "每次取出后放回",
				[2] = "每次取出后不放回",
			},
			["en"] = {
				[1] = "With replacement",
				[2] = "Without replacement",
			},
		}
		local item_text = {
			["zh"] = {
				[1] = "硬币",
				[2] = "炸弹",
				[3] = "钥匙",
			},
			["en"] = {
				[1] = " coin",
				[2] = " bomb",
				[3] = " key",
			},
		}
		local unit_text = {
			[1] = "枚",
			[2] = "个",
			[3] = "把",
		}
		local arg4_text_en = tostring(argv[4]) .. " item"
		if argv[4] > 1 then
			arg4_text_en = arg4_text_en .. "s"
		end
		local arg5_text_en = item_text["en"][argv[5]]
		if argv[6] > 1 or argv[8] ~= 1 then
			arg5_text_en = arg5_text_en .. "s"
		end
		local arg6_text_zh = "{num}" .. argv[6] .. "{num_end}" .. unit_text[argv[5]]
		local value_text = {
			["zh"] = {
				[1] = "取出的物件中恰有" .. arg6_text_zh .. item_text["zh"][argv[5]] .. "的概率",
				[2] = "取出的" .. item_text["zh"][argv[5]] .. "的数目的数学期望",
				[3] = "取出的" .. item_text["zh"][argv[5]] .. "的数目的方差",
			},
			["en"] = {
				[1] = {"the probability of", "selecting exactly " .. argv[6] .. arg5_text_en},
				[2] = {"the mathematical expectations", "of the number of" .. arg5_text_en .. " drawn"},
				[3] = {"the variance of", "the number of".. arg5_text_en .. " drawn"},
			},
		}
		local texts = {
			["zh"] = {
				"<center>从{num}" .. argv[1] .. "{num_end}枚硬币、 {num}" .. argv[2] .. "{num_end}个炸弹、 {num}" .. argv[3] .."{num_end}把钥匙中任意取出{num}" .. argv[4] .. "{num_end}件，", 
				"<center>（" .. type_text["zh"][argv[7]] .. "，假设取到每一物件的可能性相同）", 
				"<center>则" .. value_text["zh"][argv[8]] .. "是？", 
				"<center>（结果保留三位小数）", 
			},
			["en"] = {
				"<center>From a collection of ",
				"<center>" .. argv[1] .. " coins, " .. argv[2] .. " bombs, and " .. argv[3] .." keys,",
				"<center>randomly choose " .. arg4_text_en ..".",
				"<center>What is " .. value_text["en"][argv[8]][1], 
				"<center>" .. value_text["en"][argv[8]][2],
				"<center>from the collection?", 
				"<center>(" .. type_text["en"][argv[7]] .. ", assuming each item has",
				"<center>an equal probability of being chosen.)", 
				"<center>(Round the result to three decimal places.)", 
			},
		}	
		return texts[lang_fixed] or texts["en"]
	end,
	Answer = function (self, player)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or self.Build(self)
		local argv = self.argv[player_index]
		local result = 0
		local N = argv[1] + argv[2] + argv[3]	--物件总数目
		local M = argv[argv[5]]					--目标物件数目
		local n = argv[4]						--试验总次数
		local k = argv[6]						--事件发生次数
		local p = M / N							--每次事件发生概率（仅用于二项分布）
		--print("N: "..N.." M: "..M.." n: "..n.." k: "..k.." p: "..p)
		if argv[8] == 1 then
			if argv[7] == 1 then
				--print("Maths:Comb(k, n): " .. Maths:Comb(k, n))
				--print("(p ^ k): " .. (p ^ k))
				--print("((1 - p) ^ (n - k)): " .. ((1 - p) ^ (n - k)))
				result = Maths:Comb(k, n) * (p ^ k) * ((1 - p) ^ (n - k))
			else
				--print("Maths:Comb(k, M): " .. Maths:Comb(k, M))
				--print("Maths:Comb(n - k, N - M): " .. Maths:Comb(n - k, N - M))
				--print("Maths:Comb(n, N): " .. Maths:Comb(n, N))
				result = (Maths:Comb(k, M) * Maths:Comb(n - k, N - M)) / Maths:Comb(n, N)
			end
		elseif argv[8] == 2 then
			if argv[7] == 1 then
				result = n * p
			else
				result = n * M / N
			end
		elseif argv[8] == 3 then
			if argv[7] == 1 then
				result = n * p * (1 - p)
			else
				result = (n * M * (N - n) * (N - M)) / (N * N * (N - 1)) 
			end
		end
		return Maths:Fix_Round(result, 3)
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
	argc = 13,
	argv = {
		["Default"] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},		--1至12：各位置矢量横纵竖坐标；13：待求几何体类型（1：四面体；2：平行六面体）
	},
	Weight = 2,
	Build = function (self, rng)
		local argc = self.argc
		local argv = {}
		local vec_list = {}
		for i = 1, 12 do
			argv[i] = Maths:Fix_Round(Maths:RandomSign(rng, false) * Maths:RandomInt(10, rng, true, false))
		end
		for i = 1, 3 do
			vec_list[i] = Maths:Vector3(argv[i * 3 + 1], argv[i * 3 + 2], argv[i * 3 + 3]) - Maths:Vector3(argv[1], argv[2], argv[3])
		end
		while vec_list[1]:Mixed(vec_list[2], vec_list[3]) == 0 do
			argv[1] = argv[1] + 1
		end
		argv[13] = Maths:RandomInt_Ranged(1, 2, rng, true, true)
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
		local point_text = {}
		for i = 0, 3 do
			point_text[i + 1] = "(" ..argv[i * 3 + 1]  .. ", " .. argv[i * 3 + 2] .. ", " .. argv[i * 3 + 3] .. ")"
		end
		local arg13_text = {
			[1] = {
				["zh"] = "四面体",
				["en"] = "tetrahedron",
			},
			[2] = {
				["zh"] = "平行六面体",
				["en"] = "parallelepiped",
			},
		}
		local texts = {
			["zh"] = {
				"求三维空间中{num}" .. point_text[1] .. ", " .. point_text[2] .. ",{num_end}",
				"{num}" .. point_text[3] .. ", " .. point_text[4] .. "{num_end}四个点构成的",
				arg13_text[argv[13]]["zh"] .. "的体积。",
				"<center>（结果保留两位小数）",
			},
			["en"] = {
				"Find the volume of the",
				"parallelepiped fromed by",
				"the four points {num}" .. point_text[1] .. ",{num_end}",
				"{num}" .. point_text[2] .. ", " .. point_text[3] .. ",{num_end}",
				"and {num}" .. point_text[4] .. "{num_end} in",
				"three-dimensional space.",
				"<center>(Round the result to two decimal places.)", 
			},
		}	
		return texts[lang_fixed] or texts["en"]
	end,
	Answer = function (self, player)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or self.Build(self)
		local argv = self.argv[player_index]
		local vec_list = {}
		for i = 1, 3 do
			vec_list[i] = Maths:Vector3(argv[i * 3 + 1], argv[i * 3 + 2], argv[i * 3 + 3]) - Maths:Vector3(argv[1], argv[2], argv[3])
			--print(vec_list[i])
		end
		local result = math.abs(vec_list[1]:Mixed(vec_list[2], vec_list[3]))
		--print(vec_list[2]:Cross(vec_list[3]))
		if argv[13] == 1 then
			result = result / 6
		end
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

return Questions