local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ROOT = ReplicatedStorage.Shared.Assets

--[[
	Returns the requested asset itself, not a copy: :Clone() it before parenting it anywhere.
]]
return function(path: string): Instance
	return ROOT:QueryDescendants(path)[1]
end