const TextService = game:GetService("TextService")

const Networking = require("@game/ServerScriptService/Server/Core/Networking")
const PlayerData = require("@game/ServerScriptService/Server/Core/PlayerData")
const Observers = require("@game/ReplicatedStorage/Packages/Observers")
const PetConfig = require("@game/ReplicatedStorage/Shared/Config/Pets/PetConfig")
const PetNames = require("@game/ReplicatedStorage/Shared/Config/Pets/PetNames")
const Promise = require("@game/ReplicatedStorage/Packages/Promise")

const NEEDS = {
	Food = "Food",
	Happiness = "Happiness",
	Cleanliness = "Cleanliness",
} :: {[string]: string}

--[[
	Generates a new pet.
--]]
local function GenerateInfo(player: Player)
	if PlayerData.HasKey(player, "Pet") then return end
	PlayerData.SetKey(player, "Pet", {
		Name = PetNames.PickRandom(),
		Needs = table.clone(PetConfig.Needs.DefaultValue), -- Prevents modification of config values.
	})
end

--[[
	Returns read-only information about a player's pet.
--]]
local function GetInfo(player: Player): PetConfig.PetSchema
	GenerateInfo(player) -- Prevents race conditions, ensuring player has valid pet info
	return PlayerData.GetKey(player, "Pet", false) :: PetConfig.PetSchema
end

--[[
	Attempts to rename a player's pet with input validation.
	Returns a promise resolving to a success boolean and, if applicable, the new name.
--]]
local function Rename(player: Player, newName: string): any
	local valid = string.match(newName, PetConfig.Name.AllowedPattern) ~= nil
	if not valid then return Promise.resolve(false) end
	local trimmed = string.match(newName, "^%s*(.-)%s*$") :: string -- Should always return non-nil value
	local spacesRemoved = string.gsub(trimmed, "%s+", " ") -- Limit consecutive spaces to 1
	
	return Promise.try(function()
		local filterResult = TextService:FilterStringAsync(spacesRemoved, player.UserId, Enum.TextFilterContext.PublicChat)
		local filtered = filterResult:GetNonChatStringForBroadcastAsync()
		local valid = string.match(filtered, PetConfig.Name.AllowedPattern) ~= nil
		
		if not valid then return false, nil end
		
		PlayerData.UpdateKey(player, "Pet", function(petInfo)
			petInfo.Name = filtered
			return petInfo
		end)
		Networking.FireClient(player, "Pet.NameChanged", filtered)
		
		return true, filtered
	end)
end

--[[
	Returns a need level of a player's pet.
--]]
local function GetNeed(player: Player, needName: string): number
	local info = GetInfo(player)
	local level = info.Needs[needName]
	assert(level ~= nil, `Invalid need: {needName}`)
	return level
end

--[[
	Sets a need level of a player's pet.
	Returns the new need level.
--]]
local function SetNeed(player: Player, needName: string, newLevel: number): number
	local info = GetInfo(player)
	local validNeed = info.Needs[needName] ~= nil
	assert(validNeed, `Invalid need: {needName}`)

	newLevel = math.clamp(newLevel, 0, 1)
	PlayerData.UpdateKey(player, "Pet", function(petInfo)
		petInfo.Needs[needName] = newLevel
		return petInfo
	end)
	
	Networking.FireClient(player, "Pet.NeedLevelChanged", needName, newLevel)
	
	return newLevel
end

--[[
	Increments a need level of a player's pet.
	Returns the new need level.
--]]
local function IncrementNeed(player: Player, needName: string, amount: number): number
	local current = GetNeed(player, needName)
	local new = current + amount
	return SetNeed(player, needName, new)
end

--[[
	Decrements a need level of a player's pet.
	Returns the new need level.
--]]
local function DecrementNeed(player: Player, needName: string, amount: number): number
	local current = GetNeed(player, needName)
	local new = current - amount
	return SetNeed(player, needName, new)
end

--[[
	Binds behaviour to networking events.
--]]
local function BindNetworking()
	Networking.BindToFunction("Pet.GetInfo", GetInfo)
	Networking.BindToFunction("Pet.Rename", Rename)
end

--[[
    Main entry function to the module. Performs module-specific setup.
]]
local function Start()
	Observers.observePlayer(GenerateInfo)
	BindNetworking()
end

Start()

return {
	Needs = NEEDS,
	
	GetInfo = GetInfo,
	Rename = Rename,
	GetNeed = GetNeed,
	SetNeed = SetNeed,
	DecrementNeed = DecrementNeed,
	IncrementNeed = IncrementNeed,
}