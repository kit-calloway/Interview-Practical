local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GetAsset = require(ReplicatedStorage.Shared.Modules.Utility.GetAsset)

local SoundPlayer = {}

function SoundPlayer.Play(soundName: string, properties: {[string]: any}): Sound
    local sound = GetAsset(`> #Sounds >> Sound #{soundName}`)
    assert(sound ~= nil, `Sound asset "{soundName}" doesn't exist!`)
    sound = sound:Clone()
	for propertyName, propertyValue in properties or {} do
        sound[propertyName] = propertyValue
    end
    sound.Parent = if sound.Parent == nil and RunService:IsClient() then Players.LocalPlayer.PlayerGui else sound.Parent
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
    sound:Play()
    return sound
end

function SoundPlayer.PlayInAir(soundName: string, position: Vector3, properties: {[string]: any}): Sound
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Transparency = 1
    part.Size = Vector3.one
    part.Position = position
    part.Parent = workspace
    properties = properties or {}
    properties.Parent = part
    local sound = SoundPlayer.Play(soundName, properties)
    sound.Ended:Connect(function()
        part:Destroy()
    end)
    return sound
end

return SoundPlayer