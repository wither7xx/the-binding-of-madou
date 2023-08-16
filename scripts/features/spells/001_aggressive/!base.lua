local Aggressive = {}
local ModRef = tbom

local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths

local tbomCallbacks = tbom.tbomCallbacks
local SpellContent = tbom.SpellContent
local MagicType = tbom.MagicType
local Magic = tbom.Magic
local SpellType = tbom.SpellType
local modEffectVariant = tbom.modEffectVariant
local modCollectibleType = tbom.modCollectibleType

local ChargeState = {
	STANDBY = 0,	--待机
	CHARGING = 1,	--充能中
	CALMDOWN = 2,	--充能流失
	CHARGED = 3,	--满充能
	BURSTING = 4,	--爆发
	OVERHEAT = 5,	--过热
}

local function GetChargeData(player)
	return Magic:BaseSpell_GetAttribute(player, MagicType.AGGRESSIVE, "ChargeData")
end

function Aggressive:Charge_OnInit(spell_ID, player)
	local ChargeData = GetChargeData(player)
	if ChargeData then
		ChargeData = {
			State = ChargeState.STANDBY,
			ChargingSpellCache = {
				Type = SpellType.SPELL_INVALID,
				Reberu = 0,
			},
			CurrentCharge = 0,
			Timeout = 0,
			DisplayChargeBar = false,
			ChargeBarPos = Vector(0, 0),
			ChargeBarPosOffset = {},
		}
	end
end
--ModRef:AddCallback(tbomCallbacks.TBOMC_POST_SPELL_INIT_BASE, Aggressive.Charge_OnInit, MagicType.AGGRESSIVE)

function Aggressive:Charge_GetState(player)
	local ChargeData = GetChargeData(player)
	if ChargeData and ChargeData.State then
		return ChargeData.State
	end
	return ChargeState.STANDBY
end

function Aggressive:Charge_SetState(player, value)
	local ChargeData = GetChargeData(player)
	if ChargeData then
		ChargeData.State = value
	end
end

function Aggressive:Charge_GetChargingSpellType(player)
	local ChargeData = GetChargeData(player)
	if ChargeData and ChargeData.ChargingSpellCache then
		return ChargeData.ChargingSpellCache.Type
	end
	return SpellType.SPELL_INVALID
end

function Aggressive:Charge_SetChargingSpellType(player, value)
	local ChargeData = GetChargeData(player)
	if ChargeData and ChargeData.ChargingSpellCache then
		ChargeData.ChargingSpellCache.Type = value
	end
end

function Aggressive:Charge_GetChargingSpellReberu(player)
	local ChargeData = GetChargeData(player)
	if ChargeData and ChargeData.ChargingSpellCache then
		return ChargeData.ChargingSpellCache.Reberu
	end
	return 0
end

function Aggressive:Charge_SetChargingSpellReberu(player, value)
	local ChargeData = GetChargeData(player)
	if ChargeData and ChargeData.ChargingSpellCache then
		ChargeData.ChargingSpellCache.Reberu = value
	end
end

function Aggressive:Charge_GetCurrentCharge(player)
	local ChargeData = GetChargeData(player)
	if ChargeData and ChargeData.CurrentCharge then
		return ChargeData.CurrentCharge
	end
	return 0
end

function Aggressive:Charge_SetCurrentCharge(player, value)
	local ChargeData = GetChargeData(player)
	if ChargeData then
		ChargeData.CurrentCharge = value
	end
end

function Aggressive:Charge_ResetCurrentCharge(player)
	local ChargeData = GetChargeData(player)
	if ChargeData then
		ChargeData.CurrentCharge = 0
	end
end

function Aggressive:Charge_ModifyCurrentCharge(player, amount)
	local ChargeData = GetChargeData(player)
	if ChargeData then
		if ChargeData.CurrentCharge and ChargeData.ChargingSpellCache then
			--local max_charge = Magic:GetMaxCharge(ChargeData.ChargingSpellCache.Type, ChargeData.ChargingSpellCache.Reberu)
			local max_charge = Aggressive:Charge_GetCurrentMaxCharge(player)
			if max_charge then
				ChargeData.CurrentCharge = math.min(math.max(0, ChargeData.CurrentCharge + amount), max_charge)
			end
		end
	end
end

