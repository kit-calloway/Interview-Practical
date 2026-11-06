local ReplicatedStorage = game:GetService("ReplicatedStorage")
const Players = game:GetService("Players")

const ClickableObject = require("@game/ReplicatedStorage/Client/Effects/ClickableObject")
const Networking = require("@game/ReplicatedStorage/Client/Core/Networking")
const Observers = require("@game/ReplicatedStorage/Packages/Observers")
const Promise = require("@game/ReplicatedStorage/Packages/Promise")
const Trove = require("@game/ReplicatedStorage/Packages/Trove")

export type Key = Model
export type Component = {
	Key: Key,
	Trove: any,
}

local VALID_ANCESTORS = {
	workspace,
}

local Components = {} :: {[Key]: Component}

--[[
    Constructs a component.
]]
local function Construct(key: Key)
	key:AddTag("ClickableObject")
	ClickableObject.WaitForComponent(key, 5)
	
	local component = {
		Key = key,
		Trove = Trove.new(),
	} :: Component

	Components[key] = component
	
	local signal = ClickableObject.GetSelectedSignal(key)
	component.Trove:Connect(signal, function()
		Networking.FireServer("PetNeedCollectible.SetPetTarget", key)
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
end

Start()

return {
	IsComponent = IsComponent,
	WaitForComponent = WaitForComponent,
}