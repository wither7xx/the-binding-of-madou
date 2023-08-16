local Tools = {}

local ModRef = tbom
local Common = tbom.Global.Common
local Maths = tbom.Global.Maths

local tbomCallbacks = tbom.tbomCallbacks
local modEffectVariant = tbom.modEffectVariant

--游戏数据相关
function Tools:GameDataInit(is_continued)
	if not is_continued then
		tbom.TempData.GameData = {}
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Tools.GameDataInit, 0)

--NPC实体对象数据相关
function Tools:NPCDataInit(is_continued)
	if not is_continued then
		tbom.TempData.NPCData = {}
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Tools.NPCDataInit, 0)

function Tools:GetNPCData(entity)
	local idx = tostring(GetPtrHash(entity))
	tbom.TempData.NPCData[idx] = tbom.TempData.NPCData[idx] or {}
	return tbom.TempData.NPCData[idx]
end

--效果实体对象数据相关
function Tools:EffectDataInit(is_continued)
	if not is_continued then
		tbom.TempData.EffectData = {}
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Tools.EffectDataInit, 0)

function Tools:GetEffectData(effect)
	local idx = tostring(GetPtrHash(effect))
	tbom.TempData.EffectData[idx] = tbom.TempData.EffectData[idx] or {}
	return tbom.TempData.EffectData[idx]
end

--存储角色实体对象数据时的困扰：
--Isaac.GetPlayer()或Game().GetPlayer()不好使，角色数目减少时（如里拉移除长子权时/去掉饰品罗时）会导致混乱
--EntityPlayer.ControllerIndex不好使，没法区分双子/里拉/里骨/稻草人/骨哥魂石/双子魂石等
--EntityPlayer.GetData()不好使，小退大退都会重置，存不住
--GetPtrHash()不好使，退出重进时数值刷新，存不住
--EntityPlayer.InitSeed不好使，角色数目增多时（如使用表双子/里拉/饰品罗时）会导致混乱
--解决方法：EntityPlayer.GetCollectibleRNG()可能是存储并区分不同玩家的数据的唯一的好方案
--新的困扰：因为RNG对象随时都在变化，所以直接用RNG对象当索引会很快干爆堆内存导致闪退，现在需要让索引恒定，如何实现？
--解决方法：用RNG.GetSeed()取现有RNG对象的种子（整数），即可让索引在同一局内对不同角色唯一且恒定
--新的困扰之二：现有Global.Tools.GetPlayerIndex()区分表双子/里拉/饰品罗，用它来区分用户(User)会导致错误；EntityPlayer.ControllerIndex不区分表双子/里拉/饰品罗，但也只能区分输入设备的序号，不能区分用户的序号（如仅有一名使用手柄的用户时会导致错误）；现在需要根据用户的序号决定HUD布局，如何实现？
--解决方法：修改Global.Tools.GetPlayerIndex()，使之能够被手动设定是否区分表双子/里拉/饰品罗，同时引入TempData.PlayerData_UserRegister存储前者返回的索引对应的当前用户的序号、引入TempData.PlayerData_Static存储当前用户的数目（默认只增不减，且每局重置）
--新的困扰之三：现有Global.Tools.GetPlayerIndex()会在使用小红罐时将小红视为2P，如何解决？

--初始化角色数据、用户寄存器与角色静态数据
function Tools:PlayerDataInit(is_continued)
	if not is_continued then
		tbom.TempData.PlayerData = {}
		tbom.TempData.PlayerData_UserRegister = {}
		tbom.TempData.PlayerData_Static["UserNum"] = 0
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Tools.PlayerDataInit, 0)

--取角色索引（ignore_pairing设为false）/用户索引（ignore_pairing设为true），返回整数
function Tools:GetPlayerIndex(player, ignore_pairing)
	local CollectibleRNG = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_SAD_ONION)
	local collectible_type = CollectibleType.COLLECTIBLE_SAD_ONION
	local player_type = player:GetPlayerType()
	--换另一个道具的RNG以区分表双子/里拉的表形态和里形态
	if not ignore_pairing then
		if player_type == PlayerType.PLAYER_LAZARUS2_B then
			collectible_type = CollectibleType.COLLECTIBLE_INNER_EYE
		end
	else
		player = player:GetMainTwin()
	end
	local CollectibleRNG = player:GetCollectibleRNG(collectible_type)
	return tostring(CollectibleRNG:GetSeed())
end

--取角色数据，如果出现新角色（如表双子/里拉/饰品罗），则将新加入的部分初始化
function Tools:GetPlayerData(player)
	local idx = Tools:GetPlayerIndex(player, false)
	tbom.TempData.PlayerData[idx] = tbom.TempData.PlayerData[idx] or {}
	return tbom.TempData.PlayerData[idx]
end

--取角色道具数据
function Tools:GetPlayerCollectibleData(player, collectible_type)
	local data = Tools:GetPlayerData(player)
	local item_config_item = Isaac.GetItemConfig():GetCollectible(collectible_type)
	if item_config_item and item_config_item.Name then
		local idx = "Collectible:" .. string.gsub(item_config_item.Name, "%s", "_")
		data[idx] = data[idx] or {}
		return data[idx]
	end
	local idx_null = "Collectible:Null"
	data[idx_null] = data[idx_null] or {}
	return data[idx_null]
end

--取角色饰品数据
function Tools:GetPlayerTrinketData(player, trinket_type)
	local data = Tools:GetPlayerData(player)
	local item_config_item = Isaac.GetItemConfig():GetTrinket(trinket_type)
	if item_config_item and item_config_item.Name then
		local idx = "Trinket:" .. string.gsub(item_config_item.Name, "%s", "_")
		data[idx] = data[idx] or {}
		return data[idx]
	end
	local idx_null = "Trinket:Null"
	data[idx_null] = data[idx_null] or {}
	return data[idx_null]
end

