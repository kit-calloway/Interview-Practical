local Players = game:GetService("Players")
--[[
    Returns a character's humanoid.
]]
local function GetHumanoid(character: Model): Humanoid?
    return character:FindFirstChildOfClass("Humanoid")
end

--[[
    Returns a player's humanoid.
]]
local function GetPlayerHumanoid(player: Player): Humanoid?
    if player.Character == nil then return end
    return GetHumanoid(player.Character)
end

--[[
    Returns whether a player's character is alive.
]]
local function IsPlayerAlive(player: Player): boolean
    local humanoid = GetPlayerHumanoid(player)
    if humanoid == nil then return false end
    return humanoid.Health > 0
end

--[[
    Returns if the given part is a player's humanoid root part, and the player it's associated with.
]]--
local function IsHumanoidRootPart(part: BasePart): (boolean, Player?)
    local player = Players:GetPlayerFromCharacter(part.Parent)
    local isHumanoidRootPart = player ~= nil and part.Name == "HumanoidRootPart"
    return isHumanoidRootPart, player
end

return {
    GetHumanoid = GetHumanoid,
    GetPlayerHumanoid = GetPlayerHumanoid,
    IsPlayerAlive = IsPlayerAlive,
    IsHumanoidRootPart = IsHumanoidRootPart,
}