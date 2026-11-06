local ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")

const StateMachine = require("@game/ReplicatedStorage/Shared/Modules/AI/StateMachine")
const Observers = require("@game/ReplicatedStorage/Packages/Observers")
const Promise = require("@game/ReplicatedStorage/Packages/Promise")
const Query = require("@game/ReplicatedStorage/Shared/Modules/Utility/Query")
const Trove = require("@game/ReplicatedStorage/Packages/Trove")

export type Key = PVInstance
export type Component = {
	Key: Key,
	Trove: any,
	TargetPosition: Vector3,
	MovementState: StateMachine.StateMachine,
	BehaviourState: StateMachine.StateMachine,
}

local STATES = {
	Movement = {
		Standing = "Standing",
		Walking = "Walking",
	},
	Behaviour = {
		Wander = "Wander",
	}, 
}
local VALID_ANCESTORS = {
	workspace,
}

local Components = {} :: {[Key]: Component}

--[[
	Retrieves a pet's current target.
--]]
local function GetTarget(key: Key): Vector3
	local component = Components[key]
	assert(component ~= nil, "Invalid component key!")
	return component.TargetPosition
end

--[[
	Sets a pet's target.
--]]
local function SetTarget(key: Key, newTarget: Vector3)
	local component = Components[key]
	assert(component ~= nil, "Invalid component key!")
	component.TargetPosition = newTarget
end

--[[
	Returns a reference to a pet's movement state.
--]]
local function GetMovementState(key: Key): StateMachine.StateMachine
	local component = Components[key]
	assert(component ~= nil, "Invalid component key!")
	return component.MovementState
end

--[[
	Returns a reference to a pet's behaviour state.
--]]
local function GetBehaviourState(key: Key): StateMachine.StateMachine
	local component = Components[key]
	assert(component ~= nil, "Invalid component key!")
	return component.BehaviourState
end

--[[
    Constructs a component.
]]
local function Construct(key: Key)
	local component = {
		Key = key,
		Trove = Trove.new(),
		TargetPosition = Vector3.zero,
		MovementState = StateMachine.new(STATES.Movement.Standing),
		BehaviourState = StateMachine.new(STATES.Behaviour.Wander),
	} :: Component

	component.Trove:Add(component.MovementState)
	component.Trove:Add(component.BehaviourState)

	Components[key] = component
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
		"Pet",
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
	States = STATES,
	
	GetTarget = GetTarget,
	SetTarget = SetTarget,
	GetMovementState = GetMovementState,
	GetBehaviourState = GetBehaviourState,
	
	IsComponent = IsComponent,
	WaitForComponent = WaitForComponent,
}	