--取角色卡牌数据
function Tools:GetPlayerCardData(player, card)
	local data = Tools:GetPlayerData(player)
	local item_config_card = Isaac.GetItemConfig():GetCard(card)
	if item_config_card and item_config_card.Name then
		local idx = "Card:" .. string.gsub(item_config_card.Name, "%s", "_")
		data[idx] = data[idx] or {}
		return data[idx]
	end
	local idx_null = "Card:Null"
	data[idx_null] = data[idx_null] or {}
	return data[idx_null]
end

--取角色一般拾取物数据
function Tools:GetPlayerPickupData(player, pickup_variant)
	local data = Tools:GetPlayerData(player)
	if pickup_variant == nil or pickup_variant <= 0 then
		local idx_null = "Pickup:Null"
		data[idx_null] = data[idx_null] or {}
		return data[idx_null]
	end
	local idx = "Pickup:" .. tostring(pickup_variant)
	data[idx] = data[idx] or {}
	return data[idx]
end

--检查用户寄存器，如果出现新用户（如由单人模式变为多人模式时），则将新加入的部分初始化
function Tools:CheckUserNum(player)
	local idx_user = Tools:GetPlayerIndex(player, true)
	if tbom.TempData.PlayerData_UserRegister[idx_user] == nil then
		tbom.TempData.PlayerData_UserRegister[idx_user] = tbom.TempData.PlayerData_Static["UserNum"]
		tbom.TempData.PlayerData_Static["UserNum"] = tbom.TempData.PlayerData_Static["UserNum"] + 1
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CallbackPriority.IMPORTANT, Tools.CheckUserNum, 0)

--取当前用户数目，返回整数
function Tools:GetUserNum()
	return tbom.TempData.PlayerData_Static["UserNum"] or 1
end

--由角色对象取用户索引，返回整数
function Tools:GetUserIdx(player)
	local idx_user = Tools:GetPlayerIndex(player, true)
	return tbom.TempData.PlayerData_UserRegister[idx_user] or 0
end

--角色数据相关：其他函数
function Tools:PlayerData_AddAttribute(player, key, starting_value)
	local idx = Tools:GetPlayerIndex(player, false)
	if tbom.TempData.PlayerData[idx] and tbom.TempData.PlayerData[idx][key] == nil then
		tbom.TempData.PlayerData[idx][key] = starting_value
	end
end

function Tools:PlayerData_GetAttribute(player, key)
	local idx = Tools:GetPlayerIndex(player, false)
	if tbom.TempData.PlayerData[idx] then
		return tbom.TempData.PlayerData[idx][key]
	end
	return nil
end

function Tools:PlayerData_SetAttribute(player, key, value)
	local idx = Tools:GetPlayerIndex(player, false)
	if tbom.TempData.PlayerData[idx] then
		tbom.TempData.PlayerData[idx][key] = value
	end
end

function Tools:PlayerData_ClearAttribute(player, key)
	local idx = Tools:GetPlayerIndex(player, false)
	if tbom.TempData.PlayerData[idx] then
		tbom.TempData.PlayerData[idx][key] = nil
	end
end

--判断player是否为原版角色
function Tools:IsOriginalCharacter(player)
	local player_type = player:GetPlayerType()
	return player_type < PlayerType.NUM_PLAYER_TYPES
end

--判断collectible_type是否为不占被动槽位的道具（主动道具、任务道具、长子权），返回逻辑
function Tools:IsNoPassiveSlotItem(collectible_type)
	if collectible_type == CollectibleType.COLLECTIBLE_BIRTHRIGHT then
		return true
	end
	local item_config_item = Isaac.GetItemConfig():GetCollectible(collectible_type)
	if item_config_item then
		if item_config_item.Type == ItemType.ITEM_ACTIVE 
		or item_config_item:HasTags(ItemConfig.TAG_QUEST) then
			return true
		end
	end
	return false
end

--统计所有道具，返回数组
function Tools:GetAllSlotItem()
	local ItemList = {}
	local item_config = Isaac.GetItemConfig()
	for id = 1, item_config:GetCollectibles().Size - 1 do
		if item_config:GetCollectible(id) then
			table.insert(ItemList, id)
		end
	end
	return ItemList
end

--统计所有不占被动槽位的道具，返回数组
function Tools:GetNoPassiveSlotItem()
	local ItemList = {}
	for id = 1, Isaac.GetItemConfig():GetCollectibles().Size - 1 do
		if Tools:IsNoPassiveSlotItem(id) then
			table.insert(ItemList, id)
		end
	end
	return ItemList
end

--统计所有品质为quality的道具，返回数组（过滤隐藏道具和任务道具）
function Tools:GetAllItem_ByQuality(quality)
	local ItemList = {}
	local item_config = Isaac.GetItemConfig()
	for id = 1, item_config:GetCollectibles().Size - 1 do
		local item_config_item = item_config:GetCollectible(id)
		if item_config_item then
			if item_config_item.Quality == quality 
			and (not item_config_item.Hidden) 
			and (not item_config_item:HasTags(ItemConfig.TAG_QUEST)) then
				table.insert(ItemList, id)
			end
		end
	end
	return ItemList
end

--强制添加道具（如果角色（里以撒）道具槽位已满，则在角色身边生成道具）
function Tools:AddCollectibleForcibly(player, collectible_type)
	local can_add_collectible = true
	if player:GetPlayerType() == PlayerType.PLAYER_ISAAC_B then
		local slot_capacity = 8
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
			slot_capacity = 12
		end
		local slot_remain = slot_capacity - player:GetCollectibleCount()
		local NoPassiveSlotItem = Tools:GetNoPassiveSlotItem()
		for i, j in pairs(NoPassiveSlotItem) do
			slot_remain = slot_remain + player:GetCollectibleNum(j)
		end
		if slot_remain <= 0 then
			can_add_collectible = false
		end
	end
	if can_add_collectible then
		player:AddCollectible(collectible_type)
	else
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, collectible_type, Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil)
	end
	return
end