function Aggressive:Charge_GetCurrentMaxCharge(player)
	local ChargingSpellType = Aggressive:Charge_GetChargingSpellType(player)
	local ChargingSpellReberu = Aggressive:Charge_GetChargingSpellReberu(player)

	--print("ChargingSpellType: " .. ChargingSpellType)
	--print("CurrentMaxCharge: " .. tostring(Magic:GetMaxCharge(ChargingSpellType, ChargingSpellReberu)))

	return Magic:GetMaxCharge(ChargingSpellType, ChargingSpellReberu)
end

function Aggressive:Charge_GetTimeout(player)
	local ChargeData = GetChargeData(player)
	if ChargeData and ChargeData.Timeout then
		return ChargeData.Timeout
	end
	return 0
end

function Aggressive:Charge_SetTimeout(player, value)
	local ChargeData = GetChargeData(player)
	if ChargeData then
		ChargeData.Timeout = value
	end
end

function Aggressive:Charge_ModifyTimeout(player, amount)
	local ChargeData = GetChargeData(player)
	if ChargeData and ChargeData.Timeout then
		ChargeData.Timeout = math.max(0, ChargeData.Timeout + amount)
	end
end

function Aggressive:Charge_GetChargeBarPos(player)
	local ChargeData = GetChargeData(player)
	if ChargeData and ChargeData.ChargeBarPos and ChargeData.ChargeBarPosOffset then
		local pos = ChargeData.ChargeBarPos
		for i, offset in pairs(ChargeData.ChargeBarPosOffset) do
			pos = pos + offset
		end
		return pos + Tools:GetEntityRenderScreenPos(player)
	end
	return Vector(0, 0)
end

function Aggressive:Charge_AddChargeBarPosOffset(player, key, offset_X, offset_Y)
	local ChargeData = GetChargeData(player)
	if type(key) == "string" then
		ChargeData.ChargeBarPosOffset = ChargeData.ChargeBarPosOffset or {}
		ChargeData.ChargeBarPosOffset[key] = Vector(offset_X, offset_Y)
	end
end

function Aggressive:Charge_RemoveChargeBarPosOffset(player, key)
	local ChargeData = GetChargeData(player)
	if type(key) == "string" and ChargeData.ChargeBarPosOffset then
		ChargeData.ChargeBarPosOffset[key] = nil
	end
end

function Aggressive:Charge_UpdateChargingSpell(player)
	local ChargeData = GetChargeData(player)
	local CurrentSpellID = Magic:GetCurrentSpellId(player)
	local CurrentSpellReberu = Magic:GetSpellReberu(player, CurrentSpellID)
	--Aggressive:Charge_SetChargingSpellType(player, CurrentSpellID)
	--Aggressive:Charge_SetChargingSpellReberu(player, CurrentSpellReberu)
	if ChargeData and ChargeData.ChargingSpellCache then
		ChargeData.ChargingSpellCache.Type = CurrentSpellID
		ChargeData.ChargingSpellCache.Reberu = CurrentSpellReberu
	end
end

function Aggressive:Charge_IsCurrentSpellSameWithCache(player)
	local CurrentSpellID = Magic:GetCurrentSpellId(player)
	local CurrentSpellReberu = Magic:GetSpellReberu(player, CurrentSpellID)
	local ChargingSpellType = Aggressive:Charge_GetChargingSpellType(player)
	local ChargingSpellReberu = Aggressive:Charge_GetChargingSpellReberu(player)
	return (CurrentSpellID == ChargingSpellType) and (CurrentSpellReberu == ChargingSpellReberu)
end

function Aggressive:Charge_IsFullyCharged(player)
	local ChargingSpellType = Aggressive:Charge_GetChargingSpellType(player)
	local ChargingSpellReberu = Aggressive:Charge_GetChargingSpellReberu(player)
	local current_charge = Aggressive:Charge_GetCurrentCharge(player)
	--local max_charge = Magic:GetMaxCharge(ChargingSpellType, ChargingSpellReberu)
	local max_charge = Aggressive:Charge_GetCurrentMaxCharge(player)
	return max_charge ~= nil and current_charge >= max_charge
end

