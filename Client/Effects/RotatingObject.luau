local ReplicatedStorage = game:GetService("ReplicatedStorage")

const Observers = require("@game/ReplicatedStorage/Packages/Observers")
const Promise = require("@game/ReplicatedStorage/Packages/Promise")
const Query = require("@game/ReplicatedStorage/Shared/Modules/Utility/Query")
const Trove = require("@game/ReplicatedStorage/Packages/Trove")

export type Key = Model
export type Component = {
	Key: Key,
	Trove: any,
	Animator: Animator,
	Animation: Animation,
	Track: AnimationTrack,
}

local VALID_ANCESTORS = {
	workspace,
}

local Components = {} :: {[Key]: Component}

--[[
    Constructs a component.
]]
local function Construct(key: Key)
	local component = {
		Key = key,
		Trove = Trove.new(),
		Animator = Query.Descendant(key, "Animator"),
		Animation = Query.Descendant(key, "Animation#ObjectRotate"),
	} :: Component
	
	component.Track = component.Animator:LoadAnimation(component.Animation)
	component.Track.Looped = true

	Components[key] = component
	
	component.Track:Play(0, 1, 1)
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