--统计角色拥有的、品质为quality的道具数目，返回整数
function Tools:GetCollectibleNum_ByQuality(player, quality)
	local sum = 0
	ItemList_All = ItemList_All or Tools:GetAllSlotItem()
	for i, item in pairs(ItemList_All) do
		if Isaac.GetItemConfig():GetCollectible(item).Quality == quality then
			sum = sum + player:GetCollectibleNum(item)
		end
	end
	return sum
end

--统计角色拥有的、带有标签tag的道具数目，返回整数
function Tools:GetCollectibleNum_ByTags(player, tag)
	local sum = 0
	ItemList_All = ItemList_All or Tools:GetAllSlotItem()
	for i, item in pairs(ItemList_All) do
	--for i = 1, Isaac.GetItemConfig():GetCollectibles().Size do
		if Isaac.GetItemConfig():GetCollectible(item):HasTags(tag) then
			sum = sum + player:GetCollectibleNum(item)
		end
	end
	return sum
end

--随机生成/给予一个品质为quality的道具，返回道具（拾取物实体对象）（生成道具时）/nil（直接给予道具时）
function Tools:RandomCollectible_ByQuality(player, quality, rng, give_item_directly)
	local DefaultCollectibleType = {
		[0] = CollectibleType.COLLECTIBLE_POOP,
		[1] = CollectibleType.COLLECTIBLE_LUNCH,
		[2] = CollectibleType.COLLECTIBLE_CUBE_OF_MEAT,
		[3] = CollectibleType.COLLECTIBLE_STEVEN,
		[4] = CollectibleType.COLLECTIBLE_BRIMSTONE,
	}
	local ItemList_ByQuality = ItemList_ByQuality or Tools:GetAllItem_ByQuality(quality)
	local size = #ItemList_ByQuality
	local rand = Maths:RandomInt(size, rng, false, true)
	local attempts = 0
	local collectible_type = ItemList_ByQuality[rand]
	while collectible_type and player:HasCollectible(collectible_type) and attempts < size do
		rand = (rand % size) + 1
		attempts = attempts + 1
		collectible_type = ItemList_ByQuality[rand]
	end
	if attempts == size then
		collectible_type = DefaultCollectibleType[quality] or CollectibleType.COLLECTIBLE_BREAKFAST
	end
	if give_item_directly then
		player:AddCollectible(collectible_type)
		return nil
	else
		return Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, collectible_type, Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil)
	end
end

--播放某实体的特殊动画，返回“空白动画”（效果实体对象）
function Tools:PlayUniqueAnimation(entity, anim_name)
	local sprite = entity:GetSprite()
	local FILE = sprite:GetFilename()
	local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, modEffectVariant.BLANK_ANIM, 0, entity.Position, Vector(0, 0), entity)
	local effect_sprite = effect:GetSprite()
	effect_sprite:Load(FILE, true)
	effect_sprite:Play(anim_name)
	return effect
end

--模拟角色的“甩弹”效果，返回矢量
function Tools:GetSwingShotDir(mov_dir, shoot_dir, shot_speed)
	local X_hasVelocity = Maths:Sign(math.max(0, math.abs(mov_dir.X)))	--值为1则该轴上有速度分矢量，为0则无
	local Y_hasVelocity = Maths:Sign(math.max(0, math.abs(mov_dir.Y)))
	local X_isSameDir =	Maths:Sign(shoot_dir.X * mov_dir.X)				--值为1则该轴上角色朝向与速度分矢量同向，为-1则反向，为0则该轴上无与角色朝向共线的速度分矢量
	local Y_isSameDir =	Maths:Sign(shoot_dir.Y * mov_dir.Y)
	local isSwing = Vector(X_hasVelocity * Maths:Sign(X_isSameDir + X_hasVelocity), Y_hasVelocity * Maths:Sign(Y_isSameDir + Y_hasVelocity))	--分量为1则向该分矢量方向甩弹，分量为0则不甩弹

	return (shoot_dir + mov_dir * 0.125 * isSwing) * 10 * shot_speed
end

function Tools:GetHUDOffsetPos(unm_X, unm_Y)
	local game = Game()
	local HUDOffset = Options.HUDOffset
	local sign_X = 1
	if unm_X then
		sign_X = -1
	end
	local sign_Y = 1
	if unm_Y then
		sign_Y = -1
	end
	return Vector(sign_X * HUDOffset * 20, sign_Y * HUDOffset * 12)
end

function Tools:GetPlayerHUDOffsetPos(player)
	local unm_X = false
	local unm_Y = false
	local idx = Tools:GetUserIdx(player)
	if idx > 1 then
		unm_Y = true
	end
	if idx % 2 == 1 then
		unm_X = true
	end
	return Tools:GetHUDOffsetPos(unm_X, unm_Y)
end

--function Tools:GetPlayerMirrorWorldPos(player)		--已弃用：大房间中仍会出现错误
--	return (player.Position * Vector(-1, 1)) + Vector(640, 0)
--end

function Tools:GetEntityRenderScreenPos(entity, flip_X)		--参数flip_X在用于ModCallbacks.MC_POST_PLAYER_RENDER时设为true
	local game = Game()
	local IsMirrorWorld = (game:GetRoom():IsMirrorWorld())
	local world_pos = entity.Position + entity.PositionOffset
	local screen_pos = Isaac.WorldToScreen(world_pos)
	if IsMirrorWorld then
		if flip_X then
			return Vector(screen_pos.X, screen_pos.Y)
		else
			return Vector(Isaac.GetScreenWidth() - screen_pos.X, screen_pos.Y)
		end
	else
		return screen_pos
	end
end

