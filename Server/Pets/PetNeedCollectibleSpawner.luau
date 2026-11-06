local ReplicatedStorage = game:GetService("ReplicatedStorage")

const PetNeedCollectibleConfig = require("@game/ReplicatedStorage/Shared/Config/Pets/PetNeedCollectibleConfig")
const PetWanderBounds = require("@game/ServerScriptService/Server/Pets/PetWanderBounds")
const Observers = require("@game/ReplicatedStorage/Packages/Observers")
const Promise = require("@game/ReplicatedStorage/Packages/Promise")
const Query = require("@game/ReplicatedStorage/Shared/Modules/Utility/Query")
const Timer = require("@game/ReplicatedStorage/Shared/Modules/Utility/Timer")
const Trove = require("@game/ReplicatedStorage/Packages/Trove")

export type Key = BasePart
export type Component = {
	Key: Key,
	Trove: any,
	SpawnTimer: Timer.Timer,
}

local COLLECTIBLE_MODELS = ReplicatedStorage.Shared.Assets.PetNeedCollectibles:GetChildren()
local VALID_ANCESTORS = {
	workspace,
}

local Components = {} :: {[Key]: Component}


--[[
	Returns whether a collectible spawner can spawn more another collectible.
--]]
local function CanSpawnCollectible(key: Key): boolean
	local collectibles = Query.Descendants(key, ">.PetNeedCollectible")
	return #collectibles < PetNeedCollectibleConfig.Spawners.MaxCollectibles
end

--[[
	Attempts to spawn a new collectible.
--]]
local function TrySpawnCollectible(key: Key)
	if not CanSpawnCollectible(key) then return end
	local randomPosition = PetWanderBounds.GetRandomPosition(key)
	local collectibleIndex = math.random(1, #COLLECTIBLE_MODELS)
	local collectibleModel = COLLECTIBLE_MODELS[collectibleIndex]:Clone()
	collectibleModel:PivotTo(CFrame.new(randomPosition))
	collectibleModel.Parent = key
end

--[[
    Constructs a component.
]]
local function Construct(key: Key)
	key:AddTag("PetWanderBounds")
	PetWanderBounds.WaitForComponent(key, 5)
	
	local component = {
		Key = key,
		Trove = Trove.new(),
		SpawnTimer = Timer.new(PetNeedCollectibleConfig.Spawners.SpawnInterval, false),
	} :: Component
	
	component.Trove:Add(component.SpawnTimer)
	component.SpawnTimer.Ended:Connect(function()
		TrySpawnCollectible(key)
	end)
	component.SpawnTimer:Start()

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