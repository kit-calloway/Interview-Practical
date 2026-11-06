local ReplicatedStorage = game:GetService("ReplicatedStorage")

const PetBehaviourConfig = require("@game/ReplicatedStorage/Shared/Config/Pets/PetBehaviourConfig")
const Observers = require("@game/ReplicatedStorage/Packages/Observers")
const Promise = require("@game/ReplicatedStorage/Packages/Promise")
const Trove = require("@game/ReplicatedStorage/Packages/Trove")

export type Key = BasePart
export type Component = {
	Key: Key,
	Trove: any,
}

local VALID_ANCESTORS = {
	workspace,
}

local Components = {} :: {[Key]: Component}

--[[
	Returns the radius of a wander bounds.
--]]
local function GetRadius(key: Key): number
	return math.max(key.Size.X, key.Size.Y, key.Size.Z) / 2
end

--[[
	Returns the origin of a wander bounds.
--]]
local function GetOrigin(key: Key): Vector3
	return key.Position * Vector3.new(1, 0, 1) -- Remove redundant Y component
end

--[[
	Gets a random position within a wander bounds.
	Ensures unbaised distribution by rejecting values outside the circle instead of angle-distance implementation.
--]]
local function GetRandomPosition(key: Key, currentPosition: Vector3?): Vector3
	local radius = GetRadius(key)
	local random = Random.new()
	local position
	while position == nil do
		local x = random:NextNumber(-radius, radius)
		local z = random:NextNumber(-radius, radius)
		local candidate = Vector3.new(x, 0, z)
		if candidate.Magnitude > radius then continue end -- Reject points outside the radius
		if currentPosition ~= nil then
			local distance = (currentPosition - candidate).Magnitude
			if distance < PetBehaviourConfig.Wander.MinTargetDistance then continue end -- Reject points too close to current position
		end
		position = candidate
	end
	return GetOrigin(key) + position
end

--[[
    Constructs a component.
]]
local function Construct(key: Key)
	local component = {
		Key = key,
		Trove = Trove.new(),
	} :: Component

	Components[key] = component
	
	key.Transparency = 1
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
	GetRandomPosition = GetRandomPosition,
	
	IsComponent = IsComponent,
	WaitForComponent = WaitForComponent,
}