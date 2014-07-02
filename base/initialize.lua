
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

	-- main scripts
	--"melee_prototype/helper.lua",
	--"melee_prototype/character.lua",
	--"melee_prototype/main.lua",

	"character_initialize.lua"
}

logMessage("<- Finished registering scripts.")
