local AnotherCartride = include("scripts/items/trinkets/t001_another_cartride/t001_another_cartride_core").__index
local ETSpaceship = {}
local ModRef = tbom

local Tools = tbom.Global.Tools

local tbomCallbacks = tbom.tbomCallbacks
local modEffectVariant = tbom.modEffectVariant

function ETSpaceship:PostInit(effect)
	effect.DepthOffset = 999999
	--effect.Scale = 1.2
end
ModRef:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, ETSpaceship.PostInit, modEffectVariant.ET_SPACESHIP)

function ETSpaceship:OnRender(effect, offset)
	local parent = effect.Parent
	if parent and parent:Exists() and parent:ToPlayer() then
		local player = parent:ToPlayer()
		local timeout = AnotherCartride:GetTimeout(player)
		effect.Position = player.Position
		effect.Velocity = player.Velocity
		effect:FollowParent(player)
		if timeout >= 150 then
			effect.SpriteOffset = Vector(0, -(timeout - 150))
		elseif timeout > 0 then
			player.Visible = true
			player.ControlsEnabled = false
			if not player:HasEntityFlags(EntityFlag.FLAG_HELD) then
				effect.SpriteOffset = Vector(0, -(300 - timeout * 2))
				if Game():GetRoom():GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT then
					player:Render(Vector(0, -(300 - timeout * 2)))
				else
					player:Render(Vector(-32, (300 - timeout * 2)))
				end
			end
			player.Visible = false
		else
			effect:Remove()
		end
	else
		effect:Remove()
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, ETSpaceship.OnRender, modEffectVariant.ET_SPACESHIP)

function ETSpaceship:Remove(is_continued)
	if not is_continued then
		for i, entity in pairs(Isaac.GetRoomEntities()) do
			if entity.Type == EntityType.ENTITY_EFFECT and entity.Variant == modEffectVariant.ET_SPACESHIP then
				entity:Remove()
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, ETSpaceship.Remove)

return ETSpaceship