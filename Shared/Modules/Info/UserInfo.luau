local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserService = game:GetService("UserService")

local Promise = require(ReplicatedStorage.Packages.Promise)

local InfoCache = {}
local ThumbnailCache = {}

export type UserInfo = {
	Id: number,
	Username: string,
	DisplayName: string,
	HasVerifiedBadge: string,
}

--[[
    Returns a promise that resolves when all user infos have been cached.
]]--
local function CacheInfo(userIds: {number}): any
	local uncachedUserIds = {}
	for _, userId in userIds do
		local cached = InfoCache[userId] ~= nil
		if cached then continue end
		table.insert(uncachedUserIds, userIds)
	end
	
	if #uncachedUserIds == 0 then return Promise.resolve() end

	local promise = Promise.retryWithDelay(
		Promise.try,
		5,
		1,
		UserService.GetUserInfosByUserIdsAsync,
		UserService,
		userIds
	)
	
	return promise:andThen(function(userInfos)
		for _, userInfo in userInfos do
			InfoCache[userInfo.Id] = promise:andThenReturn(userInfo)
		end
	end)
end

--[[
    Returns a promise that resolves to a user's info.
]]--
local function GetInfo(userId: number): any
	local cached = InfoCache[userId] ~= nil
	
	if cached then
		return InfoCache[userId]
	else
		return CacheInfo({userId}):andThenReturn(InfoCache[userId])
	end
end

--[[
    Returns a promise that resolves when a thumbnail is successfully cached.
]]--
local function CacheThumbnail(userId: number, type: Enum.ThumbnailType, size: Enum.ThumbnailSize): any
	local key = `{userId}-{type.Name}-{size.Name}`
	
	local cached = ThumbnailCache[key] ~= nil
	if cached then return Promise.resolve() end

	local promise = Promise.retryWithDelay(
		Promise.try,
		5,
		1,
		Players.GetUserThumbnailAsync,
		Players,
		userId,
		type,
		size
	)
	ThumbnailCache[key] = promise

	return promise
end

--[[
    Returns a promise that resolve to a player's thumbnail.
]]--
local function GetThumbnail(userId: number, type: Enum.ThumbnailType, size: Enum.ThumbnailSize): any
	local key = `{userId}-{type.Name}-{size.Name}`
	local cached = ThumbnailCache[key] ~= nil
	if cached then
		return ThumbnailCache[key]	
	else
		return CacheThumbnail(userId, type, size)
	end
end

return {
	GetInfo = GetInfo,
	GetThumbnail = GetThumbnail,
	CacheInfo = CacheInfo,
	CacheThumbnail = CacheThumbnail,
}