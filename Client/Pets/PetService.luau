const TextService = game:GetService("TextService")

const Networking = require("@game/ReplicatedStorage/Client/Core/Networking")
const Observers = require("@game/ReplicatedStorage/Packages/Observers")
const PetConfig = require("@game/ReplicatedStorage/Shared/Config/Pets/PetConfig")
const PetNames = require("@game/ReplicatedStorage/Shared/Config/Pets/PetNames")
const Promise = require("@game/ReplicatedStorage/Packages/Promise")
const Signal = require("@game/ReplicatedStorage/Packages/Signal")

const NEEDS = {
	Food = "Food",
	Happiness = "Happiness",
	Cleanliness = "Cleanliness",
} :: {[string]: string}

const EVENTS = {
	InfoUpdated = Signal.new(),
	NameChanged = Signal.new(),
	NeedLevelChanged = Signal.new(),
}

local PetInfo

--[[
	Updates pet info directly from the server.
	Returns a promise that resolves when the pet info is updated.
--]]
local function UpdateInfoFromServer()
	return Networking.InvokeServer("Pet.GetInfo"):andThen(function(petInfo)
		PetInfo = petInfo
		EVENTS.InfoUpdated:Fire(PetInfo)
	end)
end

--[[
	Returns read-only information about a player's pet.
	Will yield until info has been loaded from the server.
--]]
local function GetInfo(): PetConfig.PetSchema
	if PetInfo == nil then
		EVENTS.InfoUpdated:Wait() -- Guarantees pet data is not nil
	end
	return PetInfo
end

--[[
	Attempts to rename a player's pet with input validation.
	Returns a promise resolving to a success boolean and, if applicable, the new name.
--]]
local function Rename(newName: string): any
	return Networking.InvokeServer("Pet.Rename", newName)
end

--[[
	Returns a need level of a player's pet.
--]]
local function GetNeed(needName: string): number
	local info = GetInfo()
	local level = info.Needs[needName]
	assert(level ~= nil, `Invalid need: {needName}`)
	return level
end

--[[
	Binds behaviour to networking events.
--]]
local function BindNetworking()
	Networking.BindSignalToEvent("Pet.NameChanged", EVENTS.NameChanged)
	Networking.BindSignalToEvent("Pet.NeedLevelChanged", EVENTS.NeedLevelChanged)
end

--[[
    Main entry function to the module. Performs module-specific setup.
]]
local function Start()
	UpdateInfoFromServer()
	BindNetworking()
end

Start()

return {
	Needs = NEEDS,
	Events = EVENTS,
	
	GetInfo = GetInfo,
	Rename = Rename,
	GetNeed = GetNeed,
}