function Aggressive:Charge_SpawnChargeLaserSight(player)
	local magic_type = MagicType.AGGRESSIVE
	local ChargeLaserSight_prev = Magic:BaseSpell_GetAttribute(player, magic_type, "ChargeLaserSight")
	if not ChargeLaserSight_prev or not ChargeLaserSight_prev:Exists() then
		local ChargeLaserSight = Isaac.Spawn(EntityType.ENTITY_EFFECT, modEffectVariant.CHARGE_LASER_SIGHT, 0, player.Position, Vector(0, 0), player):ToEffect()
		ChargeLaserSight.Parent = player
		--ChargeLaserSight:GetSprite().Color = Color(0, 1, 0, 0.3, 0, 0, 0)
		--ChargeLaserSight.SpriteScale = Vector(0.5, 1)
		ChargeLaserSight.Rotation = player:GetSmoothBodyRotation() - 90
		ChargeLaserSight.SpriteRotation = ChargeLaserSight.Rotation
		ChargeLaserSight.Position = player.Position
		ChargeLaserSight.Velocity = player.Velocity
		ChargeLaserSight:FollowParent(ChargeLaserSight.Parent)
		Magic:BaseSpell_SetAttribute(player, magic_type, "ChargeLaserSight", ChargeLaserSight)
		return ChargeLaserSight
	end
	return ChargeLaserSight_prev
end

function Aggressive:Charge_RemoveChargeLaserSight(player)
	local magic_type = MagicType.AGGRESSIVE
	local ChargeLaserSight = Magic:BaseSpell_GetAttribute(player, magic_type, "ChargeLaserSight")
	if ChargeLaserSight and ChargeLaserSight:Exists() then
		ChargeLaserSight:Remove()
		Magic:BaseSpell_ClearAttribute(player, magic_type, "ChargeLaserSight")
	end
end
--[[
function Aggressive:Charge_GetBusrtingTimeout(player)
	if Aggressive:Charge_GetState(player) == ChargeState.BURSTING then
		return Aggressive:Charge_GetTimeout(player)
	end
	return 0
end
]]
--[[
local function IsHoldingAnimation(anim)
	return anim == "PickupWalkDown" or 
			anim == "PickupWalkUp" or 
			anim == "PickupWalkRight"  or 
			anim == "PickupWalkLeft" or
			anim == "WalkDown" or 
			anim == "WalkUp" or 
			anim == "WalkRight"  or 
			anim == "WalkLeft" or
			anim == "HideItem"
end
]]

local function TryUdatePlayerAnim(player)
	local sprite = player:GetSprite()
	if player:IsExtraAnimationFinished() then
		--player:GetSprite():RemoveOverlay()
		player:AnimateCollectible(modCollectibleType.COLLECTIBLE_BLUE_GRIMOIRE, "LiftItem")
	end
end


function Aggressive:OnEnable(spell_ID, rng, player, use_flags)
	local magic_type = MagicType.AGGRESSIVE
	local UsedInCurrentRoom = Magic:BaseSpell_GetAttribute(player, magic_type, "UsedInCurrentRoom")
	if not UsedInCurrentRoom then
		Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_POST_TRIGGER_ATK_EFFECT, spell_ID, spell_ID, rng, player, use_flags)
		Magic:BaseSpell_SetAttribute(player, magic_type, "UsedInCurrentRoom", true)
	end
	local MagicCircle = Magic:BaseSpell_GetAttribute(player, magic_type, "MagicCircle")
	if MagicCircle and MagicCircle:Exists() then
		local sprite = MagicCircle:GetSprite()
		if not sprite:IsPlaying("Idle") then
			sprite:Play("Display")
		end
	end

	player:SetColor(Color(1,1,1,1,0.5,0.5,0.5), 6, -1, true)
	Tools:TapAndHold_SetInitStateForcibly_Shooting(player, true)
end
ModRef:AddCallback(tbomCallbacks.TBOMC_ENABLE_SPELL_BASE, Aggressive.OnEnable, MagicType.AGGRESSIVE)

function Aggressive:OnDisable(spell_ID, rng, player, use_flags)
	local magic_type = MagicType.AGGRESSIVE
	player:SetColor(Color(1,1,1,1,0.5,0.5,0.5), 6, -1, true)
end
ModRef:AddCallback(tbomCallbacks.TBOMC_DISABLE_SPELL_BASE, Aggressive.OnDisable, MagicType.AGGRESSIVE)

