local CM_ModConfigMenu = {}
--CM_ModConfigMenu.ModRef = RegisterMod("TBOM Compatible Mod ModConfigMenu", 1)
local ModRef = tbom

local categoryName = "Binding of Madou"
local prefix = {"P1", "P2", "P3", "P4",}
local prefix_alt = {"Player 1", "Player 2", "Player 3", "Player 4",}
local ResetSettings = {[1] = false, [2] = false, [3] = false, [4] = false, } 


for i = 1, 4 do
	local subcategoryName = prefix[i].." Config"
	ModConfigMenu.SimpleAddSetting(ModConfigMenu.OptionType.KEYBIND_KEYBOARD, categoryName, subcategoryName, prefix[i].." change spell 1 (Keyboard)",
									nil, nil, nil, Keyboard.KEY_LEFT_ALT, 
									"Change Spell 1", nil, true, "Key to move "..prefix_alt[i].."'s spell cursor to left (Keyboard)")
	ModConfigMenu.SimpleAddSetting(ModConfigMenu.OptionType.KEYBIND_KEYBOARD, categoryName, subcategoryName, prefix[i].." change spell 2 (Keyboard)", 
									nil, nil, nil, Keyboard.KEY_RIGHT_CONTROL, 
									"Change Spell 2", nil, true, "Key to move "..prefix_alt[i].."'s spell cursor to right (Keyboard)")
	ModConfigMenu.SimpleAddSetting(ModConfigMenu.OptionType.KEYBIND_CONTROLLER, categoryName, subcategoryName, prefix[i].." change spell 1 (Controller)", 
									nil, nil, nil, 0, 
									"Change Spell 1", nil, true, "Key to move "..prefix_alt[i].."'s spell cursor to left (Controller)")
	ModConfigMenu.SimpleAddSetting(ModConfigMenu.OptionType.KEYBIND_CONTROLLER, categoryName, subcategoryName, prefix[i].." change spell 2 (Controller)",
									nil, nil, nil, 1, 
									"Change Spell 2", nil, true, "Key to move "..prefix_alt[i].."'s spell cursor to right (Controller)")
--[[
	ModConfigMenu.AddSetting(categoryName, subcategoryName,
		{
			Type = ModConfigMenu.OptionType.KEYBIND_KEYBOARD,
			CurrentSetting = function() return tbom.KeyConfig[prefix[i].." change spell 1 (Keyboard)"] end,
			Display = function() 
				local keyboard = tbom.KeyConfig[prefix[i].." change spell 1 (Keyboard)"]
				local current_key = InputHelper.KeyboardToString[keyboard] or "None"
				return "Change Spell 1: "..current_key
			end,
			OnChange = function(new_key)
				print(prefix[i].." change spell 1 (Keyboard)")
				print(new_key)
				tbom.KeyConfig[prefix[i].." change spell 1 (Keyboard)"] = new_key or -1
			end,
			Info = {"Key to move "..prefix_alt[i].."'s spell cursor to left (Keyboard)"}
		}
	)
	ModConfigMenu.AddSetting(categoryName, subcategoryName,
		{
			Type = ModConfigMenu.OptionType.KEYBIND_KEYBOARD,
			CurrentSetting = function() return tbom.KeyConfig[prefix[i].." change spell 2 (Keyboard)"] end,
			Display = function() 
				local keyboard = tbom.KeyConfig[prefix[i].." change spell 2 (Keyboard)"]
				local current_key = InputHelper.KeyboardToString[keyboard] or "None"
				return "Change Spell 2: "..current_key
			end,
			OnChange = function(new_key)
				tbom.KeyConfig[prefix[i].." change spell 2 (Keyboard)"] = new_key or -1
			end,
			Info = {"Key to move "..prefix_alt[i].."'s spell cursor to right (Keyboard)"}
		}
	)
	ModConfigMenu.AddSetting(categoryName, subcategoryName,
		{
			Type = ModConfigMenu.OptionType.KEYBIND_CONTROLLER,
			CurrentSetting = function() return tbom.KeyConfig[prefix[i].." change spell 1 (Controller)"] end,
			Display = function() 
				local controller = tbom.KeyConfig[prefix[i].." change spell 1 (Controller)"]
				local current_key = InputHelper.ControllerToString[controller] or "None"
				return "Change Spell 1: "..current_key
			end,
			OnChange = function(new_key)
				tbom.KeyConfig[prefix[i].." change spell 1 (Controller)"] = new_key or -1
			end,
			Info = {"Key to move "..prefix_alt[i].."'s spell cursor to left (Controller)"}
		}
	)
	ModConfigMenu.AddSetting(categoryName, subcategoryName,
		{
			Type = ModConfigMenu.OptionType.KEYBIND_CONTROLLER,
			CurrentSetting = function() return tbom.KeyConfig[prefix[i].." change spell 2 (Controller)"] end,
			Display = function() 
				local controller = tbom.KeyConfig[prefix[i].." change spell 2 (Controller)"]
				local current_key = InputHelper.ControllerToString[controller] or "None"
				return "Change Spell 2: "..current_key
			end,
			OnChange = function(new_key)
				tbom.KeyConfig[prefix[i].." change spell 2 (Controller)"] = new_key or -1
			end,
			Info = {"Key to move "..prefix_alt[i].."'s spell cursor to right (Controller)"}
		}
	)
	]]
	ModConfigMenu.AddSpace(categoryName, subcategoryName)
	ModConfigMenu.AddSetting(categoryName, subcategoryName,
		{
			Type = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function() return true end,
			Display = function() return "RESET TO DEFAULT" end,
			OnChange = function()
				--local category = ModConfigMenu.Config[categoryName]
				--ModConfigMenu.Config[categoryName][prefix[i].." change spell 1 (Keyboard)"] = Keyboard.KEY_LEFT_ALT
				--ModConfigMenu.Config[categoryName][prefix[i].." change spell 2 (Keyboard)"] = Keyboard.KEY_RIGHT_CONTROL
				--ModConfigMenu.Config[categoryName][prefix[i].." change spell 1 (Controller)"] = 0
				--ModConfigMenu.Config[categoryName][prefix[i].." change spell 2 (Controller)"] = 1
				--tbom.KeyConfig[prefix[i].." change spell 1 (Keyboard)"] = Keyboard.KEY_LEFT_ALT
				--tbom.KeyConfig[prefix[i].." change spell 2 (Keyboard)"] = Keyboard.KEY_RIGHT_CONTROL
				--tbom.KeyConfig[prefix[i].." change spell 1 (Controller)"] = 0
				--tbom.KeyConfig[prefix[i].." change spell 2 (Controller)"] = 1
				ResetSettings[i] = true
			end,
			Info = {"Reset "..prefix_alt[i].."'s key config to default values"}
		}
	)
