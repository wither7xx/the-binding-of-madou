local Maths = {}

local Common = tbom.Global.Common

--�������뱣��С�����mλ��Ĭ�ϱ��������������ظ�����
function Maths:Fix_Round(x, m)
	if m == nil or m == 0 then
		return math.floor(x + 0.5)
	end
	local mod = 10 ^ m
	return math.floor(x * mod + 0.5) / mod
end

--����һ�����׷���matrix������ʽ�����ظ�����
function Maths:Determinant_2x2(matrix)
	local det = matrix[1][1] * matrix[2][2] - matrix[1][2] * matrix[2][1]
	return det
end

--����һ�����׷���matrix������ʽ�����ظ�����
function Maths:Determinant_3x3(matrix)
	local det = matrix[1][1] * matrix[2][2] * matrix[3][3] 
		+ matrix[1][2] * matrix[2][3] * matrix[3][1] 
		+ matrix[1][3] * matrix[2][1] * matrix[3][2] 
		- matrix[1][3] * matrix[2][2] * matrix[3][1] 
		- matrix[1][2] * matrix[2][1] * matrix[3][3] 
		- matrix[1][1] * matrix[2][3] * matrix[3][2]
	return det
end
		
--����һ��N*M����matrix���ȣ���������
function Maths:Rank_NxM(matrix, N, M)
	local rank = 0
	local row = 1
	local k = 1
	local temp
	for i = 1, M do
		k = row
		for j = row + 1, N do
			if math.abs(matrix[k][i]) < math.abs(matrix[j][i]) then
				k = j
			end
		end
		if k ~= row then
			for j = i, M do
				temp = matrix[row][j]
				matrix[row][j] = matrix[k][j]
				matrix[k][j] = temp
			end
		end
		if matrix[row][i] == 0 then
			goto Rank_continue
		else
			rank = rank + 1
			for j = 1, N do
				if j ~= row then
					temp = (-1) * matrix[j][i] / matrix[row][i]
					for k = i, M do
						matrix[j][k] = matrix[j][k] + temp * matrix[row][k]
					end
				end
			end
			temp = matrix[row][i]
			for j = i, M do
				matrix[row][j] = matrix[row][j] / temp
			end
		end
		row = row + 1
		if row > N then
			break
		end
		::Rank_continue::
	end
	return rank
end

--������Ȼ��n�Ľ׳ˣ���������
function Maths:Fact(n)
	local multi = 1
	for i = 1, n do
		multi = multi * i
	end
	return multi
end

--�����n����ͬԪ������ȡm��Ԫ�ص�����������������
function Maths:Perm(m, n)
	if n >= m then
		return Maths:Fact(n) / Maths:Fact(n - m)
	else
		return 0
	end
end

--�����n����ͬԪ������ȡm��Ԫ�ص����������������
function Maths:Comb(m, n)
	return Maths:Fact(n) / (Maths:Fact(n - m) * Maths:Fact(m))
end

--��ʵ��x�ķ��ţ�����������1��-1��0��
function Maths:Sign(x)
	if x > 0 then
		return 1
	elseif x < 0 then
		return -1
	else
		return 0
	end
end

--�ж�����x�Ƿ�Ϊż���������߼���nil
function Maths:IsEven(x)
	local x_abs = x
	if x < 0 then
		x_abs = math.abs(x)
	end
	if math.floor(x_abs) < x_abs then
		return nil
	else
		return (x_abs % 2) == 0
	end
end

local function GammaHelper(n)
	local multi = 1
	for i = 1, (2 * n) - 1, 2 do
		multi = multi * i
	end
	return multi / (2 ^ n)
end

