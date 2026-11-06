const Players = game:GetService("Players")

const PetService = require("@game/ServerScriptService/Server/Pets/PetService")
const PlayerData = require("@game/ServerScriptService/Server/Core/PlayerData")
const PetConfig = require("@game/ReplicatedStorage/Shared/Config/Pets/PetConfig")
const Timer = require("@game/ReplicatedStorage/Shared/Modules/Utility/Timer")

--[[
	Decays needs for all player pets for a given duration.
--]]
local function DecayNeeds(deltaTime: number)
	for _, player in Players:GetPlayers() do
		for _, needName in PetService.Needs do
			local decrementAmount = deltaTime / PetConfig.Needs.DecayDuration[needName]
			PetService.DecrementNeed(player, needName, decrementAmount)
		end
	end
end

--[[
	Decays a player's pet needs according to time between their last play session.
--]]
local function ProcessOfflineDecay(player: Player)
	local leaveTime = PlayerData.GetKey(player, "LeaveTime") or os.time()
	local deltaTime = os.time() - leaveTime
	for _, needName in PetService.Needs do
		local decrementAmount = deltaTime / PetConfig.Needs.DecayDuration[needName]
		PetService.DecrementNeed(player, needName, decrementAmount)
	end
end

--[[
	Logs the leave time of a player.
--]]
local function LogLeaveTime(player: Player)
	PlayerData.SetKey(player, "LeaveTime", os.time())
end

--[[
    Main entry function to the module. Performs module-specific setup.
]]
local function Start()
	local decayTimer = Timer.new(PetConfig.Needs.DecayInterval, false)
	decayTimer:Start()
	decayTimer.Ended:Connect(function()
		-- NOTE: Timer module accounts for timer drift in its implementation
		DecayNeeds(PetConfig.Needs.DecayInterval)
	end)
	
	Players.PlayerAdded:Connect(ProcessOfflineDecay)
	Players.PlayerRemoving:Connect(LogLeaveTime)
end

Start()

return {}