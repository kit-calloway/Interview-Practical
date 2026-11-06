local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Observers = require(ReplicatedStorage.Packages.Observers)
local ProfileStore = require(ReplicatedStorage.Packages.ProfileStore)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local PlayerDataConfig = require(ReplicatedStorage.Shared.Config.Core.PlayerDataConfig)
local TableNavigator = require(ReplicatedStorage.Shared.Modules.Utility.TableNavigator)

local PROFILE_LOAD_TIMEOUT = 60

export type ProfileSchema = PlayerDataConfig.ProfileSchema

local LoadedStore
local Profiles = {}

--[[
	Releases the profile's session lock and unloads its data from server memory.
]]
local function Unload(player: Player)
	local profile = Profiles[player]
	if profile == nil then return end
	profile:EndSession()
	Profiles[player] = nil
end

--[[
    Starts a profile session lock and loads its data into server memory.
	If the profile cannot be loaded, the player is kicked.
]]
local function Load(player: Player)
	local profile = LoadedStore:StartSessionAsync(tostring(player.UserId))
	if profile == nil then
		player:Kick(`Cannot load your data. Please rejoin.\nIf issue persists, contact a developer.`)
		return
	end

	profile:AddUserId(player.UserId)
	profile:Reconcile()
	profile.OnSessionEnd:Connect(function()
		Profiles[player] = nil
		player:Kick(`Your data was released. Have you joined another server?\nIf issue persists, contact a developer.`)
	end)
	Profiles[player] = profile

	if player:IsDescendantOf(Players) then return end
	Unload(player)
end

--[[
	Returns a player's profile, metadata included.
]]
local function GetProfile(player: Player): {Data: ProfileSchema}?
	local startTime = os.time()
	local profile = Profiles[player]
	while profile == nil and player:IsDescendantOf(Players) do
		task.wait(0.1)
		profile = Profiles[player]
		local secondsSinceStart = os.time() - startTime
		if secondsSinceStart < PROFILE_LOAD_TIMEOUT then continue end
		player:Kick(`Unable to load your player data. Try rejoining.\nIf issue persists, contact a developer.`)
		break
	end
	if profile == nil then return nil end
	return profile
end

--[[
	Returns whether a player's profile is loaded, without waiting for it like GetProfile does.
]]
function IsLoaded(player: Player): boolean
	return Profiles[player] ~= nil
end

--[[
	Returns a player's profile data, metadata excluded.
]]
function GetData(player: Player, writeAllowed: boolean?): ProfileSchema?
	local profile = GetProfile(player)
	if profile == nil then return nil end
	local data = profile.Data
	if not writeAllowed then
		data = TableUtil.Copy(profile.Data, true)
		data = table.freeze(data)
	end
	return data
end

--[[
	Returns data at a specific path within a player's data.
]]
function GetKey<T>(player: Player, path: string, writeAllowed: boolean?): T?
	local data = GetData(player, writeAllowed)
	if data == nil then return nil end
	return TableNavigator.Get(data, path)
end

--[[
	Returns whether a player has a given key.
--]]
local function HasKey(player: Player, path: string): boolean
	return GetKey(player, path, false) ~= nil
end

--[[
	Sets the key at a specific path within a player's data.
]]
function SetKey<T>(player: Player, path: string, newValue: T?)
	local steps = path:split(".")
	local finalKey = table.remove(steps)
	local parent = if #steps == 0
		then GetData(player, true)
		else GetKey(player, table.concat(steps, "."), true)
	assert(typeof(parent) == "table" and finalKey ~= "", `Cannot set "{path}" in player data`)
	parent[finalKey] = newValue
end

--[[
	Updates the key at a specific path within a player's data.
]]
function UpdateKey<T>(player: Player, path: string, mutatorFn: (T?) -> T?)
	local oldValue = GetKey(player, path)
	local newValue = mutatorFn(oldValue)
	SetKey(player, path, newValue)
end

--[[
    Main entry function to the module. Performs module-specific setup.
]]
local function Start()
	LoadedStore = ProfileStore.New("PlayerData", PlayerDataConfig.ProfileTemplate)
	if RunService:IsStudio() then
		LoadedStore = LoadedStore.Mock
	end

	Observers.observePlayer(function(player)
		Load(player)
		return function()
			task.wait(1) -- Prevents race conditions with behaviour attached to leave logic
			Unload(player)
		end
	end)
end


Start()

return {
	GetProfile = GetProfile,
	IsLoaded = IsLoaded,
	GetData = GetData,
	GetKey = GetKey,
	HasKey = HasKey,
	SetKey = SetKey,
	UpdateKey = UpdateKey,
}