--取prev_entity的堕化版本的Variant，返回整数或nil
function Tools:GetTaintedMonsterVariant(prev_entity)
	local type = prev_entity.Type
	local variant = prev_entity.Variant
	local TaintedMonsters = {
		[1] = {Type = EntityType.ENTITY_POOTER, Variant = 2, VariantOrig = 0,},
		[2] = {Type = EntityType.ENTITY_HIVE, Variant = 3, VariantOrig = 0,},
		[3] = {Type = EntityType.ENTITY_BOOMFLY, Variant = 6, VariantOrig = 0,},
		[4] = {Type = EntityType.ENTITY_HOPPER, Variant = 3, VariantOrig = 0,},
		[5] = {Type = EntityType.ENTITY_SPITTY, Variant = 1, VariantOrig = 0,},
		[6] = {Type = EntityType.ENTITY_SUCKER, Variant = 7, VariantOrig = 0,},
		[7] = {Type = EntityType.ENTITY_WALL_CREEP, Variant = 3, VariantOrig = 0,},
		--[8] = {Type = EntityType.ENTITY_ROUND_WORM, Variant = 2, VariantOrig = 0,},
		[8] = {Type = EntityType.ENTITY_ROUND_WORM, Variant = 3, VariantOrig = 1},
		[9] = {Type = EntityType.ENTITY_SUB_HORF, Variant = 1, VariantOrig = 0,},
		[10] = {Type = EntityType.ENTITY_FACELESS, Variant = 1, VariantOrig = 0,},
		[11] = {Type = EntityType.ENTITY_MOLE, Variant = 1, VariantOrig = 0,},
		[12] = {Type = EntityType.ENTITY_CHARGER_L2, Variant = 1, VariantOrig = 0,},
	}
	for i = 1, #TaintedMonsters do
		if TaintedMonsters[i].Type == type and variant ~= TaintedMonsters[i].Variant then
			return TaintedMonsters[i].Variant
		end
	end
	return nil
end

--判断是否显示HUD，返回逻辑
function Tools:CanShowHUD()
	local game = Game()
	return (not game:GetSeeds():HasSeedEffect(SeedEffect.SEED_NO_HUD)) and game:GetHUD():IsVisible() == true
end

--由使用主动道具的player和use_flag判断是否能够添加魂火，返回逻辑
function Tools:CanAddWisp(player, use_flag)
	return player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES)
		and (use_flag & UseFlag.USE_NOANIM == 0 
			or use_flag & UseFlag.USE_ALLOWWISPSPAWN > 0)
end

--由dmg_flags判断是否为自伤，返回逻辑
function Tools:IsSelfDamage(dmg_flags)
	return dmg_flags & (DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_NO_PENALTIES) > 0
end

--判断entity是否为幽灵类敌怪，返回逻辑
function Tools:IsGhostEnemy(entity)
	local ghost_enemy_list = {
		EntityType.ENTITY_WIZOOB,
		EntityType.ENTITY_THE_HAUNT,
		EntityType.ENTITY_RED_GHOST,
		EntityType.ENTITY_FORSAKEN,
		EntityType.ENTITY_POLTY,
		EntityType.ENTITY_CANDLER,
		EntityType.ENTITY_DUST,
		EntityType.ENTITY_RAINMAKER,
		EntityType.ENTITY_HERETIC,
		EntityType.ENTITY_CLUTCH,
	}
	for i, entity_type in ipairs(ghost_enemy_list) do
		if entity and entity.Type == entity_type then
			return true
		end
	end
	return false
end


--判断entity是否为独立的敌怪，返回逻辑
function Tools:IsIndividualEnemy(entity)
	if entity and entity:IsActiveEnemy(true) and (not entity:HasEntityFlags(EntityFlag.FLAG_ICE_FROZEN)) then
		local npc = entity:ToNPC()
		return npc and (npc.SpawnerType == 0 or npc.SpawnerType == nil)
	end
	return false
end

--判断entity在chance%的几率下是否能触发事件，返回逻辑
function Tools:CanTriggerEvent(entity, chance)
	if entity and entity.DropSeed then
		return entity.DropSeed % 10000 < chance * 100
	end
	return false
end

--判断entity在chance%的几率下是否能触发事件，返回逻辑
function Tools:RoomCanTriggerEvent(room_desc, chance)
	if room_desc and room_desc.SpawnSeed then
		return room_desc.SpawnSeed % 10000 < chance * 100
	end
	return false
end

--判断是否为同一实体，返回逻辑
function Tools:IsSameEntity(entity_A, entity_B)
	return (entity_A and entity_B) and (GetPtrHash(entity_A) == GetPtrHash(entity_B))
end

--取离other最近的角色实体，返回角色实体对象
function Tools:GetNearestPlayer(other)
	local player0 = Isaac.GetPlayer(0)
	local dis0 = other.Position:Distance(player0.Position)
	for p = 1, Game():GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(p)
		local dis = other.Position:Distance(player.Position)
		if dis < dis0 then
			dis0 = dis
			player0 = player
		end
	end
	return player0
end

--取离other最近的角色实体之距离，返回浮点数
function Tools:GetNearestPlayerDistance(other)
	local player0 = Tools:GetNearestPlayer(other)
	return other.Position:Distance(player0.Position)
end

--为player添加初始外观costume
function Tools:SetStartingCostume(player, costume)
	player:TryRemoveNullCostume(costume)
	player:AddNullCostume(costume)
end

local function ChangeSprite(player, sprite_path)
	local sprite = player:GetSprite()
	local anim = sprite:GetAnimation()
	local frame = sprite:GetFrame()
	local overlay_anim = sprite:GetOverlayAnimation()
	local overlay_frame = sprite:GetOverlayFrame()
	sprite:Load(sprite_path, true)
	sprite:SetFrame(anim, frame)
	sprite:SetOverlayFrame(overlay_anim, overlay_frame)
end

--尝试为player添加初始外观costume（仅针对本Mod角色），引入default_sprite_path防止装扮丢失
--[[
function Tools:TrySetStartingCostume(player, costume, default_sprite_path)	--//
	--local data = Tools:GetPlayerData(player)
	--local sprite = player:GetSprite()
	--data.StartingSpritePath = sprite:GetFilename()
	--print(data.StartingSpritePath)
	local starting_sprite_path = "gfx/001.000_player.anm2"

	if player.Variant == 0 then
		local data = Tools:GetPlayerData(player)
		if data.HasStartingCostume then
			if player:IsCoopGhost() then
				data.HasStartingCostume = false
			end
			if player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH) then
				if not data.HadMegaMushEffect then
					data.HadMegaMushEffect = true
					--if data.StartingSpritePath then
						print("ChangeSprite(player, data.StartingSpritePath)")
						ChangeSprite(player, starting_sprite_path)
					--end
				end
			else
				if data.HadMegaMushEffect then
					data.HadMegaMushEffect = false
					ChangeSprite(player, default_sprite_path)
				end
			end
		elseif not player:IsCoopGhost() then
			--local sprite = player:GetSprite()
			--data.StartingSpritePath = sprite:GetFilename()
			--print(data.StartingSpritePath)
			Tools:SetStartingCostume(player, costume)
			ChangeSprite(player, default_sprite_path)
			data.HasStartingCostume = true
		end
		ChangeSprite(player, default_sprite_path)
	end
end
]]