end

function CM_ModConfigMenu:PostUpdate()
	local category = ModConfigMenu.Config[categoryName]
	if category then
		for i = 1, 4 do
			if ResetSettings[i] == true then
				category[prefix[i].." change spell 1 (Keyboard)"] = Keyboard.KEY_LEFT_ALT
				category[prefix[i].." change spell 2 (Keyboard)"] = Keyboard.KEY_RIGHT_CONTROL
				category[prefix[i].." change spell 1 (Controller)"] = 0
				category[prefix[i].." change spell 2 (Controller)"] = 1
				ResetSettings[i] = false
			else
				tbom.KeyConfig[prefix[i].." change spell 1 (Keyboard)"] = category[prefix[i].." change spell 1 (Keyboard)"]
				tbom.KeyConfig[prefix[i].." change spell 2 (Keyboard)"] = category[prefix[i].." change spell 2 (Keyboard)"]
				tbom.KeyConfig[prefix[i].." change spell 1 (Controller)"] = category[prefix[i].." change spell 1 (Controller)"]
				tbom.KeyConfig[prefix[i].." change spell 2 (Controller)"] = category[prefix[i].." change spell 2 (Controller)"]
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_UPDATE, CM_ModConfigMenu.PostUpdate)

local json = require("json")

function CM_ModConfigMenu:LoadData(isContinued)
	local category = ModConfigMenu.Config[categoryName]
	if tbom:HasData() then
		local LoadingData = json.decode(tbom:LoadData())
		if LoadingData and category then
			for i = 1, 4 do
				if LoadingData.KeyConfig then
					category[prefix[i].." change spell 1 (Keyboard)"] = LoadingData.KeyConfig[prefix[i].." change spell 1 (Keyboard)"] or Keyboard.KEY_LEFT_ALT
					category[prefix[i].." change spell 2 (Keyboard)"] = LoadingData.KeyConfig[prefix[i].." change spell 2 (Keyboard)"] or Keyboard.KEY_RIGHT_CONTROL
					category[prefix[i].." change spell 1 (Controller)"] = LoadingData.KeyConfig[prefix[i].." change spell 1 (Controller)"] or 0
					category[prefix[i].." change spell 2 (Controller)"] = LoadingData.KeyConfig[prefix[i].." change spell 2 (Controller)"] or 1
				else
					category[prefix[i].." change spell 1 (Keyboard)"] = Keyboard.KEY_LEFT_ALT
					category[prefix[i].." change spell 2 (Keyboard)"] = Keyboard.KEY_RIGHT_CONTROL
					category[prefix[i].." change spell 1 (Controller)"] = 0
					category[prefix[i].." change spell 2 (Controller)"] = 1
				end
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, CM_ModConfigMenu.LoadData)

return CM_ModConfigMenu