--���㦣����ֵ�����ظ������������즣(s)��sΪ���������ͦ�(s+1/2)��sΪ��Ȼ��������ʽ��
--�������������֣����������Ƿ�1/2���߼������̦еĽ���ֵ֮���ȣ�������Ĭ��Ϊ��ȡ����ֵ��
function Maths:Gamma(s, has_den, rtpi_acc)
	if has_den then
		if s >= 0 then
			local rtpi = math.sqrt(math.pi)
			if rtpi_acc then
				rtpi = Maths:Fix_Round(rtpi, rtpi_acc)
			end
			return GammaHelper(s) * rtpi
		end
	else
		if s > 0 then
			return Maths:Fact(s - 1)
		end
	end
	return nil
end

--���㦢����ֵ�����ظ������������즢(p, q)��p��qΪ���������ͦ�(p+1/2, q)��pΪ��Ȼ����qΪ��������...����ʽ��
--������p�������֣���������q�������֣���������p�Ƿ�1/2���߼�����q�Ƿ�1/2���߼������еĽ���ֵ֮���ȣ�������Ĭ��Ϊ��ȡ����ֵ��
function Maths:Beta(p, q, p_has_den, q_has_den, pi_acc)
	if p < 0 or q < 0 or (p == 0 and (not p_has_den)) or (q == 0 and (not q_has_den)) then
		return nil
	end
	if p_has_den and q_has_den then
		local pi = math.pi
		if pi_acc then
			pi = Maths:Fix_Round(pi, pi_acc)
		end
		return (GammaHelper(p) * GammaHelper(q) * pi) / Maths:Gamma(p + q + 1, false)
	elseif not (p_has_den or q_has_den) then
		return (Maths:Gamma(p, false) * Maths:Gamma(q, false)) / Maths:Gamma(p + q, false)
	else
		local p_multi
		if p_has_den then
			p_multi = GammaHelper(p)
		else
			p_multi = Maths:Gamma(p, false)
		end
		local q_multi
		if q_has_den then
			q_multi = GammaHelper(q)
		else
			q_multi = Maths:Gamma(q, false)
		end
		return (p_multi * q_multi) / GammaHelper(p + q)
	end
	return nil
end

--���ʽ�����ظ�����
--������ָ��������1�������������еĽ���ֵ֮���ȣ�������Ĭ��Ϊ��ȡ����ֵ��
function Maths:Wallis(n, pi_acc)
	if n <= 1 then
		return nil
	end
	local result_num = 1
	local result_den = 1
	if Maths:IsEven(n) then
		for i = 1, (n - 1), 2 do
			result_num = result_num * i
			result_den = result_den * (i + 1)
		end
		local pi = math.pi
		if pi_acc then
			pi = Maths:Fix_Round(pi, pi_acc)
		end
		result_num = result_num * pi
		result_den = result_den * 2
	else
		for i = 2, (n - 1), 2 do
			result_num = result_num * i
			result_den = result_den * (i + 1)
		end
	end
	return result_num / result_den
end

function Maths:RandomInt(max, rng, include_zero, include_max)
	if include_zero == nil then
		include_zero = true
	end
	if include_max == nil then
		include_max = false
	end
	local max_fixed = max
	if include_zero and include_max then
		max_fixed = max + 1
	elseif (not include_zero) and (not include_max) then
		max_fixed = max - 1
	end
	if max_fixed <= 0 then
		return 0
	end
	local rand = math.random(max_fixed)
	if rng == nil then
		if include_zero then
			if not include_max then
				if rand == max then
					rand = 0
				end
			else
				rand = rand - 1
			end
		end
	else
		rand = rng:RandomInt(max_fixed)
		if not include_zero then
			if include_max then
				if rand == 0 then
					rand = max
				end
			else
				rand = rand + 1
			end
		end
	end
	return rand
end

function Maths:RandomInt_Ranged(min, max, rng, include_min, include_max)
	if include_min == nil then
		include_min = true
	end
	if include_max == nil then
		include_max = true
	end
	local dif = max - min
	return min + Maths:RandomInt(max - min, rng, include_min, include_max)
end

