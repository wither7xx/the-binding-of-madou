local MagicCircle = {}
local ModRef = tbom

local Tools = tbom.Global.Tools
local tbomCallbacks = tbom.tbomCallbacks
local modEffectVariant = tbom.modEffectVariant
local MagicType = tbom.MagicType
local SpellType = tbom.SpellType
local SpellContent = tbom.SpellContent
local Magic = tbom.Magic

local MagicCircleColor = {
	[SpellType.SPELL_FIRE] = Color(1, 1, 1, 1, 0.3, 0, 0),
	[SpellType.SPELL_ICE_STORM] = Color(0.518, 0.671, 0.976, 1, 0.14, 0.16, 0.18),
	[SpellType.SPELL_THUNDER] = Color(1, 1, 0, 1, 0.3, 0.3, 0.3),
}

function MagicCircle:PostInit(effect)
	effect.SortingLayer = SortingLayer.SORTING_BACKGROUND
end
ModRef:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, MagicCircle.PostInit, modEffectVariant.MAGIC_CIRCLE)

function MagicCircle:PostRender(effect, offset)
	local parent = effect.Parent
	if parent and parent:Exists() then
		local player = parent:ToPlayer()
		local CurrentSpellID = Magic:GetCurrentSpellId(player)
		if Magic:GetMagicType(CurrentSpellID) == MagicType.AGGRESSIVE and Magic:IsUsingSpell(player, CurrentSpellID) then
			local color = (MagicCircleColor[CurrentSpellID] or Color(1, 1, 1, 1, 0, 0, 0))
			effect:SetColor(color, -1, 1, false)
			effect.SpriteScale = Vector(0.5, 0.5)
			effect.Position = player.Position
			effect.Velocity = player.Velocity
			effect:FollowParent(player)
		end
	else
		effect:Remove()
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, MagicCircle.PostRender, modEffectVariant.MAGIC_CIRCLE)

function MagicCircle:Remove(isContinued)
	if not isContinued then
		for i, entity in pairs(Isaac.GetRoomEntities()) do
			if entity.Type == EntityType.ENTITY_EFFECT and entity.Variant == modEffectVariant.MAGIC_CIRCLE then
				entity:Remove()
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, MagicCircle.Remove)

return MagicCircle