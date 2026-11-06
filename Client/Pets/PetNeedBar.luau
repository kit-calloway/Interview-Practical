local ReplicatedStorage = game:GetService("ReplicatedStorage")

const SequenceUtilities = require("@game/ReplicatedStorage/Shared/Modules/Utility/SequenceUtilities")
const PetService = require("@game/ReplicatedStorage/Client/Pets/PetService")
const Observers = require("@game/ReplicatedStorage/Packages/Observers")
const Promise = require("@game/ReplicatedStorage/Packages/Promise")
const Trove = require("@game/ReplicatedStorage/Packages/Trove")

export type Key = UIGradient
export type Component = {
	Key: Key,
	Trove: any,
	NeedName: string,
}

local VALID_ANCESTORS = {
	workspace,
}

local Components = {} :: {[Key]: Component}

--[[
	Sets the level of a need bar.
--]]
local function SetLevel(key: Key, newLevel: number)
	local component = Components[key]
	assert(component ~= nil, "Invalid component key!")
	local numberSequence = SequenceUtilities.SetNumberSequenceProgress(newLevel, 0, 1)
	component.Key.Transparency = numberSequence
end

--[[
	Updates need level bars.
--]]
local function OnNeedLevelChanged(needName: string, newLevel: number)
	for key, component in Components do
		if component.NeedName ~= needName then continue end
		SetLevel(key, newLevel)
	end
end

--[[
    Constructs a component.
]]
local function Construct(key: Key)
	local component = {
		Key = key,
		Trove = Trove.new(),
		NeedName = key:GetAttribute("NeedName"),
	} :: Component

	Components[key] = component
	
	local needLevel = PetService.GetNeed(component.NeedName)
	SetLevel(key, needLevel)
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
	
	PetService.Events.NeedLevelChanged:Connect(OnNeedLevelChanged)
end

Start()

return {
	IsComponent = IsComponent,
	WaitForComponent = WaitForComponent,
}