function Maths:RandomInt_Weighted(weight_list, rng)		--����1���������ŵļ�Ȩ�����
	if type(weight_list) == "table" then
		local weight_sum = 0
		for _, weight in ipairs(weight_list) do
			weight_sum = weight_sum + weight
		end
		local rand = Maths:RandomInt(weight_sum, rng, true, false)
		for _, weight in ipairs(weight_list) do
			if rand < weight then
				return rand + 1
			end
			rand = rand - weight
		end
	end
	return 1
end

function Maths:RandomInt_Inclined(max_exp, rng)
	max_exp = max_exp or 12		--Ĭ�����ֵ������4095����Сֵ������2
	local weight_list = {}
	for i = max_exp, 1, -1 do
		table.insert(weight_list, i)
	end
	local rand_exp = Maths:RandomInt_Weighted(weight_list, nil) + 1
	return Maths:RandomInt_Ranged(2 ^ (rand_exp - 1), 2 ^ rand_exp, rng, true, false)
end
function Maths:RandomFloat(rng)
	if rng == nil then
		return math.random()
	end
	return rng:RandomFloat()
end

function Maths:RandomFloat_Fixed(m, rng)
	return Maths:Fix_Round(Maths:RandomFloat(rng), m)
end

function Maths:RandomSign(rng, include_zero)
	if include_zero == nil then
		include_zero = false
	end
	local max = 1
	if include_zero == true then
		max = 2
	end
	local rand = Maths:RandomInt(max, rng, true, true)
	if rand == 1 then
		return -1
	elseif rand == 2 then
		return 0
	end
	return 1
end

function Maths:GetSignedVector(v)
	return Vector(Maths:Sign(v.X), Maths:Sign(v.Y))
end

function Maths:GetReflectionVector(incident_vector, normal_vector)		--�˴�Ҫ���������������Ϊ��λʸ��
	return (-(incident_vector:Dot(normal_vector)) * normal_vector):Normalized()
end

--�ռ�ʸ�����
--�ռ�ʸ��Ԫ����
local Vector3_META = {
	__index = {},
}

--���캯��
function Vector3_META:new(x, y, z)
	local new_vec3 = setmetatable({}, Vector3_META)
	new_vec3.X = x
	new_vec3.Y = y
	new_vec3.Z = z
	return new_vec3
end

function Maths:Vector3(x, y, z)
	return Vector3_META:new(x, y, z)
end

--��������غ���
Vector3_META.__add = function (vec3_a, vec3_b)
	local new_vec3_X = vec3_a.X + vec3_b.X
	local new_vec3_Y = vec3_a.Y + vec3_b.Y
	local new_vec3_Z = vec3_a.Z + vec3_b.Z
	return Vector3_META:new(new_vec3_X, new_vec3_Y, new_vec3_Z)
end

Vector3_META.__sub = function (vec3_a, vec3_b)
	local new_vec3_X = vec3_a.X - vec3_b.X
	local new_vec3_Y = vec3_a.Y - vec3_b.Y
	local new_vec3_Z = vec3_a.Z - vec3_b.Z
	return Vector3_META:new(new_vec3_X, new_vec3_Y, new_vec3_Z)
end

Vector3_META.__mul = function (vec3_a, vec3_b)
	local new_vec3_X
	local new_vec3_Y
	local new_vec3_Z
	if type(vec3_a) == "number" and type(vec3_b) == "table" then
		new_vec3_X = vec3_a * vec3_b.X
		new_vec3_Y = vec3_a * vec3_b.Y
		new_vec3_Z = vec3_a * vec3_b.Z
	elseif type(vec3_a) == "table" and type(vec3_b) == "number" then
		new_vec3_X = vec3_a.X * vec3_b
		new_vec3_Y = vec3_a.Y * vec3_b
		new_vec3_Z = vec3_a.Z * vec3_b
	elseif type(vec3_a) == "table" and type(vec3_b) == "table" then
		new_vec3_X = vec3_a.X * vec3_b.X
		new_vec3_Y = vec3_a.Y * vec3_b.Y
		new_vec3_Z = vec3_a.Z * vec3_b.Z
	end
	return Vector3_META:new(new_vec3_X, new_vec3_Y, new_vec3_Z)
