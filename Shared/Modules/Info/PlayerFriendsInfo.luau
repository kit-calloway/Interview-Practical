local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)

export type OnlineFriendInfo = {
	VisitorId: number,
	UserName: string,
	DisplayName: string,
	LastOnline: string,
	IsOnline: boolean,
	LastLocation: string?,
	PlaceId: number?,
	GameId: string?,
	LocationType: number?,
}

--[[
    Returns a promise that resolves to a list of friends in the server.
]]--
local function GetFriendsInServer(player: Player): any
	local promises = {}
	local friends = {}
	
	if player.UserId <= 0 then return Promise.resolve({}) end
	
	for _, other in Players:GetPlayers() do
		if other == player then continue end
		local promise = Promise.try(
			player.IsFriendsWithAsync,
			player,
			other.UserId
		):andThen(function(isFriend)
			if not isFriend then return end
			table.insert(friends, other)
		end)
		table.insert(promises, promise)
	end
	return Promise.all(promises):andThenReturn(friends)
end

--[[
    Returns a promise that resolves to a list of online friend infos for a player.
]]--
local function GetOnlineFriendInfos(player: Player): any
	return Promise.retryWithDelay(
		Promise.try,
		5,
		1,
		player.GetFriendsOnlineAsync,
		player
	)
end

--[[
	Returns a promise that resolves to a list of user ID of friends who have played the game.
--]]
local function GetFriendsWhoHavePlayed(player: Player): any
	return Promise.try(player.GetFriendsWhoPlayedAsync, player)
end

return {
	GetFriendsInServer = GetFriendsInServer,
	GetOnlineFriendInfos = GetOnlineFriendInfos,
	GetFriendsWhoHavePlayed = GetFriendsWhoHavePlayed,
}