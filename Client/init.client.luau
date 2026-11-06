local ReplicatedStorage = game:GetService("ReplicatedStorage")

const Observers = require(ReplicatedStorage.Packages.Observers)
const Promise = require(ReplicatedStorage.Packages.Promise)

const Query = require("@game/ReplicatedStorage/Shared/Modules/Utility/Query")

local ServiceCount = 0

--[[
	Returns a promise that resolves when all modules have been loaded successfully.
]]--
local function LoadModules(modules: {ModuleScript})
	for _, module in modules do
		ServiceCount += 1
		require(module)
	end
end

local function Load()
	local modules = Query.Descendants(script, "Folder > ModuleScript")

	Promise.try(function()
		LoadModules(modules)
		print(`✅ Loaded {#modules} client modules!`)
	end)
end

Load()