end

Vector3_META.__div = function (vec3_a, vec3_b)
	local new_vec3_X
	local new_vec3_Y
	local new_vec3_Z
	if type(vec3_a) == "number" and type(vec3_b) == "table" then
		if vec3_b.X == 0 or vec3_b.Y == 0 or vec3_b.Z == 0 then
			error("attempt to perform a divsion by zero")
		end
		new_vec3_Y = vec3_a / vec3_b.Y
		new_vec3_Z = vec3_a / vec3_b.Z
		new_vec3_Z = vec3_a / vec3_b.Z
	elseif type(vec3_a) == "table" and type(vec3_b) == "number" then
		if vec3_b == 0 then
			error("attempt to perform a divsion by zero")
		end
		new_vec3_X = vec3_a.X / vec3_b
		new_vec3_Y = vec3_a.Y / vec3_b
		new_vec3_Z = vec3_a.Z / vec3_b
	elseif type(vec3_a) == "table" and type(vec3_b) == "table" then
		if vec3_b.X == 0 or vec3_b.Y == 0 or vec3_b.Z == 0 then
			error("attempt to perform a divsion by zero")
		end
		new_vec3_X = vec3_a.X / vec3_b.X
		new_vec3_Y = vec3_a.Y / vec3_b.Y
		new_vec3_Z = vec3_a.Z / vec3_b.Z
	end
	return Vector3_META:new(new_vec3_X, new_vec3_Y, new_vec3_Z)
end

Vector3_META.__unm = function (vec3)
	local new_vec3_X = -(vec3.X)
	local new_vec3_Y = -(vec3.Y)
	local new_vec3_Z = -(vec3.Z)
	return Vector3_META:new(new_vec3_X, new_vec3_Y, new_vec3_Z)
end

Vector3_META.__eq = function (vec3_a, vec3_b)
	return vec3_a.X == vec3_b.X and vec3_a.Y == vec3_b.Y and vec3_a.Z == vec3_b.Z
end

Vector3_META.__tostring = function (vec3)
	return "Vector(" .. vec3.X .. "," .. vec3.Y .. "," .. vec3.Z .. ")"
end

--������Ա����
do
	local Vector3 = Vector3_META.__index

	--��ʸ�������ؿռ�ʸ��
	function Vector3:Cross(second)
		local new_vec3_X = Vector(self.Y, self.Z):Cross(Vector(second.Y, second.Z))
		local new_vec3_Y = -(Vector(self.X, self.Z):Cross(Vector(second.X, second.Z)))
		local new_vec3_Z = Vector(self.X, self.Y):Cross(Vector(second.X, second.Y))
		return Vector3_META:new(new_vec3_X, new_vec3_Y, new_vec3_Z)
	end

	--��ռ��������࣬���ظ�����
	function Vector3:Distance(second)
		return math.sqrt(((self.X - second.X) ^ 2) + ((self.Y - second.Y)^ 2) + ((self.Z - second.Z) ^ 2))
	end

	--���������ظ�����
	function Vector3:Dot(second)
		return self.X * second.X + self.Y * second.Y + self.Z * second.Z
	end

	--��ĳʸ���ĳ��ȣ����ظ�����
	function Vector3:Length()
		return math.sqrt((self.X ^ 2) + (self.Y ^ 2) + (self.Z ^ 2))
	end

	--���ϻ����������ػ��������ظ�����
	function Vector3:Mixed(second, third)
		return self.Dot(self, second:Cross(third))
	end

	--��λ��ĳʸ������Ϊ��ʸ�������κδ��������ؿռ�ʸ��
	function Vector3:Normalized()
		local length = self.Length(self)
		if length == 0 then
			return Vector3_META:new(0, 0, 0)
		end
		return self / length
	end
end

return Maths