local ReplicatedStorage = game:GetService("ReplicatedStorage")
const Players = game:GetService("Players")

const PetComponent = require("@game/ServerScriptService/Server/Pets/PetComponent")
const Networking = require("@game/ServerScriptService/Server/Core/Networking")
const PetService = require("@game/ServerScriptService/Server/Pets/PetService")
const Observers = require("@game/ReplicatedStorage/Packages/Observers")
const Promise = require("@game/ReplicatedStorage/Packages/Promise")
const Query = require("@game/ReplicatedStorage/Shared/Modules/Utility/Query")
const Trove = require("@game/ReplicatedStorage/Packages/Trove")

export type Key = Model
export type Component = {
	Key: Key,
	Trove: any,
	NeedName: string,
	NeedAmount: number,
}

local VALID_ANCESTORS = {
	workspace,
}

local Components = {} :: {[Key]: Component}

--[[
	Attempts to collect a need collectible.
--]]
local function TryCollect(key: Key, otherPart: BasePart)
	local component = Components[key]
	assert(component ~= nil, "Invalid component key!")
	local petKey = otherPart.Parent
	if petKey == nil then return end
	local isPet = petKey:HasTag("Pet")
	if not isPet then return end
	local player = Players:GetPlayers()[1]
	PetService.IncrementNeed(player, component.NeedName, component.NeedAmount)
	key:Destroy()
end

--[[
    Constructs a component.
]]
local function Construct(key: Key)
	local component = {
		Key = key,
		Trove = Trove.new(),
		NeedName = key:GetAttribute("NeedName"),
		NeedAmount = key:GetAttribute("NeedAmount"),
	} :: Component

	Components[key] = component
	
	assert(key.PrimaryPart ~= nil, `Primary part required!`)
	component.Trove:Connect(key.PrimaryPart.Touched, function(otherPart)
		TryCollect(key, otherPart)
	end)
end

--[[
    Deconstructs a component.
]]
local function Deconstruct(key: Key)
	local component = Components[key]
	if component == nil then return end
	component.Trove:Clean()
	component.Trove = nil
	Components[component.Key] = nil
end

--[[
	Returns whether an instance is a component key.
--]]
local function IsComponent(key: Key): boolean
	return Components[key] ~= nil
end

--[[
	Returns a promise that resolves when a component is created.
--]]
local function WaitForComponent(key: Key, timeout: number): any
	return Promise.try(function()
		while not IsComponent(key) do
			task.wait()
		end
	end)
	:timeout(timeout)
end

--[[
	Attempts to set a pet's target to a pet need collectible.
--]]
local function SetPetTarget(player: Player, key: Key)
	local component = Components[key]
	if component == nil then return end
	local petKey = Query.Descendant(workspace, ".Pet") :: PVInstance
	local targetPosition = key:GetPivot().Position
	PetComponent.SetTarget(petKey, targetPosition)
end

--[[
    Main entry function to the module. Performs module-specific setup.
]]
local function Start()
	Observers.observeTag(
		script.Name,
		function(key: Key)
			Construct(key)
			return function()
				Deconstruct(key)
			end
		end,
		VALID_ANCESTORS
	)
	
	Networking.BindToEvent("PetNeedCollectible.SetPetTarget", SetPetTarget)
end

Start()

return {
	IsComponent = IsComponent,
	WaitForComponent = WaitForComponent,
}