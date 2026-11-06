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
		print(`✅ Loaded {#modules} server modules!`)
	end)
	:catch(function(err)
		Observers.observePlayer(function(player)
			player:Kick("This server has experienced an error on startup. Please join another server!")
		end)
		error(err)
	end)
end

Load()