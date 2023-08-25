local Bayoen = {}
local ModRef = tbom

local Maths = tbom.Global.Maths
local Tools = tbom.Global.Tools

local tbomCallbacks = tbom.tbomCallbacks
local modCollectibleType = tbom.modCollectibleType
local MagicType = tbom.MagicType
local SpellType = tbom.SpellType
local SpellContent = tbom.SpellContent
local Magic = tbom.Magic
local modSoundEffect = tbom.modSoundEffect

function Bayoen:OnUse(Spell_ID, rng, player, use_flag)
	local SFX = SFXManager()
	local Diacute_OrbsNum = (Magic:Spell_GetAttribute(player, SpellType.SPELL_DIACUTE, "OrbsNum") or 0)
	if Diacute_OrbsNum > 0 then		--���ʹ���˶���ǿ���������ܶ黯�Ĺ���黯���Ȼ�֮
		for _, entity in pairs(Isaac.GetRoomEntities()) do
			if entity:IsActiveEnemy() and entity:IsVulnerableEnemy() then
				local NPC = entity:ToNPC()
				if not (NPC:IsBoss() or (NPC.SpawnerEntity and NPC.SpawnerEntity:IsBoss())) then	--����BOSS�������ɵĹ��ֻ�Ȼ�10�룬�Ҳ��ᱻ�黯
					local newNPC = Tools:GetTaintedMonsterVariant(NPC)
					if newNPC ~= nil and Tools:CanTriggerEvent(NPC, Diacute_OrbsNum * 25) then
						Isaac.Spawn(NPC.Type, newNPC, 0, NPC.Position, NPC.Velocity, nil)
						NPC:Remove()
					end
				end
			end
		end
	end
	for _, entity in pairs(Isaac.GetRoomEntities()) do
		if entity:IsActiveEnemy() and entity:IsVulnerableEnemy() then
			local NPC = entity:ToNPC()
			if not NPC:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
				if (NPC:IsBoss()) or (NPC.SpawnerEntity and NPC.SpawnerEntity:IsBoss()) then
					NPC:AddCharmed(EntityRef(entity), 10 * 30)
				else
					NPC:AddCharmed(EntityRef(entity), -1)
				end
			end
		end
	end
	SFX:Play(SoundEffect.SOUND_HAPPY_RAINBOW)
	if Tools:CanAddWisp(player, use_flag) then
		player:AddWisp(CollectibleType.COLLECTIBLE_BEST_FRIEND, player.Position)
	end
	return true
end
ModRef:AddCallback(tbomCallbacks.TBOMC_USE_SPELL, Bayoen.OnUse, SpellType.SPELL_BAYOEN)

return Bayoen