function Aggressive:PostUpdate(spell_ID, player)
	local magic_type = MagicType.AGGRESSIVE
	if Magic:IsUsingSpell(player, spell_ID) then
		if player.FrameCount % 30 == 0 then
			Magic:CostDefaultMadouRyoku(player, spell_ID, false)
		end
	end
	Magic:BaseSpell_SetAttribute(player, magic_type, "TearFlagSeed", Maths:RandomInt(100, Magic:GetSpellRNG(player, spell_ID)))

	local MagicCircle = Magic:BaseSpell_GetAttribute(player, magic_type, "MagicCircle")
	local CurrentSpellID = Magic:GetCurrentSpellId(player)
	local IsUsingATKSpell = (Magic:IsUsingSpell(player, CurrentSpellID) and Magic:GetMagicType(CurrentSpellID) == MagicType.AGGRESSIVE)
	if IsUsingATKSpell then
		if MagicCircle and MagicCircle:Exists() then
			local sprite = MagicCircle:GetSprite()
			if ((sprite:IsFinished("Appear") or sprite:IsFinished("Display")) and (not sprite:IsPlaying("Idle"))) or sprite:IsFinished("Idle") then
				sprite:Play("Idle")
			end
		else
			local MagicCircle_new = Isaac.Spawn(EntityType.ENTITY_EFFECT, modEffectVariant.MAGIC_CIRCLE, 0, player.Position, Vector(0,0), player):ToEffect()
			MagicCircle_new.Parent = player
			MagicCircle_new.SpriteScale = Vector(0.5, 0.5)
			MagicCircle_new.Position = player.Position
			Magic:BaseSpell_SetAttribute(player, magic_type, "MagicCircle", MagicCircle_new)
		end
	elseif MagicCircle and MagicCircle:Exists() then
		local sprite = MagicCircle:GetSprite()
		sprite:Play("Hide")
	end
end
ModRef:AddCallback(tbomCallbacks.TBOMC_SPELL_UPDATE_BASE, Aggressive.PostUpdate, MagicType.AGGRESSIVE)

function Aggressive:PostNewRoom()
	local magic_type = MagicType.AGGRESSIVE
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = Game():GetPlayer(p)
		Magic:BaseSpell_SetAttribute(player, magic_type, "UsedInCurrentRoom", false)

		local state = Aggressive:Charge_GetState(player)
		if (state == ChargeState.CHARGING or state == ChargeState.CHARGED) and player:IsExtraAnimationFinished() then
			--player:AnimateCollectible(modCollectibleType.COLLECTIBLE_BLUE_GRIMOIRE, "LiftItem")
			TryUdatePlayerAnim(player)
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Aggressive.PostNewRoom)

function Aggressive:Charge_Holding(shoot_dir, player)	--//问题：按着蓄力键进新房间时角色举起物品的动画会出bug；退出重进会触发无法放下主动的恶性bug
	local CurrentSpellID = Magic:GetCurrentSpellId(player)
	local IsUsingCurrentSpell = Magic:IsUsingSpell(player, CurrentSpellID)
	local state = Aggressive:Charge_GetState(player)
	if state == ChargeState.STANDBY then
		if IsUsingCurrentSpell then
			--Aggressive:Charge_UpdateChargingSpell(player)
			--player:AnimateCollectible(modCollectibleType.COLLECTIBLE_BLUE_GRIMOIRE, "LiftItem")
			TryUdatePlayerAnim(player)
			--Aggressive:Charge_SpawnChargeLaserSight(player)
			Aggressive:Charge_SetState(player, ChargeState.CHARGING)
		end
	elseif state == ChargeState.CHARGING then
		if IsUsingCurrentSpell then
			if not Aggressive:Charge_IsCurrentSpellSameWithCache(player) then
				Aggressive:Charge_ResetCurrentCharge(player)
				Aggressive:Charge_UpdateChargingSpell(player)
				Tools:TapAndHold_TriggerReleaseForcibly_Shooting(player)
			end
		else
			player:PlayExtraAnimation("HideItem")
			--Aggressive:Charge_RemoveChargeLaserSight(player)
			Aggressive:Charge_SetState(player, ChargeState.CALMDOWN)
		end
	elseif state == ChargeState.CALMDOWN then
		if IsUsingCurrentSpell then
			--player:AnimateCollectible(modCollectibleType.COLLECTIBLE_BLUE_GRIMOIRE, "LiftItem")
			TryUdatePlayerAnim(player)
			--Aggressive:Charge_SpawnChargeLaserSight(player)
			Aggressive:Charge_UpdateChargingSpell(player)
			Aggressive:Charge_SetState(player, ChargeState.CHARGING)
		end
	elseif state == ChargeState.CHARGED then
		if IsUsingCurrentSpell then
			if not Aggressive:Charge_IsCurrentSpellSameWithCache(player) then
				Aggressive:Charge_ResetCurrentCharge(player)
				Aggressive:Charge_UpdateChargingSpell(player)
				--Aggressive:Charge_SetState(player, ChargeState.STANDBY)
			end
		else
			player:PlayExtraAnimation("HideItem")
			--Aggressive:Charge_RemoveChargeLaserSight(player)
			Aggressive:Charge_SetState(player, ChargeState.CALMDOWN)
		end
	end
