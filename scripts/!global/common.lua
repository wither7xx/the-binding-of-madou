local Common = {}

--�жϱ����Ƿ���prev_table�У������߼�
function Common:IsInTable(v, prev_table)
	for _, value in pairs(prev_table) do
		if v == value then
			return true
		end
	end
	return false
end

--�������ɸ����飬��������
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

--�߼���򣬷����߼�
function Common:Xor(a, b)
	return ((not a) and b) or (a and (not b))
end

--�ж�prev_table�Ƿ�Ϊ�ձ������߼�
function Common:IsTableEmpty(prev_table)
    return _G.next(prev_table) == nil
end

--����һ����prev_table�����ı�ԭ�����ݣ����ر�
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

function Common:UTF8_simplyfind(str, pattern, ini)	--�����ҳ����ַ���
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