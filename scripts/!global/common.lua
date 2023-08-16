local Common = {}

--判断变量是否在prev_table中，返回逻辑
function Common:IsInTable(v, prev_table)
	for _, value in pairs(prev_table) do
		if v == value then
			return true
		end
	end
	return false
end

--连接若干个数组，返回数组
function Common:ConcatArrays(...)
	local result = {}
	local arrays = {...}
	for _, array in ipairs(arrays) do
		for i, value in ipairs(array) do
			table.insert(result, value)
		end
	end
	return result
end

--逻辑异或，返回逻辑
function Common:Xor(a, b)
	return ((not a) and b) or (a and (not b))
end

--判断prev_table是否为空表，返回逻辑
function Common:IsTableEmpty(prev_table)
    return _G.next(prev_table) == nil
end

--复制一个表prev_table，不改变原表数据，返回表
function Common:CopyTable(prev_table)
	local new_table = {}
	for key, value in pairs(prev_table) do
		if type(value) == "table" then
			new_table[key] = Common:CopyTable(value)
		else
			new_table[key] = value
		end
	end
	return new_table
end

function Common:UTF8_strlen(str)
    local _, count = str:gsub("[%z\1-\127\194-\244][\128-\191]*", "")
    return count
end

function Common:UTF8_sub(str, ini, fin)
	fin = fin or string.len(str)
	local offset_fin = utf8.offset(str, fin + 1)
	if offset_fin then
		offset_fin = offset_fin - 1
	end
	return string.sub(str, utf8.offset(str, ini), offset_fin)
end

function Common:UTF8_simplyfind(str, pattern, ini)	--仅查找常规字符串
	ini = ini or 1
	for idx = ini, Common:UTF8_strlen(str) do
		local chr = Common:UTF8_sub(str, idx, idx)
		if chr == string.sub(pattern, 1, 1) then
			local target_len = string.len(pattern)
			local checking_str = Common:UTF8_sub(str, idx, idx + target_len - 1)
			if checking_str == pattern then
				return idx, idx + target_len - 1
			end
		end
	end
	return nil, nil
end

return Common