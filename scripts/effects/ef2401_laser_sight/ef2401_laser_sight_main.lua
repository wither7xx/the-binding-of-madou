local LaserSight = {}
local ModRef = tbom

local Tools = tbom.Global.Tools

local tbomCallbacks = tbom.tbomCallbacks
local modEffectVariant = tbom.modEffectVariant
local MagicType = tbom.MagicType
local SpellType = tbom.SpellType
local SpellContent = tbom.SpellContent
local Magic = tbom.Magic
local Lockon = tbom.BaseSpell[MagicType.LOCKON]

function LaserSight:PostRender(effect, offset)
	local parent = effect.Parent
	if parent and parent:Exists() then
		local player = parent:ToPlayer()
		local CurrentSpellID = Magic:GetCurrentSpellId(player)
		if Magic:GetMagicType(CurrentSpellID) == MagicType.LOCKON then
			local LockonCD = Magic:BaseSpell_GetAttribute(player, MagicType.LOCKON, "LockonCD")
			if not Lockon:CanLockonTarget(player, CurrentSpellID) then
				effect:GetSprite().Color = Color(1 - (LockonCD / 5), (LockonCD / 5), 0, 0.3, 0, 0, 0)
			else
				effect:GetSprite().Color = Color(0, 1, 0, 0.3, 0, 0, 0)
			end
			effect.SpriteScale = Vector(0.5, 1)
			effect.Rotation = player:GetSmoothBodyRotation() - 90
			effect.SpriteRotation = effect.Rotation
			effect.Position = player.Position
			effect.Velocity = player.Velocity
			effect:FollowParent(player)
		end
	else
		effect:Remove()
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, LaserSight.PostRender, modEffectVariant.LASER_SIGHT)

function LaserSight:Remove(is_continued)
	if not is_continued then
		for i, entity in pairs(Isaac.GetRoomEntities()) do
			if entity.Type == EntityType.ENTITY_EFFECT and entity.Variant == modEffectVariant.LASER_SIGHT then
				entity:Remove()
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, LaserSight.Remove)

return LaserSight