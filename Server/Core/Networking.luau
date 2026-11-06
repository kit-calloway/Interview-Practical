const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Signal = require("@game/ReplicatedStorage/Packages/Signal")

local RemoteEvent = Instance.new("RemoteEvent")
local RemoteFunction = Instance.new("RemoteFunction")
local FunctionCallbacks = {}

export type EventCallback = (player: Player, ...any) -> ()
export type FunctionCallback = (player: Player, ...any) -> ...any

--[[
	Sends an event to a client.
--]]
local function FireClient(player: Player, eventName: string, ...)
	RemoteEvent:FireClient(player, eventName, ...)
end

--[[
	Sends an event to all clients.
--]]
local function FireAllClients(eventName: string, ...)
	RemoteEvent:FireAllClients(eventName, ...)
end

--[[
	Binds a function to a remote event.
	Returns an event connection.
--]]
local function BindToEvent(eventName: string, callback: EventCallback): RBXScriptConnection
	return RemoteEvent.OnServerEvent:Connect(function(player: Player, otherEventName: string, ...)
		if otherEventName ~= eventName then return end
		callback(player, ...)
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

--[[
	Binds a function to a remote function.
	To unbind a function, pass in a nil value for the callback.
--]]
local function BindToFunction(functionName: string, callback: FunctionCallback?)
	FunctionCallbacks[functionName] = callback
end

--[[
	Sets up networking objects
--]]
local function InstantiateNetworking()
	local folder = Instance.new("Folder")
	folder.Name = "Networking"
	folder.Parent = ReplicatedStorage
	
	RemoteEvent.Parent = folder
	RemoteFunction.Parent = folder
end

--[[
	Responds to client invocations of the server.
--]]
local function OnFunctionInvoked(player: Player, functionName: string, ...)
	local callback = FunctionCallbacks[functionName]
	assert(callback ~= nil, `Callback for function name "{functionName}" has not be bound by the server.`)
	return callback(player, ...)
end

--[[
    Main entry function to the module. Performs module-specific setup.
]]
local function Start()
	InstantiateNetworking()
	RemoteFunction.OnServerInvoke = OnFunctionInvoked
end

Start()

return {
	FireClient = FireClient,
	FireAllClients = FireAllClients,
	BindToEvent = BindToEvent,
	BindSignalToEvent = BindSignalToEvent,
	BindToFunction = BindToFunction,
}