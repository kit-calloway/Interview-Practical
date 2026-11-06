const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Promise = require("@game/ReplicatedStorage/Packages/Promise")
const Query = require("@game/ReplicatedStorage/Shared/Modules/Utility/Query")

local RemoteEvent = Query.Descendant(ReplicatedStorage, "Folder#Networking > RemoteEvent") :: RemoteEvent
local RemoteFunction = Query.Descendant(ReplicatedStorage, "Folder#Networking > RemoteFunction") :: RemoteFunction

export type EventCallback = (player: Player, ...any) -> ()
export type FunctionCallback = (player: Player, ...any) -> ...any

--[[
	Sends an event to the server.
--]]
local function FireServer(eventName: string, ...)
	RemoteEvent:FireServer(eventName, ...)
end

--[[
	Invokes the server.
	Returns a promise that resolves to the returned value of the query.
--]]
local function InvokeServer(eventName: string, ...): any
	local args = table.pack(...)
	return Promise.try(function()
		return RemoteFunction:InvokeServer(eventName, table.unpack(args))
	end)
end

--[[
	Binds a function to a remote event.
	Returns an event connection.
--]]
local function BindToEvent(eventName: string, callback: EventCallback): RBXScriptConnection
	return RemoteEvent.OnClientEvent:Connect(function(otherEventName: string, ...)
		if otherEventName ~= eventName then return end
		callback(...)
	end)
end

--[[
	Binds a signal to a networking event.
	Returns an event connection.
--]]
local function BindSignalToEvent(eventName: string, signal: any): RBXScriptConnection
	return BindToEvent(eventName, function(...)
		signal:Fire(...)
	end)
end

return {
	FireServer = FireServer,
	InvokeServer = InvokeServer,
	BindToEvent = BindToEvent,
	BindSignalToEvent = BindSignalToEvent,
}