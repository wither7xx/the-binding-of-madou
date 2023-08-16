local CompatibleMods = {}

if EID then
	CompatibleMods.CM_EID = include("compatible mods/external item descriptions/main")
end

if ModConfigMenu then
	CompatibleMods.CM_ModConfigMenu = include("compatible mods/mod config menu/main")
end

if CuerLib then
	if Martha then
		CompatibleMods.CM_Martha = include("compatible mods/martha/main")
	end
	--以下是尚未确定是否会引入的兼容
	--if Reverie then
	--	CompatibleMods.CM_Reverie = include("compatible mods/reverie/main")
	--end
end

--if Isaac_BenightedSoul then
--	CompatibleMods.CM_BenightedSoul = include("compatible mods/benighted soul/main")
--end

--if Epiphany then
--	CompatibleMods.CM_Epiphany = include("compatible mods/epiphany/main")
--end

--if FiendFolio then
--	CompatibleMods.CM_FiendFolio = include("compatible mods/fiend folio/main")
--end

--if REVEL then
--	CompatibleMods.CM_Revelations = include("compatible mods/revelations/main")
--end

return CompatibleMods
