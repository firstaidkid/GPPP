local utilsDir = Scripting:getImportantScriptsRoot() .. "utils/"

-- executes important scripts that live in the data/base/utils/ dir
-- Note: this function is local to this script!
local function include(utilsFile)
	local scriptFile = utilsDir .. utilsFile
	dofile(scriptFile)
end

include("builtins.lua")
include("type.lua")
include("debugging.lua")
include("null.lua")
include("tables.lua")
include("logging.lua")
include("math.lua")
include("string.lua")
include("scripting.lua")
include("events.lua")
include("state-machines.lua")
include("physics.lua")
