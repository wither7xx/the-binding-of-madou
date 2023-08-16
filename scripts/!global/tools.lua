local Tools = {}

local ModRef = tbom
local Common = tbom.Global.Common
local Maths = tbom.Global.Maths

local tbomCallbacks = tbom.tbomCallbacks
local modEffectVariant = tbom.modEffectVariant

--��Ϸ�������
function Tools:GameDataInit(is_continued)
	if not is_continued then
		tbom.TempData.GameData = {}
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Tools.GameDataInit, 0)

--NPCʵ������������
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

--Ч��ʵ������������
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

--�洢��ɫʵ���������ʱ�����ţ�
--Isaac.GetPlayer()��Game().GetPlayer()����ʹ����ɫ��Ŀ����ʱ���������Ƴ�����Ȩʱ/ȥ����Ʒ��ʱ���ᵼ�»���
--EntityPlayer.ControllerIndex����ʹ��û������˫��/����/���/������/�Ǹ��ʯ/˫�ӻ�ʯ��
--EntityPlayer.GetData()����ʹ��С�˴��˶������ã��治ס
--GetPtrHash()����ʹ���˳��ؽ�ʱ��ֵˢ�£��治ס
--EntityPlayer.InitSeed����ʹ����ɫ��Ŀ����ʱ����ʹ�ñ�˫��/����/��Ʒ��ʱ���ᵼ�»���
--���������EntityPlayer.GetCollectibleRNG()�����Ǵ洢�����ֲ�ͬ��ҵ����ݵ�Ψһ�ĺ÷���
--�µ����ţ���ΪRNG������ʱ���ڱ仯������ֱ����RNG����������ܿ�ɱ����ڴ浼�����ˣ�������Ҫ�������㶨�����ʵ�֣�
--�����������RNG.GetSeed()ȡ����RNG��������ӣ���������������������ͬһ���ڶԲ�ͬ��ɫΨһ�Һ㶨
--�µ�����֮��������Global.Tools.GetPlayerIndex()���ֱ�˫��/����/��Ʒ�ޣ������������û�(User)�ᵼ�´���EntityPlayer.ControllerIndex�����ֱ�˫��/����/��Ʒ�ޣ���Ҳֻ�����������豸����ţ����������û�����ţ������һ��ʹ���ֱ����û�ʱ�ᵼ�´��󣩣�������Ҫ�����û�����ž���HUD���֣����ʵ�֣�
--����������޸�Global.Tools.GetPlayerIndex()��ʹ֮�ܹ����ֶ��趨�Ƿ����ֱ�˫��/����/��Ʒ�ޣ�ͬʱ����TempData.PlayerData_UserRegister�洢ǰ�߷��ص�������Ӧ�ĵ�ǰ�û�����š�����TempData.PlayerData_Static�洢��ǰ�û�����Ŀ��Ĭ��ֻ����������ÿ�����ã�
--�µ�����֮��������Global.Tools.GetPlayerIndex()����ʹ��С���ʱ��С����Ϊ2P����ν����

--��ʼ����ɫ���ݡ��û��Ĵ������ɫ��̬����
function Tools:PlayerDataInit(is_continued)
	if not is_continued then
		tbom.TempData.PlayerData = {}
		tbom.TempData.PlayerData_UserRegister = {}
		tbom.TempData.PlayerData_Static["UserNum"] = 0
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Tools.PlayerDataInit, 0)

--ȡ��ɫ������ignore_pairing��Ϊfalse��/�û�������ignore_pairing��Ϊtrue������������
function Tools:GetPlayerIndex(player, ignore_pairing)
	local CollectibleRNG = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_SAD_ONION)
	local collectible_type = CollectibleType.COLLECTIBLE_SAD_ONION
	local player_type = player:GetPlayerType()
	--����һ�����ߵ�RNG�����ֱ�˫��/�����ı���̬������̬
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

--ȡ��ɫ���ݣ���������½�ɫ�����˫��/����/��Ʒ�ޣ������¼���Ĳ��ֳ�ʼ��
function Tools:GetPlayerData(player)
	local idx = Tools:GetPlayerIndex(player, false)
	tbom.TempData.PlayerData[idx] = tbom.TempData.PlayerData[idx] or {}
	return tbom.TempData.PlayerData[idx]
end

--ȡ��ɫ��������
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

--ȡ��ɫ��Ʒ����
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

--ȡ��ɫ��������
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

--ȡ��ɫһ��ʰȡ������
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

