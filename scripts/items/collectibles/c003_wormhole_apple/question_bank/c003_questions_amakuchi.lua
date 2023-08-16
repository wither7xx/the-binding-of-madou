local Questions = {}

local Common = tbom.Global.Common
local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths
local Translation = tbom.Global.Translation

local function RandomInt_Inclined(max_exp, rng)
	max_exp = max_exp or 12		--默认最大值不超过4095，最小值不低于2
	local weight_list = {}
	for i = max_exp, 1, -1 do
		table.insert(weight_list, i)
	end
	local rand_exp = Maths:RandomInt_Weighted(weight_list, nil) + 1
	return Maths:RandomInt_Ranged(2 ^ (rand_exp - 1), 2 ^ rand_exp, rng, true, false)
end

Questions[1] = {
	argc = 1,								--变量数目（整数）
	argv = {								--变量容器（散列表，内含数组）
		["Default"] = {0},
	},
	--inited = false,						--是否已初始化（逻辑）
	Weight = 1,								--题目权重（整数）
	Build = function (self, rng)			--构造变量容器函数，返回数组
		local argc = self.argc
		local argv = {}
		for i = 1, argc do
			argv[i] = Maths:RandomSign(rng, false) * Maths:RandomInt_Inclined(nil, rng)
		end
		return argv
	end,
	--[[
	Update = function (self, player)		--更新变量函数，每次组卷时触发，无返回值
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or {}
		self.inited = false

		local argc = self.argc
		local argv = self.argv[player_index]
		for i = 1, argc do
			argv[i] = Maths:RandomSign(nil, false) * Maths:RandomInt_Inclined()
		end

		self.inited = true
	end,
	]]
	Update = function (self, player, rng)	--更新变量函数，可手动触发，无返回值
		local player_index = Tools:GetPlayerIndex(player)
		--if self.argv[player_index] then
		--	local new_argv = self.Build()
		--	self.argv[player_index] = new_argv
		--else
		--	self.argv[player_index] = self.Build()
		--end
		self.argv[player_index] = self.Build(self, rng)
	end,
	Texts = function (self, player, lang)	--获取题目文字函数，返回字符串数组
		local lang_fixed = Translation:FixLanguage(lang)
		--local argv = self.argv["Default"]
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or self.Build(self)
		local argv = self.argv[player_index]

		local texts = {
			["zh"] = {
				"<center>介于{num}".. Maths:Fix_Round(argv[1] - 1) .."{num_end}和{num}".. Maths:Fix_Round(argv[1] + 1) .."{num_end}之间的整数是？", 
			},
			["en"] = {
				"<center>Find the integer between", 
				"<center>" .. Maths:Fix_Round(argv[1] - 1) .." and ".. Maths:Fix_Round(argv[1] + 1) ..".", 
			},
		}	
		return texts[lang_fixed] or texts["en"]
	end,
	Answer = function (self, player)		--获取答案函数，返回数字
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or self.Build(self)
		local argv = self.argv[player_index]
		return argv[1]
	end,
	Reset = function (self)					--重置变量容器函数，无返回值
		for key, value in pairs(self.argv) do
			if key ~= "Default" then
				self.argv[key] = nil
			end
		end
	end,
}

