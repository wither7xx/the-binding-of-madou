local DebugConsole = {}
local ModRef = tbom

local Magic = tbom.Magic
local LevelExp = tbom.LevelExp

local tbomCommand = {
	TBOM_DEBUG = "tbom_debug",
}

local tbomDebugParam = {
	DISPLAY_PARAM_LIST = "",
	INFINITE_MP = "1",
	NO_SPELL_CD = "2",
	HIGH_EXP_MULTI = "3",
	PUYOPUYO = "2424",
}

local tbomCmdFunction = {}

tbomCmdFunction[tbomCommand.TBOM_DEBUG] = {}

do
	local tbomDebug = tbomCmdFunction[tbomCommand.TBOM_DEBUG]

	local Debug_CanDisableAll = {}
	Debug_CanDisableAll[tbomDebugParam.INFINITE_MP] = function ()
		local player0 = Isaac.GetPlayer(0)
		return Magic:HasInfiniteMP(player0)
	end
	Debug_CanDisableAll[tbomDebugParam.NO_SPELL_CD] = function ()
		local player0 = Isaac.GetPlayer(0)
		return Magic:NoSpellCD(player0)
	end
	Debug_CanDisableAll[tbomDebugParam.HIGH_EXP_MULTI] = function ()
		local player0 = Isaac.GetPlayer(0)
		return LevelExp:HasHighExpMulti(player0)
	end

	tbomDebug[tbomDebugParam.DISPLAY_PARAM_LIST] = function (cmd, param)
		print("[TBOM] 1:Infinite MP 2:No Spell CD 3:High Exp Multipler")
	end
	tbomDebug[tbomDebugParam.INFINITE_MP] = function (cmd, param)
		local NumPlayers = Game():GetNumPlayers()
		local DisableAll = Debug_CanDisableAll[param]
		if DisableAll ~= nil then
			if DisableAll() then
				for p = 0, NumPlayers - 1 do
					local player = Isaac.GetPlayer(p)
					Magic:DisableInfiniteMP(player)
				end
				print("[TBOM] Disabled debug flag.")
			else
				for p = 0, NumPlayers - 1 do
					local player = Isaac.GetPlayer(p)
					Magic:EnableInfiniteMP(player)
				end
				print("[TBOM] Enabled debug flag.")
			end
		end
	end
	tbomDebug[tbomDebugParam.NO_SPELL_CD] = function (cmd, param)
		local NumPlayers = Game():GetNumPlayers()
		local DisableAll = Debug_CanDisableAll[param]
		if DisableAll ~= nil then
			if DisableAll() then
				for p = 0, NumPlayers - 1 do
					local player = Isaac.GetPlayer(p)
					Magic:DisableNoSpellCD(player)
				end
				print("[TBOM] Disabled debug flag.")
			else
				for p = 0, NumPlayers - 1 do
					local player = Isaac.GetPlayer(p)
					Magic:EnableNoSpellCD(player)
				end
				print("[TBOM] Enabled debug flag.")
			end
		end
	end
	tbomDebug[tbomDebugParam.HIGH_EXP_MULTI] = function (cmd, param)
		local NumPlayers = Game():GetNumPlayers()
		local DisableAll = Debug_CanDisableAll[param]
		if DisableAll ~= nil then
			if DisableAll() then
				for p = 0, NumPlayers - 1 do
					local player = Isaac.GetPlayer(p)
					LevelExp:DisableHighExpMulti(player)
				end
				print("[TBOM] Disabled debug flag.")
			else
				for p = 0, NumPlayers - 1 do
					local player = Isaac.GetPlayer(p)
					LevelExp:EnableHighExpMulti(player)
				end
				print("[TBOM] Enabled debug flag.")
			end
		end
	end
	tbomDebug[tbomDebugParam.PUYOPUYO] = function (cmd, param)
		print("[TBOM] Puyo is falling from the sky!")
	end

	tbomCmdFunction["tdb"] = tbomCmdFunction[tbomCommand.TBOM_DEBUG]
end

DebugConsole.CmdFunction = tbomCmdFunction

function DebugConsole:OnExecuteCmd(cmd, param)
	if tbomCmdFunction[cmd] ~= nil and tbomCmdFunction[cmd][param] ~= nil then
		tbomCmdFunction[cmd][param](cmd, param)
	end
end
ModRef:AddCallback(ModCallbacks.MC_EXECUTE_CMD, DebugConsole.OnExecuteCmd)

return DebugConsole