--����û��Ĵ���������������û������ɵ���ģʽ��Ϊ����ģʽʱ�������¼���Ĳ��ֳ�ʼ��
function Tools:CheckUserNum(player)
	local idx_user = Tools:GetPlayerIndex(player, true)
	if tbom.TempData.PlayerData_UserRegister[idx_user] == nil then
		tbom.TempData.PlayerData_UserRegister[idx_user] = tbom.TempData.PlayerData_Static["UserNum"]
		tbom.TempData.PlayerData_Static["UserNum"] = tbom.TempData.PlayerData_Static["UserNum"] + 1
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CallbackPriority.IMPORTANT, Tools.CheckUserNum, 0)

--ȡ��ǰ�û���Ŀ����������
function Tools:GetUserNum()
	return tbom.TempData.PlayerData_Static["UserNum"] or 1
end

--�ɽ�ɫ����ȡ�û���������������
function Tools:GetUserIdx(player)
	local idx_user = Tools:GetPlayerIndex(player, true)
	return tbom.TempData.PlayerData_UserRegister[idx_user] or 0
end

--��ɫ������أ���������
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

--�ж�player�Ƿ�Ϊԭ���ɫ
function Tools:IsOriginalCharacter(player)
	local player_type = player:GetPlayerType()
	return player_type < PlayerType.NUM_PLAYER_TYPES
end

--�ж�collectible_type�Ƿ�Ϊ��ռ������λ�ĵ��ߣ��������ߡ�������ߡ�����Ȩ���������߼�
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

--ͳ�����е��ߣ���������
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

--ͳ�����в�ռ������λ�ĵ��ߣ���������
function Tools:GetNoPassiveSlotItem()
	local ItemList = {}
	for id = 1, Isaac.GetItemConfig():GetCollectibles().Size - 1 do
		if Tools:IsNoPassiveSlotItem(id) then
			table.insert(ItemList, id)
		end
	end
	return ItemList
end

--ͳ������Ʒ��Ϊquality�ĵ��ߣ��������飨�������ص��ߺ�������ߣ�
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

--ǿ����ӵ��ߣ������ɫ�������������߲�λ���������ڽ�ɫ������ɵ��ߣ�
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

--ͳ�ƽ�ɫӵ�еġ�Ʒ��Ϊquality�ĵ�����Ŀ����������
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

--ͳ�ƽ�ɫӵ�еġ����б�ǩtag�ĵ�����Ŀ����������
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

--�������/����һ��Ʒ��Ϊquality�ĵ��ߣ����ص��ߣ�ʰȡ��ʵ����󣩣����ɵ���ʱ��/nil��ֱ�Ӹ������ʱ��
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

--����ĳʵ������⶯�������ء��հ׶�������Ч��ʵ�����
function Tools:PlayUniqueAnimation(entity, anim_name)
	local sprite = entity:GetSprite()
	local FILE = sprite:GetFilename()
	local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, modEffectVariant.BLANK_ANIM, 0, entity.Position, Vector(0, 0), entity)
	local effect_sprite = effect:GetSprite()
	effect_sprite:Load(FILE, true)
	effect_sprite:Play(anim_name)
	return effect
end

--ģ���ɫ�ġ�˦����Ч��������ʸ��
function Tools:GetSwingShotDir(mov_dir, shoot_dir, shot_speed)
	local X_hasVelocity = Maths:Sign(math.max(0, math.abs(mov_dir.X)))	--ֵΪ1����������ٶȷ�ʸ����Ϊ0����
	local Y_hasVelocity = Maths:Sign(math.max(0, math.abs(mov_dir.Y)))
	local X_isSameDir =	Maths:Sign(shoot_dir.X * mov_dir.X)				--ֵΪ1������Ͻ�ɫ�������ٶȷ�ʸ��ͬ��Ϊ-1����Ϊ0������������ɫ�����ߵ��ٶȷ�ʸ��
	local Y_isSameDir =	Maths:Sign(shoot_dir.Y * mov_dir.Y)
	local isSwing = Vector(X_hasVelocity * Maths:Sign(X_isSameDir + X_hasVelocity), Y_hasVelocity * Maths:Sign(Y_isSameDir + Y_hasVelocity))	--����Ϊ1����÷�ʸ������˦��������Ϊ0��˦��

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

--function Tools:GetPlayerMirrorWorldPos(player)		--�����ã��󷿼����Ի���ִ���
--	return (player.Position * Vector(-1, 1)) + Vector(640, 0)
--end

function Tools:GetEntityRenderScreenPos(entity, flip_X)		--����flip_X������ModCallbacks.MC_POST_PLAYER_RENDERʱ��Ϊtrue
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

--ȡprev_entity�Ķ黯�汾��Variant������������nil
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

