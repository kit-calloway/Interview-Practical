local RunService = game:GetService("RunService")

const Signal = require("@game/ReplicatedStorage/Packages/Signal")

export type Timer = {
	Duration: number,
	TimeLeft: number,
	OneShot: boolean,
	Paused: boolean,
	
	Start: (Timer) -> (),
	Stop: (Timer) -> (),
	Destroy: (Timer) -> (),
	
	Ended: any,
	_RunConnection: RBXScriptConnection?,
}

--[[
    Stops a timer.
]]--
local function Stop(timer: Timer)
	if timer.Paused then return end
	if timer._RunConnection == nil then return end
	timer._RunConnection:Disconnect()
	timer.Paused = true
	timer.TimeLeft = timer.Duration
end

--[[
    Increments a running timer.
]]--
local function OnHeartbeat(timer: Timer, deltaTime: number)
	if timer.Paused then return end

	timer.TimeLeft -= deltaTime
	if timer.TimeLeft > 0 then return end
	
	if timer.OneShot then
		timer:Stop()
		timer.Ended:Fire()
	else
		while timer.TimeLeft <= 0 do
			timer.TimeLeft += timer.Duration
			timer.Ended:Fire()
		end
	end
end

--[[
    Starts a timer.
]]--
local function Start(timer: Timer)
	timer.Paused = false
	timer._RunConnection = RunService.Heartbeat:Connect(function(deltaTime)
		OnHeartbeat(timer, deltaTime)
	end)
end

--[[
    Alias for stopping a timer.
]]--
local function Destroy(timer: Timer)
	timer:Stop()
end

--[[
    Creates a new timer.
]]--
local function new(duration: number, oneShot: boolean): Timer
	return {
		Duration = duration,
		TimeLeft = duration,
		OneShot = if oneShot ~= nil then oneShot else true,
		Paused = true,
		
		Start = Start,
		Stop = Stop,
		Destroy = Destroy,
		
		Ended = Signal.new(),
	}
end

return {
	new = new,
}