function Tools:TrySetStartingCostume(player, costume, starting_sprite_path)
	local default_sprite_path = "gfx/001.000_player.anm2"
	local used_path = starting_sprite_path
	local should_use_default_costume = false
	if player.Variant == 0 then
		local data = Tools:GetPlayerData(player)
		if data.StartingCostumeData == nil then
			data.StartingCostumeData = {
				UsingDefaultCostume = true,
			}
			Tools:SetStartingCostume(player, costume)
			--ChangeSprite(player, starting_sprite_path)
		end
		if player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH) and (not player:HasCurseMistEffect()) then
			should_use_default_costume = true
			used_path = default_sprite_path
		end
		--if player:HasCurseMistEffect() then
		--	should_use_default_costume = false
		--end
		if Common:Xor(data.StartingCostumeData.UsingDefaultCostume, should_use_default_costume) then
			--if player:HasCurseMistEffect() then
			--	if not data.StartingCostumeData.HadCurseMistEffect then
			--		data.StartingCostumeData.HadCurseMistEffect = true
			--		ChangeSprite(player, starting_sprite_path)
			--	end
			--else
				ChangeSprite(player, used_path)
				--used_path = default_sprite_path
				data.StartingCostumeData.UsingDefaultCostume = should_use_default_costume
			--end
		end
		--if player:HasCurseMistEffect() then
		--	if not data.StartingCostumeData.HadCurseMistEffect then
		--		data.StartingCostumeData.HadCurseMistEffect = true
		--		ChangeSprite(player, starting_sprite_path)
		--	end
		--end
	end
end
--[[
function Tools:TrySetStartingCostume(player, costume, default_sprite_path)
	if player.Variant == 0 then
		local data = Tools:GetPlayerData(player)
		--print("data.HasStartingCostume: " .. tostring(data.HasStartingCostume))
		if data.HasStartingCostume then
			if player:IsCoopGhost() then
				data.HasStartingCostume = false
			end
			if player:HasCurseMistEffect() then
				if not data.HadCurseMistEffect then
					data.HadCurseMistEffect = true
					ChangeSprite(player, default_sprite_path)
				end
			end
		elseif not player:IsCoopGhost() then
			Tools:SetStartingCostume(player, costume)
			data.HasStartingCostume = true
		end
	end
end
]]
--[[
function Tools:StartingCostume_OnInit(player)
	if player.Variant == 0 then
		local data = Tools:GetPlayerData(player)
		data.HasStartingCostume = false
		data.HadMegaMushEffect = false
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Tools.StartingCostume_OnInit, 0)
]]
--[[
function Tools:StartingCostume_PostNewRoom()
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = Isaac.GetPlayer(p)
		local data = Tools:GetPlayerData(player)
		if data.HasStartingCostume then
			data.HasStartingCostume = false
			--print("new room")
		end
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.LATE, Tools.StartingCostume_PostNewRoom)
]]

--取room_desc对应房间维度，返回整数
function Tools:GetDimByRoomDesc(room_desc)
	local level = Game():GetLevel()
	for dim = 0, 2 do
		local room_desc_in_dim = level:GetRoomByIdx(desc.SafeGridIndex, dim)
		if GetPtrHash(room_desc) == GetPtrHash(room_desc_in_dim) then
			return dim
		end
	end
	return -1
end

--取角色射击方向，返回矢量
function Tools:GetShootingDir(player)
	local dir = player:GetFireDirection()
	if dir ~= Direction.NO_DIRECTION and player:AreControlsEnabled() then
		if dir == Direction.UP then
			return Vector(0, -1)
		elseif dir == Direction.DOWN then
			return Vector(0, 1)
		elseif dir == Direction.LEFT then
			return Vector(-1, 0)
		elseif dir == Direction.RIGHT then
			return Vector(1, 0)
		end
	end
	return Vector(0, 0)
end

function Tools:GetShootingJoystick(player)
	if not player:AreControlsEnabled() then
		return Vector(0, 0)
	end
	local controller_idx = player.ControllerIndex
	if Options.MouseControl and controller_idx == 0 then
		if Input.IsMouseBtnPressed(controller_idx) then
			return (Input.GetMousePosition(true) - player.Position):Normalized()
		end
	end
	return player:GetShootingJoystick()
end

function Tools:GetActualShootingDir(player, analog)
	if analog == true or player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) then
		return Tools:GetShootingJoystick(player)
	else
		return Tools:GetShootingDir(player)
	end
end

function Tools:GetCachedShootingDir(player)
	local data = Tools:GetPlayerData(player)
	return data.CachedShootingDir or Vector(0, 1)
end

function Tools:UpdateCachedShootingDir(player)
	local data = Tools:GetPlayerData(player)
	data.CachedShootingDir = data.CachedShootingDir or Vector(0, 1)
	local dir = Tools:GetShootingJoystick(player)
	if dir:Length() > 0 then
		data.CachedShootingDir = dir
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Tools.UpdateCachedShootingDir)

function Tools:GetMovingDir(player)
	local idx = player.ControllerIndex
	local dir_X = Input.GetActionValue(ButtonAction.ACTION_RIGHT, idx) - Input.GetActionValue(ButtonAction.ACTION_LEFT, idx)
	local dir_Y = Input.GetActionValue(ButtonAction.ACTION_DOWN, idx) - Input.GetActionValue(ButtonAction.ACTION_UP, idx)
	return Vector(dir_X, dir_Y)