end
ModRef:AddCallback(tbomCallbacks.TBOMC_TAP_AND_HOLD_SHOOTING, Aggressive.Charge_Holding, 1)

function Aggressive:Charge_Releasing(shoot_dir, player)
	local CurrentSpellID = Magic:GetCurrentSpellId(player)
	local IsUsingCurrentSpell = Magic:IsUsingSpell(player, CurrentSpellID)
	local state = Aggressive:Charge_GetState(player)
	if state == ChargeState.CHARGING then
		player:PlayExtraAnimation("HideItem")
		--Aggressive:Charge_RemoveChargeLaserSight(player)
		Aggressive:Charge_SetState(player, ChargeState.CALMDOWN)
	elseif state == ChargeState.CHARGED then
		player:PlayExtraAnimation("HideItem")
		--Aggressive:Charge_RemoveChargeLaserSight(player)
		Aggressive:Charge_SetState(player, ChargeState.BURSTING)
		local ChargingSpellType = Aggressive:Charge_GetChargingSpellType(player)
		local ChargingSpellReberu = Aggressive:Charge_GetChargingSpellReberu(player)
		Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_PRE_BURST_ATK_CHARGE, ChargingSpellType, ChargingSpellType, ChargingSpellReberu, Magic:GetSpellRNG(player, ChargingSpellType), player)
	end
	
end
ModRef:AddCallback(tbomCallbacks.TBOMC_TAP_AND_HOLD_SHOOTING, Aggressive.Charge_Releasing, 2)

function Aggressive:Charge_OnUpdate(spell_ID, player)
	local state = Aggressive:Charge_GetState(player)
	if state == ChargeState.STANDBY then
		Aggressive:Charge_ResetCurrentCharge(player)
		Aggressive:Charge_UpdateChargingSpell(player)
	else
		if Tools:GetUserNum() > 1 then
			Magic:AddSpellIconAreaOffset(player, "SpellChargeBar", 0, -35)
			Magic:AddSpellTextAreaOffset(player, "SpellChargeBar", 0, -35)
		else
			Magic:RemoveSpellIconAreaOffset(player, "SpellChargeBar")
			Magic:RemoveSpellTextAreaOffset(player, "SpellChargeBar")
		end
		local ChargingSpellType = Aggressive:Charge_GetChargingSpellType(player)
		local ChargingSpellReberu = Aggressive:Charge_GetChargingSpellReberu(player)
		if state == ChargeState.CHARGING then
			--player:AnimateCollectible(modCollectibleType.COLLECTIBLE_BLUE_GRIMOIRE, "LiftItem")
			TryUdatePlayerAnim(player)
			if Aggressive:Charge_IsFullyCharged(player) then
				Aggressive:Charge_SetState(player, ChargeState.CHARGED)
			elseif ChargingSpellType == spell_ID then
				Aggressive:Charge_ModifyCurrentCharge(player, 2)
			end
		elseif state == ChargeState.CALMDOWN then
			if Aggressive:Charge_GetCurrentCharge(player) > 0 then
				if ChargingSpellType == spell_ID and player.FrameCount % 2 == 0 then		--规定：充能流失速度比充能速度慢两倍
					Aggressive:Charge_ModifyCurrentCharge(player, -1)
				end
			else
				Aggressive:Charge_ResetCurrentCharge(player)
				Aggressive:Charge_SetState(player, ChargeState.STANDBY)
			end
		elseif state == ChargeState.CHARGED then
			--if Magic:IsUsingSpell(player, spell_ID) then
			--	Aggressive:Charge_SetTimeout(player, Magic:GetBurstingTime(spell_ID, Magic:GetSpellReberu(player, spell_ID)))
			--end
			TryUdatePlayerAnim(player)
			Aggressive:Charge_SetTimeout(player, Magic:GetBurstingTime(ChargingSpellType, ChargingSpellReberu))
		elseif state == ChargeState.BURSTING then
			Aggressive:Charge_ResetCurrentCharge(player)
			local Timeout = Aggressive:Charge_GetTimeout(player)
			if Timeout > 0 then
				if ChargingSpellType == spell_ID then
					Isaac.RunCallbackWithParam(tbomCallbacks.TBOMC_POST_BURST_ATK_CHARGE, ChargingSpellType, ChargingSpellType, ChargingSpellReberu, Timeout, Magic:GetSpellRNG(player, spell_ID), player)
					Aggressive:Charge_ModifyTimeout(player, -2)
				end
			else
				Aggressive:Charge_SetTimeout(player, Magic:GetOverHeatCD(ChargingSpellType, ChargingSpellReberu))
				Aggressive:Charge_SetState(player, ChargeState.OVERHEAT)
			end
		elseif state == ChargeState.OVERHEAT then
			Aggressive:Charge_ResetCurrentCharge(player)
			if Aggressive:Charge_GetTimeout(player) > 0 then
				if ChargingSpellType == spell_ID then
					Aggressive:Charge_ModifyTimeout(player, -2)
				end
			else
				Aggressive:Charge_SetState(player, ChargeState.STANDBY)
			end
		end
	end
