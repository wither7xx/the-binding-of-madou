local CM_Degeneracy = {}
local ModRef = tbom

local modPlayerType = tbom.modPlayerType
local modEntityType = tbom.modEntityType
local Puyo = include("scripts/monsters/e305_puyo/e305_puyo_api")

local MarthaCollectibleType = tbom.CM_MarthaCollectibleType
local Degeneracy = Martha.Collectibles.Degeneracy

--�����������ַ��������������ͣ�����������ɫ���ͣ���������������������������������ɫʵ����󣩣���װ��ID��������
Martha:AddCollectibleCostumeReplacement("ARLENADJA_DEGENERACY", 
										MarthaCollectibleType.COLLECTIBLE_DEGENERACY, 
										modPlayerType.PLAYER_ARLENADJA, nil, 
										Isaac.GetCostumeIdByPath("gfx/characters/compatible mods/martha/costume_degeneracy_arle.anm2"))

function CM_Degeneracy:PostProjectileInit(projectile)
	local spawner = projectile.SpawnerEntity
	if Puyo:IsSpawnedByFirePoint(projectile) and spawner.Parent then
		local data = Degeneracy:GetEntityData(spawner.Parent, false)
		if data then
			if data.DegeneracyCharge and data.DegeneracyCharge > 0 then
				projectile:AddProjectileFlags(ProjectileFlags.SLOWED)
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, CM_Degeneracy.PostProjectileInit)

return CM_Degeneracy