local ReplicatedStorage = game:GetService("ReplicatedStorage")

const PetComponent = require("@game/ServerScriptService/Server/Pets/PetComponent")
const StateMachine = require("@game/ReplicatedStorage/Shared/Modules/AI/StateMachine")
const Observers = require("@game/ReplicatedStorage/Packages/Observers")
const Promise = require("@game/ReplicatedStorage/Packages/Promise")
const Query = require("@game/ReplicatedStorage/Shared/Modules/Utility/Query")
const Trove = require("@game/ReplicatedStorage/Packages/Trove")

export type Key = PVInstance
export type Component = {
	Key: Key,
	Trove: any,
	MovementState: StateMachine.StateMachine,
	Animator: Animator,
	Animations: {
		Idle: Animation,
		Walk: Animation,
	},
	Tracks: {
		Idle: AnimationTrack,
		Walk: AnimationTrack,
	},
}

local VALID_ANCESTORS = {
	workspace,
}

local Components = {} :: {[Key]: Component}

--[[
	Updates the currently played animation.
--]]
local function OnMovementStateChanged(key: Key, newState: string)
	local component = Components[key]
	assert(component ~= nil, "Invalid component key!")
	for _, track in component.Tracks do
		track:Stop()
	end
	if newState == "Standing" then
		component.Tracks.Idle:Play()
	elseif newState == "Walking" then
		component.Tracks.Walk:Play()
	end
end

--[[
    Constructs a component.
]]
local function Construct(key: Key)
	key:AddTag("PetComponent")
	PetComponent.WaitForComponent(key, 5)
	
	local component = {
		Key = key,
		Trove = Trove.new(),
		MovementState = PetComponent.GetMovementState(key),
		Animator = Query.Descendant(key, "Animator"),
		Animations = {
			Idle = Query.Descendant(key, "Animation#Idle"),
			Walk = Query.Descendant(key, "Animation#Walk"),
		},
	} :: Component

	component.Tracks = {
		Idle = component.Animator:LoadAnimation(component.Animations.Idle),
		Walk = component.Animator:LoadAnimation(component.Animations.Walk),
	}

	Components[key] = component
	
	OnMovementStateChanged(key, component.MovementState.State)
	component.Trove:Connect(component.MovementState.StateEntered, function(newState)
		OnMovementStateChanged(key, newState)
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