end
ModRef:AddCallback(tbomCallbacks.TBOMC_SPELL_UPDATE_BASE, Aggressive.Charge_OnUpdate, MagicType.AGGRESSIVE)

function Aggressive:OnTakeDamage(took_dmg, dmg_amount, dmg_flags, dmg_source, dmg_cd_frames)
	local player = took_dmg:ToPlayer()
	if player then
		Tools:TapAndHold_SetInitStateForcibly_Shooting(player, true)
	end
end
ModRef:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Aggressive.OnTakeDamage)

function Aggressive:Charge_OnRender(player, offset)
	local game = Game()
	--local ScreenShakeOffset = game.ScreenShakeOffset
	local NumPlayers = game:GetNumPlayers()
	if Tools:CanShowHUD() and game:GetRoom():GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT then
		local ChargeData = GetChargeData(player)
		local state = Aggressive:Charge_GetState(player)
		if state ~= ChargeState.STANDBY then
			ChargeData.DisplayChargeBar = true
			local ChargeBar = Sprite()
			ChargeBar:Load("gfx/tbom/ui/hund_spell_charge_bar.anm2")
			if state == ChargeState.CHARGING or state == ChargeState.CALMDOWN then
				if not ChargeBar:IsPlaying ("Charging") then
					ChargeBar:Play("Charging")
				end
				local max_charge = Aggressive:Charge_GetCurrentMaxCharge(player)
				if max_charge and max_charge ~= 0 then
					local frame = math.ceil((Aggressive:Charge_GetCurrentCharge(player) / max_charge) * 34)
					ChargeBar:SetFrame(frame)
				else
					ChargeData.DisplayChargeBar = false
				end
			elseif state == ChargeState.CHARGED then
				ChargeBar:Play("Charged")
				ChargeBar:SetFrame(player.FrameCount % 4)
			elseif state == ChargeState.BURSTING then
				ChargeBar:Play("Bursting")
				ChargeBar:SetFrame(player.FrameCount % 24)
			elseif state == ChargeState.OVERHEAT then
				ChargeBar:Play("OverHeat")
				ChargeBar:SetFrame(player.FrameCount % 36)
			end
			if ChargeData.DisplayChargeBar then
				local pos = Aggressive:Charge_GetChargeBarPos(player) + Vector(0, -35)
				local ChargeBarColor = Color(1, 1, 1, 0.8, 0, 0, 0)
				ChargeBar.Color = ChargeBarColor
				ChargeBar:Render(pos)
			end
		end
		--调试专用
		--[[
		local font = tbom.Fonts[Options.Language] or tbom.Fonts["en"]
		local texts = {
			[1] = "State: ".. tostring(Aggressive:Charge_GetState(player)),
			[2] = "ChargingSpell: Type: ".. tostring(Aggressive:Charge_GetChargingSpellType(player))  .. " Reberu: " .. tostring(Aggressive:Charge_GetChargingSpellReberu(player)),
			[3] = "Charge: " .. tostring(Aggressive:Charge_GetCurrentCharge(player)),
			[4] = "MaxCharge: " .. tostring(Aggressive:Charge_GetCurrentMaxCharge(player)),
			[5] = "Timeout: " .. tostring(Aggressive:Charge_GetTimeout(player)),
		}
		local pos = Tools:GetEntityRenderScreenPos(player)
		for i = 1, #texts do
			font:DrawStringUTF8(texts[i], pos.X - 200, pos.Y + 20 - 5 * #texts + i * 15, KColor(1, 1, 1, 0.8), 400, true)
		end
		]]
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, Aggressive.Charge_OnRender)

return Aggressive