--�ж��Ƿ���ʾHUD�������߼�
function Tools:CanShowHUD()
	local game = Game()
	return (not game:GetSeeds():HasSeedEffect(SeedEffect.SEED_NO_HUD)) and game:GetHUD():IsVisible() == true
end

--��ʹ���������ߵ�player��use_flag�ж��Ƿ��ܹ���ӻ�𣬷����߼�
function Tools:CanAddWisp(player, use_flag)
	return player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES)
		and (use_flag & UseFlag.USE_NOANIM == 0 
			or use_flag & UseFlag.USE_ALLOWWISPSPAWN > 0)
end

--��dmg_flags�ж��Ƿ�Ϊ���ˣ������߼�
function Tools:IsSelfDamage(dmg_flags)
	return dmg_flags & (DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_NO_PENALTIES) > 0
end

--�ж�entity�Ƿ�Ϊ������й֣������߼�
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


--�ж�entity�Ƿ�Ϊ�����ĵй֣������߼�
function Tools:IsIndividualEnemy(entity)
	if entity and entity:IsActiveEnemy(true) and (not entity:HasEntityFlags(EntityFlag.FLAG_ICE_FROZEN)) then
		local npc = entity:ToNPC()
		return npc and (npc.SpawnerType == 0 or npc.SpawnerType == nil)
	end
	return false
end

--�ж�entity��chance%�ļ������Ƿ��ܴ����¼��������߼�
function Tools:CanTriggerEvent(entity, chance)
	if entity and entity.DropSeed then
		return entity.DropSeed % 10000 < chance * 100
	end
	return false
end

--�ж�entity��chance%�ļ������Ƿ��ܴ����¼��������߼�
function Tools:RoomCanTriggerEvent(room_desc, chance)
	if room_desc and room_desc.SpawnSeed then
		return room_desc.SpawnSeed % 10000 < chance * 100
	end
	return false
end

--�ж��Ƿ�Ϊͬһʵ�壬�����߼�
function Tools:IsSameEntity(entity_A, entity_B)
	return (entity_A and entity_B) and (GetPtrHash(entity_A) == GetPtrHash(entity_B))
end

--ȡ��other����Ľ�ɫʵ�壬���ؽ�ɫʵ�����
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

--ȡ��other����Ľ�ɫʵ��֮���룬���ظ�����
function Tools:GetNearestPlayerDistance(other)
	local player0 = Tools:GetNearestPlayer(other)
	return other.Position:Distance(player0.Position)
end

--Ϊplayer��ӳ�ʼ���costume
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

--����Ϊplayer��ӳ�ʼ���costume������Ա�Mod��ɫ��������default_sprite_path��ֹװ�綪ʧ
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

--ȡroom_desc��Ӧ����ά�ȣ���������
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

--ȡ��ɫ������򣬷���ʸ��
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
	--��˫��+��ס��ʽ�������˼·�����ʱ���߼���·��Mealy�ͣ���ÿ������֡Ϊһ��ʱ������
	local States = {
		INIT = 0,	--�����룺״̬���䣻�����룺��¼����ת��TAP
		TAP = 1,	--�����룺����ʱ�ޡ�ת��WAIT�������룺״̬����
		WAIT = 2,	--ʱ��δ���㣺��������ۼ�ʱ�ޡ�״̬���䣬�������ҷ��򲻱��򴥷�����ס���¼���ת��HOLD�������뵫����ı����¼����ת��TAP��ʱ���ѹ��㣺ת��INIT
		HOLD = 3,	--�����룺����ʱ�ޡ��������ͷš��¼���ת��WAIT�������룺��������ס���¼�����¼����״̬����
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
						if math.abs(angle) <= accuracy then	--���ڶ������뷽���Ƿ����һ����ͬ�����
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
						if math.abs(angle) <= accuracy then		--���ڶ������뷽���Ƿ����һ����ͬ�����
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

--��ɫ������أ���ʼ������
function Tools:AddCollectible_PlayerDataInit(player)
	local data = Tools:GetPlayerData(player)
	if data.CollectibleNumTable == nil then
		data.CollectibleNumTable = {}
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Tools.AddCollectible_PlayerDataInit)

--��ɫ������أ����лص�����
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

--�޵�ʱ�����
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

--̰��ģʽ��أ���ʼ������
function Tools:Greed_GameDataInit()
	if tbom.TempData.GameData["GreedModeWaveCount"] == nil then
		tbom.TempData.GameData["GreedModeWaveCount"] = 0
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_UPDATE, Tools.Greed_GameDataInit)

--̰��ģʽ��أ����лص�����
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

--ȫ�����
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

--ȡ��������
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

--ȡ��Ʒ����
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

--ȡ��������
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

--ȡһ��ʰȡ������
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