end

do
	--“双击+按住”式操作设计思路：类比时序逻辑电路（Mealy型），每个更新帧为一个时钟脉冲
	local States = {
		INIT = 0,	--无输入：状态不变；有输入：记录方向、转到TAP
		TAP = 1,	--无输入：重置时限、转到WAIT；有输入：状态不变
		WAIT = 2,	--时限未归零：无输入则扣减时限、状态不变，有输入且方向不变则触发“按住”事件、转到HOLD，有输入但方向改变则记录方向、转回TAP；时限已归零：转回INIT
		HOLD = 3,	--无输入：重置时限、触发“释放”事件、转回WAIT；有输入：触发“按住”事件、记录方向、状态不变
	}

	local CallbackParams = {
		STANDBY = 0,
		HOLD = 1,
		RELEASE = 2,
	}

	function Tools:TapAndHold_PlayerDataInit(player)
		local data = Tools:GetPlayerData(player)
		if data.MovingData == nil then
			data.MovingData = {
				State = States.INIT,
				PrevDir = Vector(0, 0),
				Timeout = 0,
			}
		end
		if data.ShootingData == nil then
			data.ShootingData = {
				State = States.INIT,
				PrevDir = Vector(0, 0),
				Timeout = 0,
			}
		end
	end
	ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Tools.TapAndHold_PlayerDataInit)

	function Tools:TapAndHold_SetInitStateForcibly_Moving(player, trigger_release)
		if trigger_release == nil then
			trigger_release = false
		end
		local data = Tools:GetPlayerData(player)
		if data.MovingData then
			data.MovingData.State = States.INIT
			if trigger_release then
				Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_TAP_AND_HOLD_MOVING, CallbackParams.RELEASE, data.MovingData.PrevDir, player)
			end
		end
	end

	function Tools:TapAndHold_SetInitStateForcibly_Shooting(player, trigger_release)
		if trigger_release == nil then
			trigger_release = false
		end
		local data = Tools:GetPlayerData(player)
		if data.ShootingData then
			data.ShootingData.State = States.INIT
			if trigger_release then
				Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_TAP_AND_HOLD_SHOOTING, CallbackParams.RELEASE, data.ShootingData.PrevDir, player)
			end
		end
	end

	function Tools:TapAndHold_TriggerReleaseForcibly_Moving(player)
		local data = Tools:GetPlayerData(player)
		if data.MovingData then
			Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_TAP_AND_HOLD_MOVING, CallbackParams.RELEASE, data.MovingData.PrevDir, player)
		end
	end

	function Tools:TapAndHold_TriggerReleaseForcibly_Shooting(player)
		local data = Tools:GetPlayerData(player)
		if data.ShootingData then
			Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_TAP_AND_HOLD_SHOOTING, CallbackParams.RELEASE, data.ShootingData.PrevDir, player)
		end
	end

	function Tools:TapAndHold_OnUpdate(player)
		local data = Tools:GetPlayerData(player)
		local idx = player.ControllerIndex
		local MaxTimeout = 6
		if data.MovingData then
			local is_standby = true
			local dir = Tools:GetMovingDir(player)
			local min_value = 0.5
			--local has_input = math.abs(dir.X) >= min_value or math.abs(dir.Y) >= min_value
			local has_input = math.abs(Input.GetActionValue(ButtonAction.ACTION_RIGHT, idx)) >= min_value 
							or math.abs(Input.GetActionValue(ButtonAction.ACTION_LEFT, idx)) >= min_value 
							or math.abs(Input.GetActionValue(ButtonAction.ACTION_DOWN, idx)) >= min_value 
							or math.abs(Input.GetActionValue(ButtonAction.ACTION_UP, idx)) >= min_value
			--print(data.MovingData.State)
			if data.MovingData.State == States.INIT then
				if has_input then
					data.MovingData.PrevDir = dir
					data.MovingData.State = States.TAP
				end
			elseif data.MovingData.State == States.TAP then
				if not has_input then
					data.MovingData.Timeout = MaxTimeout
					data.MovingData.State = States.WAIT
				end
			elseif data.MovingData.State == States.WAIT then
				local accuracy = 10
				local angle = math.deg(math.acos((data.MovingData.PrevDir):Dot(dir)))
				--print("prev_X: " .. data.MovingData.PrevDir.X .. " " .. "prev_Y: " .. data.MovingData.PrevDir.Y)
				--print("X: " .. dir.X .. " " .. "Y: " .. dir.Y)
				--print(angle)
				if data.MovingData.Timeout > 0 then
					if has_input then
						if math.abs(angle) <= accuracy then	--检测第二次输入方向是否与第一次相同或相近
							Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_TAP_AND_HOLD_MOVING, CallbackParams.HOLD, dir, player)
							is_standby = false
							data.MovingData.State = States.HOLD
						else
							data.MovingData.PrevDir = dir
							data.MovingData.State = States.TAP
						end
					else
						data.MovingData.Timeout = data.MovingData.Timeout - 1
					end
				else
					data.MovingData.State = States.INIT
				end
			else
				if has_input then
					data.MovingData.PrevDir = dir
					Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_TAP_AND_HOLD_MOVING, CallbackParams.HOLD, dir, player)
					is_standby = false
				else
					data.MovingData.Timeout = MaxTimeout
					Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_TAP_AND_HOLD_MOVING, CallbackParams.RELEASE, data.MovingData.PrevDir, player)
					is_standby = false
					data.MovingData.State = States.WAIT
				end
			end
			if is_standby == true then
				Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_TAP_AND_HOLD_MOVING, CallbackParams.STANDBY, data.MovingData.PrevDir, player)
			end
		end

		if data.ShootingData then
			local is_standby = true
			local dir = Tools:GetShootingJoystick(player)
			local has_input = dir:Length() > 0 
							or (math.abs(Input.GetActionValue(ButtonAction.ACTION_SHOOTRIGHT, idx)) > 0 
								and math.abs(Input.GetActionValue(ButtonAction.ACTION_SHOOTLEFT, idx)) > 0) 
							or (math.abs(Input.GetActionValue(ButtonAction.ACTION_SHOOTDOWN, idx)) > 0 
								and math.abs(Input.GetActionValue(ButtonAction.ACTION_SHOOTUP, idx)) > 0)
			--local has_input = math.abs(Input.GetActionValue(ButtonAction.ACTION_SHOOTRIGHT, idx)) > 0 
			--				or math.abs(Input.GetActionValue(ButtonAction.ACTION_SHOOTLEFT, idx)) > 0 
			--				or math.abs(Input.GetActionValue(ButtonAction.ACTION_SHOOTDOWN, idx)) > 0 
			--				or math.abs(Input.GetActionValue(ButtonAction.ACTION_SHOOTUP, idx)) > 0

			--print("state: " .. data.ShootingData.State)
			--print("prev_X: " .. data.ShootingData.PrevDir.X .. " " .. "prev_Y: " .. data.ShootingData.PrevDir.Y)
			--print("X: " .. dir.X .. " " .. "Y: " .. dir.Y)

			if data.ShootingData.State == States.INIT then
				if has_input then
					data.ShootingData.PrevDir = dir
					data.ShootingData.State = States.TAP
				end
			elseif data.ShootingData.State == States.TAP then
				if not has_input then
					data.ShootingData.Timeout = MaxTimeout
					data.ShootingData.State = States.WAIT
				end
			elseif data.ShootingData.State == States.WAIT then
				local accuracy = 10
				local angle = math.deg(math.acos((data.ShootingData.PrevDir):Dot(dir)))
				if data.ShootingData.Timeout > 0 then
					if has_input then
						if math.abs(angle) <= accuracy then		--检测第二次输入方向是否与第一次相同或相近
							Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_TAP_AND_HOLD_SHOOTING, CallbackParams.HOLD, dir, player)
							is_standby = false
							data.ShootingData.State = States.HOLD
						else
							data.ShootingData.PrevDir = dir
							data.ShootingData.State = States.TAP
						end
					else
						data.ShootingData.Timeout = data.ShootingData.Timeout - 1
					end
				else
					data.ShootingData.State = States.INIT
				end
			else
				if has_input then
					data.ShootingData.PrevDir = dir
					Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_TAP_AND_HOLD_SHOOTING, CallbackParams.HOLD, dir, player)
					is_standby = false
				else
					data.ShootingData.Timeout = MaxTimeout
					Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_TAP_AND_HOLD_SHOOTING, CallbackParams.RELEASE, data.ShootingData.PrevDir, player)
					is_standby = false
					data.ShootingData.State = States.WAIT
				end
			end
			if is_standby == true then
				Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_TAP_AND_HOLD_SHOOTING, CallbackParams.STANDBY, data.ShootingData.PrevDir, player)
			end
		end
	end
	ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Tools.TapAndHold_OnUpdate)