Questions[2] = {
	argc = 5,
	argv = {
		["Default"] = {1, 1, 1, 1, 1},			--基数，基数，基数，运算符序号，运算符序号
	},
	--inited = false,
	Weight = 2,
	Build = function (self, rng)
		local argc = self.argc
		local argv = {}
		local weighted = false
		if Maths:RandomInt(1, rng, true, true) == 0 then
			weighted = true
		end
		for i = 1, argc do
			local int_part = Maths:RandomInt_Inclined(nil, rng)
			if i <= 3 then
				if Maths:RandomInt(1, rng, true, true) == 0 then
					argv[i] = Maths:RandomSign(rng, false) * Maths:Fix_Round(int_part)
				else
					argv[i] = Maths:RandomSign(rng, false) * (int_part + Maths:RandomFloat_Fixed(2, rng))
				end
			else
				argv[i] = Maths:RandomInt(4, rng, false, true)
			end
		end
		return argv
	end,
	Update = function (self, player, rng)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.Build(self, rng)
	end,
	--[[
	Update = function (self, player)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or {}
		self.inited = false

		local argc = self.argc
		local argv = self.argv[player_index]
		local weighted = false
		if Maths:RandomInt(1, nil, true, true) == 0 then
			weighted = true
		end
		for i = 1, argc do
			local int_part = Maths:RandomInt_Inclined()
			if i <= 3 then
				if Maths:RandomInt(1, nil, true, true) == 0 then
					argv[i] = Maths:RandomSign(nil, false) * Maths:Fix_Round(int_part)
				else
					argv[i] = Maths:RandomSign(nil, false) * (int_part + Maths:RandomFloat_Fixed(2))
				end
			else
				argv[i] = Maths:RandomInt(4, nil, false, true)
			end
		end

		self.inited = true
	end,
	]]
	Texts = function (self, player, lang)
		local lang_fixed = Translation:FixLanguage(lang)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or self.Build(self)
		local argv = self.argv[player_index]
		local arg_text = {}
		for i = 1, 3 do
			arg_text[i] = tostring(argv[i])
			if argv[i] < 0 then
				arg_text[i] = "(" .. arg_text[i] .. ")"
			end
			if argv[4] <= 2 and argv[5] > 2 then
				if i == 1 then
					arg_text[i] = "(" .. arg_text[i]
				elseif i == 2 then
					arg_text[i] = arg_text[i] .. ")"
				end
			end
		end
		local operator_text = {
			[1] = " + ",
			[2] = " - ",
			[3] = " × ",
			[4] = " ÷ ",
		}
		local concated_text = arg_text[1] .. operator_text[argv[4]] .. arg_text[2] .. operator_text[argv[5]] .. arg_text[3] .. " = ?"
		local texts = {
			["zh"] = {
				"<center>{num}".. concated_text, 
				"<center>（结果保留两位小数）", 
			},
			["en"] = {
				"<center>{num}".. concated_text, 
				"<center>(Round the result to two decimal places.)", 
			},
		}	
		return texts[lang_fixed] or texts["en"]
	end,
	Answer = function (self, player)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or self.Build(self)
		local argv = self.argv[player_index]
		local operators = {
			[1] = function (arg1, arg2)
				return arg1 + arg2
			end,
			[2] = function (arg1, arg2)
				return arg1 - arg2
			end,
			[3] = function (arg1, arg2)
				return arg1 * arg2
			end,
			[4] = function (arg1, arg2)
				return arg1 / arg2
			end,
		}
		local result = operators[argv[5]](operators[argv[4]](argv[1], argv[2]), argv[3])
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
	argc = 2,
	argv = {
		["Default"] = {1, 2},		--底数（正整数），指数（大于1的整数）
	},
	--inited = false,
	Weight = 1,
	Build = function (self, rng)
		local argc = self.argc
		local argv = {}
		--for i = 1, argc do
		argv[2] = Maths:RandomInt_Ranged(2, 3, rng, true, true)
		if argv[2] == 2 then
			argv[1] = Maths:RandomInt_Ranged(2, 20, rng, true, true)
		else
			argv[1] = Maths:RandomInt_Inclined(3, rng)
		end
		--end
		return argv
	end,
	Update = function (self, player, rng)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.Build(self, rng)
	end,
	--[[
	Update = function (self, player)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or {}
		self.inited = false

		local argc = self.argc
		local argv = self.argv[player_index]
		for i = 1, argc do
			argv[i] = Maths:RandomInt_Ranged(2, 20, nil, true, true) * 1
		end

		self.inited = true
	end,]]
	Texts = function (self, player, lang)
		local lang_fixed = Translation:FixLanguage(lang)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or self.Build(self)
		local argv = self.argv[player_index]
		local arg1_text = tostring(Maths:Fix_Round(argv[1] ^ argv[2]))
		local arg2_text = "{sps}" .. argv[2] .. "{sps_end}"
		if argv[2] == 2 then
			arg2_text = ""
		end
		local texts = {
			["zh"] = {
				--"记 {num}sqrt(){num_end} 为取算术平方根运算符，则：", 
				"<center>{num}" .. arg2_text .. "{root} {root_end}  (".. arg1_text .. ") = ?", 
			},
			["en"] = {
				--"Let's define sqrt() as the", 
				--"arithmetic square root operator.", 
				"<center>What is the value of {num}" .. arg2_text .. "{root} {root_end}  (".. arg1_text .. ")?", 
			},
		}	
		return texts[lang_fixed] or texts["en"]
	end,
	Answer = function (self, player)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or self.Build(self)
		local argv = self.argv[player_index]
		return argv[1]
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
	argc = 4,
	argv = {
		["Default"] = {1, 1, 1, 1},			--基数，基数，基数，被取物件序号
	},
	--inited = false,
	Weight = 1,
	Build = function (self, rng)
		local argc = self.argc
		local argv = {}
		for i = 1, argc do
			if i >= 4 then
				argv[i] = Maths:RandomInt(3, rng, false, true)
			else
				argv[i] = Maths:RandomInt(64, rng, false, true)
			end
		end
		return argv
	end,
	Update = function (self, player, rng)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.Build(self, rng)
	end,
	--[[
	Update = function (self, player)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or {}
		self.inited = false

		local argc = self.argc
		local argv = self.argv[player_index]
		for i = 1, argc do
			if i >= 4 then
				argv[i] = Maths:RandomInt(3, nil, false, true)
			else
				argv[i] = Maths:RandomInt(64, nil, false, true)
			end
		end

		self.inited = true
	end,]]
	Texts = function (self, player, lang)
		local lang_fixed = Translation:FixLanguage(lang)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or self.Build(self)
		local argv = self.argv[player_index]
		local item_text = {
			["zh"] = {
				[1] = "硬币",
				[2] = "炸弹",
				[3] = "钥匙",
			},
			["en"] = {
				[1] = "coin",
				[2] = "bomb",
				[3] = "key",
			},
		}
		local texts = {
			["zh"] = {
				"从{num}" .. argv[1] .. "{num_end}枚硬币、 {num}" .. argv[2] .. "{num_end}个炸弹、 {num}" .. argv[3] .."{num_end}把钥匙中", 
				"任意取出一件（假设取到每一物件的", 
				"可能性相同）， 则取出的物件为" ..item_text["zh"][argv[4]] .. "的", 
				"概率是？", 
				"<center>（结果保留三位小数）", 
			},
			["en"] = {
				"What is the probability of", 
				"randomly selecting a " ..item_text["en"][argv[4]] .. " from", 
				"a collection of " .. argv[1] .. " coins,", 
				argv[2] .. " bombs, and " .. argv[3] .." keys?", 
				"(Assuming each item has an", 
				"equal probability of being", 
				"chosen.)", 
				"<center>(Round the result to three decimal places.)", 
			},
		}	
		return texts[lang_fixed] or texts["en"]
	end,
	Answer = function (self, player)
		local player_index = Tools:GetPlayerIndex(player)
		self.argv[player_index] = self.argv[player_index] or self.Build(self)
		local argv = self.argv[player_index]
		local result = argv[argv[4]] / (argv[1] + argv[2] + argv[3])
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

return Questions