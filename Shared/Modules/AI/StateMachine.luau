--[[
	NOTE: Whilst typical OOP classes using metatables does work and is recommended, I prefer to be more explicit 
	with my interfaces to control visibility. For that reason, you'll notice I instead insert methods into the class 
	directly like I do my module returns. This approach is also simpler and feels less "magic" than using metatables.
]]--

const Signal = require("@game/ReplicatedStorage/Packages/Signal")

export type StateMachine = {
	State: string,
	StateEntered: any,
	StateLeft: any,
	
	SetState: (StateMachine, newState: string) -> (),
}

--[[
	Sets a state machine's current state.
	Returns whether the state change was successful.
--]]
local function SetState(stateMachine: StateMachine, newState: string): boolean
	if stateMachine.State == newState then return false end
	local oldState = stateMachine.State
	stateMachine.State = newState
	stateMachine.StateLeft:Fire(oldState)
	stateMachine.StateEntered:Fire(newState)
	return true
end

--[[
	Destroys the state machine.
--]]
local function Destroy(stateMachine: StateMachine)
	stateMachine.StateEntered:Destroy()
	stateMachine.StateLeft:Destroy()
end

--[[
	Creates a new state machine
--]]
local function new(startingState: string): StateMachine
	return {
		State = startingState,
		StateEntered = Signal.new(),
		StateLeft = Signal.new(),
		
		SetState = SetState,
		Destroy = Destroy,
	}
end

return {
	new = new,
}