end

--角色道具相关：初始化数据
function Tools:AddCollectible_PlayerDataInit(player)
	local data = Tools:GetPlayerData(player)
	if data.CollectibleNumTable == nil then
		data.CollectibleNumTable = {}
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Tools.AddCollectible_PlayerDataInit)

--角色道具相关：运行回调函数
function Tools:AddCollectible_RunCallback(player)
	local data = Tools:GetPlayerData(player)
	if data.CollectibleNumTable then
		local item_list = Tools:GetAllSlotItem()
		for _, collectible_type in pairs(item_list) do
			if player:HasCollectible(collectible_type, true) then
				local num = player:GetCollectibleNum(collectible_type, true)
				local rng = player:GetCollectibleRNG(collectible_type)
				local is_newly_added = true
				local key = tostring(collectible_type)
				if data.CollectibleNumTable[key] == nil then
					data.CollectibleNumTable[key] = {
						CurrentNum = num,
						CachedMaxNum = num,
					}
					for i = 1, num do
						Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_POST_ADD_COLLECTIBLE, collectible_type, collectible_type, rng, player, is_newly_added)
					end
				else
					if data.CollectibleNumTable[key].CurrentNum > num then
						data.CollectibleNumTable[key].CurrentNum = num
					else
						while data.CollectibleNumTable[key].CurrentNum < num do
							if data.CollectibleNumTable[key].CurrentNum <= data.CollectibleNumTable[key].CachedMaxNum then
								is_newly_added = false
							end
							Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_POST_ADD_COLLECTIBLE, collectible_type, collectible_type, rng, player, is_newly_added)
							data.CollectibleNumTable[key].CurrentNum = data.CollectibleNumTable[key].CurrentNum + 1
						end
						if data.CollectibleNumTable[key].CachedMaxNum < num then
							data.CollectibleNumTable[key].CachedMaxNum = num
						end
					end
				end
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Tools.AddCollectible_RunCallback)

--无敌时间相关
local function Immunity_GetImmunityData()
	local data = Tools:GetPlayerData(player)
	data.ImmunityData = data.ImmunityData or {
		DamageCooldown = 0,
		ShouldBlink = false,
	}
	return data.ImmunityData
end

function Tools:Immunity_GetDamageCooldown(player)
	local data = Immunity_GetImmunityData()
	return data.DamageCooldown or 0
end

function Tools:Immunity_SetDamageCooldown(player, value)
	local data = Immunity_GetImmunityData()
	data.DamageCooldown = math.max(0, value)
end

function Tools:Immunity_ModifyDamageCooldown(player, amount)
	local data = Immunity_GetImmunityData()
	if data.DamageCooldown then
		data.DamageCooldown = math.max(0, data.DamageCooldown + amount)
	end
end

function Tools:Immunity_ShouldBlink(player)
	local data = Immunity_GetImmunityData()
	return data.ShouldBlink
end

function Tools:Immunity_SetIfShouldBlink(player, value)
	local data = Immunity_GetImmunityData()
	data.ShouldBlink = value
end

