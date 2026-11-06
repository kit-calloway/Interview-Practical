local ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")

const PetBehaviourConfig = require("@game/ReplicatedStorage/Shared/Config/Pets/PetBehaviourConfig")
const PetWanderBounds = require("@game/ServerScriptService/Server/Pets/PetWanderBounds")
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
	ControllerManager: ControllerManager,
}

local REACHED_THRESHOLD = 0.5
local VALID_ANCESTORS = {
	workspace,
}

local Components = {} :: {[Key]: Component}

--[[
	If a pet has stopped, queues up a change in target after a delay.
--]]
local function TryWander(key: Key)
	local component = Components[key]
	assert(component ~= nil, "Invalid component key!")
	local movementState = PetComponent.GetMovementState(key)
	local behaviourState = PetComponent.GetBehaviourState(key)
	local isWandering = behaviourState.State == PetComponent.States.Behaviour.Wander
	local isStopped = movementState.State == PetComponent.States.Movement.Standing
	if not isWandering or not isStopped then return end
	
	local newTargetInterval = PetBehaviourConfig.Wander.NewTargetInterval
	local delay = Random.new():NextNumber(newTargetInterval.Min, newTargetInterval.Max)
	task.delay(delay, function()
		local isWandering = behaviourState.State == PetComponent.States.Behaviour.Wander
		local isStopped = movementState.State == PetComponent.States.Movement.Standing
		if not isWandering or not isStopped then return end -- Ensure still wandering
		local wanderBoundsKey = key:GetAttribute("WanderBounds"):Get()
		local currentPosition = key:GetPivot().Position
		local newPosition = PetWanderBounds.GetRandomPosition(wanderBoundsKey, currentPosition)
		PetComponent.SetTarget(key, newPosition)
	end)
end

--[[
    Constructs a component.
]]
local function Construct(key: Key)
	PetComponent.WaitForComponent(key, 5):await()
		
	local component = {
		Key = key,
		Trove = Trove.new(),
		ControllerManager = Query.Descendant(key, "ControllerManager"),
	} :: Component
	
	Components[key] = component
	
	TryWander(key)
	local movementState = PetComponent.GetMovementState(key)
	local behaviourState = PetComponent.GetBehaviourState(key)
	movementState.StateEntered:Connect(function()
		TryWander(key)
	end)
	behaviourState.StateEntered:Connect(function()
		TryWander(key)
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
	Updates all pets' move directions according to current positions and targets.
--]]
local function UpdateMoveDirections()
	for key, component in Components do
		local movementState = PetComponent.GetMovementState(key)
		local behaviourState = PetComponent.GetBehaviourState(key)
		
		local isWandering = behaviourState.State == PetComponent.States.Behaviour.Wander
		if not isWandering then continue end
		local keyPosition = key:GetPivot().Position
		local targetPosition = PetComponent.GetTarget(key)
		local direction = (targetPosition - keyPosition) * Vector3.new(1, 0, 1) -- Remove vertical vector component
		local distance = direction.Magnitude
		local reached = distance < REACHED_THRESHOLD
		local moveDirection = if reached then Vector3.zero else direction.Unit
		
		component.ControllerManager.MovingDirection = moveDirection
		movementState:SetState(
			if moveDirection.Magnitude > 0 
			then PetComponent.States.Movement.Walking 
			else PetComponent.States.Movement.Standing
		)
		if moveDirection.Magnitude == 0 then continue end
		component.ControllerManager.FacingDirection = moveDirection
	end
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
	
	RunService.PreSimulation:Connect(UpdateMoveDirections)
end

Start()

return {
	IsComponent = IsComponent,
	WaitForComponent = WaitForComponent,
}	