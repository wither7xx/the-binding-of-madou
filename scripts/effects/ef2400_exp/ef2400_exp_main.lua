local Exp = {}
local ModRef = tbom

local Tools = tbom.Global.Tools
local Maths = tbom.Global.Maths

local tbomCallbacks = tbom.tbomCallbacks
local modEffectVariant = tbom.modEffectVariant
local MagicType = tbom.MagicType
local SpellType = tbom.SpellType
local SpellContent = tbom.SpellContent
local LevelExp = tbom.LevelExp
local Magic = tbom.Magic
local modSoundEffect = tbom.modSoundEffect

local ExpState = {
	STATE_IDLE = 0,
	STATE_COLLECTED = 1,
}
Exp.ExpState = ExpState

function Exp:PostInit(effect)
	effect:SetColor(Color(0, 1, 0, 1, 0, 0, 0), -1, 0)
end
ModRef:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, Exp.PostInit, modEffectVariant.EXP)
	
function Exp:PostUpdate(effect)
	if effect.Variant == modEffectVariant.EXP then
		if not effect.Child then
			local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, effect.Position, Vector(0, 0), effect):ToEffect()
			trail.Parent = effect
			trail.MinRadius = 0.15
			trail.MaxRadius = 0.15
			trail.SpriteScale = Vector(2, 2)
			trail:SetColor(Color(0.25, 0.5, 0.25, 0.5, 0, 0, 0), -1, 0)
			effect.Child = trail
		else 
			effect.Child.Position = effect.Position + Vector(0, -24)
		end

		local sprite = effect:GetSprite()
		if effect.State == ExpState.STATE_IDLE then
			if effect.Target and effect.Target:Exists() and (not effect.Target:IsDead()) then
				sprite:Play("Move")

				local velocity = effect.Velocity
				local dir = effect.Target.Position - effect.Position
				effect.Velocity = effect.Velocity * 0.8 + dir:Resized(20) * 0.2

				if effect.Target.Position:Distance(effect.Position) <= effect.Target.Size and effect.FrameCount > 10 then
					SFXManager():Play(modSoundEffect.SOUND_EXP_GET)
					effect.Position = effect.Target.Position
					effect.State = ExpState.STATE_COLLECTED
					effect.Velocity = Vector(0, 0)
					LevelExp:ModifyExp(effect.Target:ToPlayer(), 1)
				end
			else
				sprite:Play("Idle")
				effect:MultiplyFriction(0.9)
				if effect.Velocity:Length() < 0.5 then
					effect.State = ExpState.STATE_COLLECTED
				end
			end
		else
			sprite:Play("Collect")
			if sprite:IsFinished("Collect") then
				effect:Remove()
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Exp.PostUpdate)

function Exp:PostRemove(entity)
	if entity.Type == EntityType.ENTITY_EFFECT and entity.Variant == modEffectVariant.EXP then
		local effect = entity:ToEffect()
		local data = Tools:GetEffectData(effect)
		if effect.State == ExpState.STATE_IDLE and data.Target then
			LevelExp:ModifyExp(data.Target, 1)
		end
		if effect.Child and effect.Child:Exists() then
			effect.Child:Remove()
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, Exp.PostRemove)

return Exp