function Tools:Immunity_AddImmuneEffect(player, cd, blink)
	Tools:Immunity_ModifyDamageCooldown(player, cd)
	player:SetMinDamageCooldown(1)
	if not blink then
		player:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK)
		Tools:Immunity_SetIfShouldBlink(player, false)
	else
		Tools:Immunity_SetIfShouldBlink(player, true)
	end
end

function Tools:Immunity_PostPlayerUpdate(player)
	local data = Tools:GetPlayerData(player)
	if Tools:Immunity_GetDamageCooldown(player) > 0 then
		player:SetMinDamageCooldown(1)
		if not Tools:Immunity_ShouldBlink(player) then
			player:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK)
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Tools.Immunity_PostPlayerUpdate)

function Tools:Immunity_PostPlayerEffectUpdate(player)
	Tools:Immunity_ModifyDamageCooldown(player, -1)
end
ModRef:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Tools.Immunity_PostPlayerEffectUpdate)

function Tools:Immunity_PostNewRoom()
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = Game():GetPlayer(p)
		Tools:Immunity_SetDamageCooldown(player, 0)
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Tools.Immunity_PostNewRoom)

--贪婪模式相关：初始化数据
function Tools:Greed_GameDataInit()
	if tbom.TempData.GameData["GreedModeWaveCount"] == nil then
		tbom.TempData.GameData["GreedModeWaveCount"] = 0
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_UPDATE, Tools.Greed_GameDataInit)

--贪婪模式相关：运行回调函数
function Tools:Greed_RunCallback()
	if (Game():IsGreedMode()) then
		local level = Game():GetLevel()
		local current_wave = level.GreedModeWave
		local GreedModeWaveCount = (tbom.TempData.GameData["GreedModeWaveCount"] or 0)
		if current_wave > GreedModeWaveCount then
			Isaac.RunCallback(tbomCallbacks.TBOMC_POST_NEW_GREED_MODE_WAVE, current_wave)
			tbom.TempData.GameData["GreedModeWaveCount"] = current_wave
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_UPDATE, Tools.Greed_RunCallback)

--全局相关
function Tools:Global_GameDataInit()
	if tbom.TempData.GameData["MomKilled"] == nil then
		tbom.TempData.GameData["MomKilled"] = false
	end
	if tbom.TempData.GameData["MomsHeartKilled"] == nil then
		tbom.TempData.GameData["MomsHeartKilled"] = false
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_UPDATE, Tools.Global_GameDataInit)

function Tools:MomKilled()
	return tbom.TempData.GameData["MomKilled"] == true
end

function Tools:SetMomKilled(value)
	tbom.TempData.GameData["MomKilled"] = value
end

function Tools:MomsHeartKilled()
	return tbom.TempData.GameData["MomsHeartKilled"] == true
end

function Tools:SetMomsHeartKilled(value)
	tbom.TempData.GameData["MomsHeartKilled"] = value
end

function Tools:GameData_AddAttribute(key, starting_value)
	if tbom.TempData.GameData[key] == nil then
		tbom.TempData.GameData[key] = starting_value
	end
end

function Tools:GameData_GetAttribute(key, try_init_as_table)
	if try_init_as_table then
		tbom.TempData.GameData[key] = tbom.TempData.GameData[key] or {}
	end
	return tbom.TempData.GameData[key]
end

function Tools:GameData_SetAttribute(key, value)
	tbom.TempData.GameData[key] = value
end

function Tools:GameData_ModifyAttribute(key, amount, is_unsigned)
	if is_unsigned == nil then
		is_unsigned = true
	end
	if type(tbom.TempData.GameData[key]) == "number" and type(amount) == "number" then
		if is_unsigned then
			tbom.TempData.GameData[key] = math.max(0, tbom.TempData.GameData[key] + amount)
		else
			tbom.TempData.GameData[key] = tbom.TempData.GameData[key] + amount
		end
	end
end

function Tools:GameData_ClearAttribute(key)
	tbom.TempData.GameData[key] = nil
end

--取道具数据
function Tools:Global_GetCollectibleData(collectible_type)
	local data = Tools:GameData_GetAttribute("CollectibleData", true)
	local item_config_item = Isaac.GetItemConfig():GetCollectible(collectible_type)
	if item_config_item and item_config_item.Name then
		local idx = "Collectible:" .. string.gsub(item_config_item.Name, "%s", "_")
		data[idx] = data[idx] or {}
		return data[idx]
	end
	local idx_null = "Collectible:Null"
	data[idx_null] = data[idx_null] or {}
	return data[idx_null]
end

--取饰品数据
function Tools:Global_GetTrinketData(trinket_type)
	local data = Tools:GameData_GetAttribute("TrinketData", true)
	local item_config_item = Isaac.GetItemConfig():GetTrinket(trinket_type)
	if item_config_item and item_config_item.Name then
		local idx = "Trinket:" .. string.gsub(item_config_item.Name, "%s", "_")
		data[idx] = data[idx] or {}
		return data[idx]
	end
	local idx_null = "Trinket:Null"
	data[idx_null] = data[idx_null] or {}
	return data[idx_null]
end

--取卡牌数据
function Tools:Global_GetCardData(card)
	local data = Tools:GameData_GetAttribute("CardData", true)
	local item_config_card = Isaac.GetItemConfig():GetCard(card)
	if item_config_card and item_config_card.Name then
		local idx = "Card:" .. string.gsub(item_config_card.Name, "%s", "_")
		data[idx] = data[idx] or {}
		return data[idx]
	end
	local idx_null = "Card:Null"
	data[idx_null] = data[idx_null] or {}
	return data[idx_null]
end

--取一般拾取物数据
function Tools:Global_GetPickupData(pickup_variant)
	local data = Tools:GameData_GetAttribute("PickupData", true)
	if pickup_variant == nil or pickup_variant <= 0 then
		local idx_null = "Pickup:Null"
		data[idx_null] = data[idx_null] or {}
		return data[idx_null]
	end
	local idx = "Pickup:" .. tostring(pickup_variant)
	data[idx] = data[idx] or {}
	return data[idx]
end


return Tools