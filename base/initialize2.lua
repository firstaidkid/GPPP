
logMessage("-> registering scripts...")

local function include(oneOrMoreScriptNames)
	if type(oneOrMoreScriptNames) == "string" then
		Scripting:registerScript(oneOrMoreScriptNames)
	else
		for _,scriptName in ipairs(oneOrMoreScriptNames) do
			include(scriptName)
		end
	end
end

include{
	-- utils
	"utils/timedStatusDisplay.lua",
	
--	"samples/audio_component.lua",

	-- melee prototype
--	"melee_prototype/helper.lua",
--	"melee_prototype/character.lua",
--	"melee_prototype/main.lua",

	-- zombie prototype
	"zombie_prototype/utils.lua",
	"zombie_prototype/guns.lua",
	"zombie_prototype/player.lua",
	"zombie_prototype/zombie.lua",
	"zombie_prototype/main.lua",
}

logMessage("<- Finished registering scripts.")
