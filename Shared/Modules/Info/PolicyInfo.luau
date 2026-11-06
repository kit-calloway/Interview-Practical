local Players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)

export type PolicyInfo = {
	AreAdsAllowed: boolean,
	ArePaidRandomItemsRestricted: boolean,
	IsContentSharingAllowed: boolean,
	IsEligibleToPurchaseCommerceProduct: boolean,
	IsEligibleToPurchaseSubscription: boolean,
	IsPaidItemTradingAllowed: boolean,
	IsPhotoToAvatarAllowed: boolean,
	IsSubjectToChinaPolicies: boolean,
	AllowedExternalLinkReferences: boolean,
	IsEndlessContentLoadAllowed: boolean,
	IsEndlessContentAutoplayAllowed: boolean,
}

local InfoCache = {}

--[[
    Returns a promise that resolves to info about a gamepass or dev product.
]]--
local function GetInfo(player: Player): any
	local cached = InfoCache[player] ~= nil
	
	if not cached then
		local promise = Promise.retryWithDelay(
			Promise.try,
			5,
			1,
			PolicyService.GetPolicyInfoForPlayerAsync,
			PolicyService, 
			player
		):tap(function()
			if player:IsDescendantOf(Players) then return end
			InfoCache[player] = nil
		end)
		InfoCache[player] = promise
		-- A failed lookup isn't kept, so the next call asks again
		promise:catch(function()
			if InfoCache[player] ~= promise then return end
			InfoCache[player] = nil
		end)
	end
	
	return InfoCache[player]
end

Players.PlayerRemoving:Connect(function(player)
	InfoCache[player] = nil
end)

return {
	GetInfo = GetInfo,
}